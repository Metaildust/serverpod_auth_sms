import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import 'generated/protocol.dart';
import 'phone/phone_id_store.dart';
import 'sms_idp_config.dart';
import 'sms_idp_utils.dart';

class SmsIdp {
  static const String method = 'sms';

  final SmsIdpConfig config;
  final SmsIdpUtils utils;
  final TokenManager _tokenManager;
  final AuthUsers _authUsers;
  final UserProfiles _userProfiles;

  SmsIdp._(
    this.config,
    this.utils,
    this._tokenManager,
    this._authUsers,
    this._userProfiles,
  );

  factory SmsIdp(
    SmsIdpConfig config, {
    required TokenManager tokenManager,
    required AuthUsers authUsers,
    required UserProfiles userProfiles,
  }) {
    final utils = SmsIdpUtils(
      config: config,
      authUsers: authUsers,
    );
    return SmsIdp._(config, utils, tokenManager, authUsers, userProfiles);
  }

  Future<UuidValue> startRegistration(
    Session session, {
    required String phone,
    Transaction? transaction,
  }) async {
    if (!config.enableRegistration) {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.invalid,
      );
    }
    return DatabaseUtil.runInTransactionOrSavepoint(
      session.db,
      transaction,
      (transaction) async {
        try {
          return await utils.accountCreation.startRegistration(
            session,
            phone: phone,
            transaction: transaction,
          );
        } on SmsAccountAlreadyRegisteredException catch (_) {
          session.log(
            'Failed to start registration for phone, reason: already registered',
            level: LogLevel.debug,
          );
          return const Uuid().v7obj();
        }
      },
    );
  }

  Future<String> verifyRegistrationCode(
    Session session, {
    required UuidValue accountRequestId,
    required String verificationCode,
    Transaction? transaction,
  }) async {
    return DatabaseUtil.runInTransactionOrSavepoint(
      session.db,
      transaction,
      (transaction) =>
          utils.accountCreation.verifyRegistrationCode(
            session,
            accountRequestId: accountRequestId,
            verificationCode: verificationCode,
            transaction: transaction,
          ),
    );
  }

  Future<AuthSuccess> finishRegistration(
    Session session, {
    required String registrationToken,
    required String phone,
    required String password,
    Transaction? transaction,
  }) async {
    return DatabaseUtil.runInTransactionOrSavepoint(
      session.db,
      transaction,
      (transaction) async {
        final result = await utils.accountCreation.completeAccountCreation(
          session,
          registrationToken: registrationToken,
          phone: phone,
          password: password,
          transaction: transaction,
        );

        await _userProfiles.createUserProfile(
          session,
          result.authUserId,
          UserProfileData(),
          transaction: transaction,
        );

        return _tokenManager.issueToken(
          session,
          authUserId: result.authUserId,
          method: method,
          scopes: result.scopes,
          transaction: transaction,
        );
      },
    );
  }

  Future<UuidValue> startLogin(
    Session session, {
    required String phone,
    Transaction? transaction,
  }) async {
    if (!config.enableLogin) {
      throw SmsLoginException(reason: SmsLoginExceptionReason.invalid);
    }
    return DatabaseUtil.runInTransactionOrSavepoint(
      session.db,
      transaction,
      (transaction) async =>
          utils.login.startLogin(
            session,
            phone: phone,
            transaction: transaction,
          ),
    );
  }

  Future<SmsVerifyLoginResult> verifyLoginCode(
    Session session, {
    required UuidValue loginRequestId,
    required String verificationCode,
    Transaction? transaction,
  }) async {
    return DatabaseUtil.runInTransactionOrSavepoint(
      session.db,
      transaction,
      (transaction) =>
          utils.login.verifyLoginCode(
            session,
            loginRequestId: loginRequestId,
            verificationCode: verificationCode,
            transaction: transaction,
          ),
    );
  }

  Future<AuthSuccess> finishLogin(
    Session session, {
    required String loginToken,
    required String phone,
    String? password,
    Transaction? transaction,
  }) async {
    if (!config.enableLogin) {
      throw SmsLoginException(reason: SmsLoginExceptionReason.invalid);
    }
    return DatabaseUtil.runInTransactionOrSavepoint(
      session.db,
      transaction,
      (transaction) async {
        final request = await utils.login.completeLogin(
          session,
          loginToken: loginToken,
          transaction: transaction,
        );

        final normalized = config.phoneIdStore.normalizePhone(phone);
        final phoneHash = config.phoneIdStore.hashPhone(normalized);
        if (phoneHash != request.phoneHash) {
          throw SmsLoginException(reason: SmsLoginExceptionReason.invalid);
        }

        final existingAuthUserId = await config.phoneIdStore
            .findAuthUserIdByPhoneHash(
              session,
              phoneHash: phoneHash,
              transaction: transaction,
            );

        if (existingAuthUserId != null) {
          final authUser = await _authUsers.get(
            session,
            authUserId: existingAuthUserId,
            transaction: transaction,
          );
          await SmsLoginRequest.db.deleteRow(
            session,
            request,
            transaction: transaction,
          );
          return _tokenManager.issueToken(
            session,
            authUserId: authUser.id,
            method: method,
            scopes: authUser.scopes,
            transaction: transaction,
          );
        }

        if (config.requirePasswordOnUnregisteredLogin &&
            (password == null || password.isEmpty)) {
          throw SmsLoginException(reason: SmsLoginExceptionReason.passwordRequired);
        }

        if (!config.passwordValidationFunction(password ?? '')) {
          throw SmsLoginException(reason: SmsLoginExceptionReason.policyViolation);
        }

        final authUser = await _authUsers.create(
          session,
          transaction: transaction,
        );

        final passwordHash = await utils.hashUtil.createHashFromString(
          secret: password ?? '',
        );
        await SmsAccount.db.insertRow(
          session,
          SmsAccount(
            authUserId: authUser.id,
            passwordHash: passwordHash,
          ),
          transaction: transaction,
        );

        try {
          await config.phoneIdStore.bindPhone(
            session,
            authUserId: authUser.id,
            phone: normalized,
            allowRebind: config.allowPhoneRebind,
            transaction: transaction,
          );
        } on PhoneAlreadyBoundException {
          throw SmsLoginException(reason: SmsLoginExceptionReason.invalid);
        } on PhoneRebindNotAllowedException {
          throw SmsLoginException(reason: SmsLoginExceptionReason.invalid);
        }

        await config.onAfterAccountCreated?.call(
          session,
          authUserId: authUser.id,
          transaction: transaction,
        );
        await config.onAfterPhoneBound?.call(
          session,
          authUserId: authUser.id,
          transaction: transaction,
        );

        await _userProfiles.createUserProfile(
          session,
          authUser.id,
          UserProfileData(),
          transaction: transaction,
        );

        await SmsLoginRequest.db.deleteRow(
          session,
          request,
          transaction: transaction,
        );

        return _tokenManager.issueToken(
          session,
          authUserId: authUser.id,
          method: method,
          scopes: authUser.scopes,
          transaction: transaction,
        );
      },
    );
  }

  Future<UuidValue> startBindPhone(
    Session session, {
    required UuidValue authUserId,
    required String phone,
    Transaction? transaction,
  }) async {
    if (!config.enableBind) {
      throw SmsPhoneBindException(reason: SmsPhoneBindExceptionReason.invalid);
    }
    return DatabaseUtil.runInTransactionOrSavepoint(
      session.db,
      transaction,
      (transaction) => utils.bind.startBind(
        session,
        authUserId: authUserId,
        phone: phone,
        transaction: transaction,
      ),
    );
  }

  Future<String> verifyBindCode(
    Session session, {
    required UuidValue bindRequestId,
    required String verificationCode,
    Transaction? transaction,
  }) async {
    return DatabaseUtil.runInTransactionOrSavepoint(
      session.db,
      transaction,
      (transaction) => utils.bind.verifyBindCode(
        session,
        bindRequestId: bindRequestId,
        verificationCode: verificationCode,
        transaction: transaction,
      ),
    );
  }

  Future<void> finishBindPhone(
    Session session, {
    required UuidValue authUserId,
    required String bindToken,
    required String phone,
    Transaction? transaction,
  }) async {
    if (!config.enableBind) {
      throw SmsPhoneBindException(reason: SmsPhoneBindExceptionReason.invalid);
    }
    return DatabaseUtil.runInTransactionOrSavepoint(
      session.db,
      transaction,
      (transaction) async {
        final request = await utils.bind.completeBind(
          session,
          bindToken: bindToken,
          transaction: transaction,
        );

        if (request.authUserId != authUserId) {
          throw SmsPhoneBindException(
            reason: SmsPhoneBindExceptionReason.invalid,
          );
        }

        final normalized = config.phoneIdStore.normalizePhone(phone);
        final phoneHash = config.phoneIdStore.hashPhone(normalized);
        if (phoneHash != request.phoneHash) {
          throw SmsPhoneBindException(
            reason: SmsPhoneBindExceptionReason.invalid,
          );
        }

        try {
          await config.phoneIdStore.bindPhone(
            session,
            authUserId: authUserId,
            phone: normalized,
            allowRebind: config.allowPhoneRebind,
            transaction: transaction,
          );
        } on PhoneAlreadyBoundException {
          throw SmsPhoneBindException(
            reason: SmsPhoneBindExceptionReason.phoneAlreadyBound,
          );
        } on PhoneRebindNotAllowedException {
          throw SmsPhoneBindException(
            reason: SmsPhoneBindExceptionReason.phoneAlreadyBound,
          );
        }

        await SmsBindRequest.db.deleteRow(
          session,
          request,
          transaction: transaction,
        );

        await config.onAfterPhoneBound?.call(
          session,
          authUserId: authUserId,
          transaction: transaction,
        );
      },
    );
  }

  Future<bool> isPhoneBound(
    Session session, {
    required UuidValue authUserId,
    Transaction? transaction,
  }) async {
    return config.phoneIdStore.isPhoneBoundForUser(
      session,
      authUserId: authUserId,
      transaction: transaction,
    );
  }
}

extension SmsIdpGetter on AuthServices {
  SmsIdp get smsIdp => AuthServices.getIdentityProvider<SmsIdp>();
}
