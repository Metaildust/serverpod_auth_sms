import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import 'generated/protocol.dart';
import 'phone/phone_id_store.dart';
import 'phone/phone_match.dart';
import 'sms_idp_config.dart';
import 'sms_idp_utils.dart';

class SmsIdp {
  static const String method = 'sms';

  final SmsIdpConfig config;
  final SmsIdpUtils utils;
  final TokenManager _tokenManager;
  final AuthUsers _authUsers;
  final UserProfiles _userProfiles;
  final DatabaseRateLimitedRequestAttemptUtil<String> _passwordLoginRateLimiter;

  factory SmsIdp(
    SmsIdpConfig config, {
    required TokenManager tokenManager,
    required AuthUsers authUsers,
    required UserProfiles userProfiles,
  }) {
    final utils = SmsIdpUtils(config: config, authUsers: authUsers);
    final passwordLoginRateLimiter =
        DatabaseRateLimitedRequestAttemptUtil<String>(
          RateLimitedRequestAttemptConfig(
            domain: 'sms',
            source: 'password_login',
            maxAttempts: config.loginRequestRateLimit.maxAttempts,
            timeframe: config.loginRequestRateLimit.timeframe,
          ),
        );
    return SmsIdp._(
      config,
      utils,
      tokenManager,
      authUsers,
      userProfiles,
      passwordLoginRateLimiter,
    );
  }

  SmsIdp._(
    this.config,
    this.utils,
    this._tokenManager,
    this._authUsers,
    this._userProfiles,
    this._passwordLoginRateLimiter,
  );

  Future<AuthSuccess> finishBindPhoneV2(
    Session session, {
    required UuidValue authUserId,
    required String bindToken,
    required String phone,
    required SmsBindFinishDecision decision,
    UuidValue? expectedConflictOwnerAuthUserId,
    Transaction? transaction,
  }) async {
    if (!config.enableBind) {
      throw SmsPhoneBindException(reason: SmsPhoneBindExceptionReason.invalid);
    }

    return DatabaseUtil.runInTransactionOrSavepoint(session.db, transaction, (
      transaction,
    ) async {
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

      final stored = config.phoneIdStore.requestFingerprint(phone);
      if (stored != request.phoneHash) {
        throw SmsPhoneBindException(
          reason: SmsPhoneBindExceptionReason.invalid,
        );
      }

      final match = await config.phoneIdStore.matchPhone(
        session,
        phone: phone,
        transaction: transaction,
      );
      if (match.conflict) {
        throw SmsPhoneBindException(
          reason: SmsPhoneBindExceptionReason.phoneIdentityConflict,
        );
      }
      final conflictOwnerAuthUserId = match.userId;
      final rowHash = match.storedHash ?? '';
      final normalizedConflictOwnerAuthUserId = _normalizeConflictOwner(
        conflictOwnerAuthUserId: conflictOwnerAuthUserId,
        currentAuthUserId: authUserId,
      );

      if (normalizedConflictOwnerAuthUserId !=
          expectedConflictOwnerAuthUserId) {
        throw SmsPhoneBindException(
          reason: SmsPhoneBindExceptionReason.conflictStateChanged,
        );
      }

      final hasConflict = normalizedConflictOwnerAuthUserId != null;
      late final UuidValue tokenAuthUserId;
      if (hasConflict && decision == SmsBindFinishDecision.bindAndLogin) {
        final availability = await _resolveBindAndLoginAvailability(
          session,
          currentAuthUserId: authUserId,
          conflictAuthUserId: normalizedConflictOwnerAuthUserId,
          phoneHash: rowHash,
          transaction: transaction,
        );
        if (!availability.enabled) {
          throw SmsPhoneBindException(
            reason: SmsPhoneBindExceptionReason.bindAndLoginDisabled,
          );
        }

        final execution = await _executeBindAndLogin(
          session,
          currentAuthUserId: authUserId,
          conflictAuthUserId: normalizedConflictOwnerAuthUserId,
          phoneHash: rowHash,
          transaction: transaction,
        );
        tokenAuthUserId = execution.targetAuthUserId;
      } else {
        if (hasConflict) {
          await config.phoneIdStore.unbindPhoneByHash(
            session,
            authUserId: normalizedConflictOwnerAuthUserId,
            phoneHash: rowHash,
            transaction: transaction,
          );
        }
        try {
          await config.phoneIdStore.bindPhone(
            session,
            authUserId: authUserId,
            phone: phone,
            allowRebind: config.allowPhoneRebind,
            transaction: transaction,
          );
        } on PhoneAlreadyBoundException {
          throw SmsPhoneBindException(
            reason: SmsPhoneBindExceptionReason.conflictStateChanged,
          );
        } on PhoneRebindNotAllowedException {
          throw SmsPhoneBindException(
            reason: SmsPhoneBindExceptionReason.phoneAlreadyBound,
          );
        }
        await config.onAfterPhoneBound?.call(
          session,
          authUserId: authUserId,
          transaction: transaction,
        );
        tokenAuthUserId = authUserId;
      }

      await SmsBindRequest.db.deleteWhere(
        session,
        where: (t) => t.id.equals(request.id),
        transaction: transaction,
      );

      return _issueTokenForAuthUser(
        session,
        authUserId: tokenAuthUserId,
        transaction: transaction,
      );
    });
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
    return DatabaseUtil.runInTransactionOrSavepoint(session.db, transaction, (
      transaction,
    ) async {
      final request = await utils.login.completeLogin(
        session,
        loginToken: loginToken,
        transaction: transaction,
      );

      final canonical = config.phoneIdStore.canonicalPhone(phone);
      final stored = config.phoneIdStore.requestFingerprint(phone);
      if (canonical.isEmpty || stored != request.phoneHash) {
        throw SmsLoginException(reason: SmsLoginExceptionReason.invalid);
      }

      final match = await config.phoneIdStore.matchPhone(
        session,
        phone: phone,
        transaction: transaction,
      );
      if (match.conflict) {
        throw SmsLoginException(
          reason: SmsLoginExceptionReason.phoneIdentityConflict,
        );
      }
      final existingAuthUserId = match.userId;

      if (existingAuthUserId != null) {
        final authUser = await _authUsers.get(
          session,
          authUserId: existingAuthUserId,
          transaction: transaction,
        );
        // verifyLoginCode 已做过同样的查询来决定 needsPassword，
        // 但两次调用属于不同事务，此处必须重查以保证 finishLogin 自身判断准确。
        final smsAccount = await SmsAccount.db.findFirstRow(
          session,
          where: (t) => t.authUserId.equals(existingAuthUserId),
          transaction: transaction,
        );
        if (smsAccount == null && config.requirePasswordOnUnregisteredLogin) {
          if (password == null || password.isEmpty) {
            throw SmsLoginException(
              reason: SmsLoginExceptionReason.passwordRequired,
            );
          }
          if (!config.passwordValidationFunction(password)) {
            throw SmsLoginException(
              reason: SmsLoginExceptionReason.policyViolation,
            );
          }
          final passwordHash = await utils.hashUtil.createHashFromString(
            secret: password,
          );
          await SmsAccount.db.insertRow(
            session,
            SmsAccount(
              authUserId: existingAuthUserId,
              passwordHash: passwordHash,
            ),
            transaction: transaction,
          );
        }
        await SmsLoginRequest.db.deleteRow(
          session,
          request,
          transaction: transaction,
        );
        await _rewriteOnLogin(
          session,
          phone: phone,
          authUserId: existingAuthUserId,
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
        throw SmsLoginException(
          reason: SmsLoginExceptionReason.passwordRequired,
        );
      }

      if (!config.passwordValidationFunction(password ?? '')) {
        throw SmsLoginException(
          reason: SmsLoginExceptionReason.policyViolation,
        );
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
        SmsAccount(authUserId: authUser.id, passwordHash: passwordHash),
        transaction: transaction,
      );

      try {
        await config.phoneIdStore.bindPhone(
          session,
          authUserId: authUser.id,
          phone: phone,
          allowRebind: config.allowPhoneRebind,
          transaction: transaction,
        );
      } on PhoneIdentityConflictException {
        throw SmsLoginException(
          reason: SmsLoginExceptionReason.phoneIdentityConflict,
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
    });
  }

  Future<void> finishPasswordReset(
    Session session, {
    required String resetToken,
    required String phone,
    required String password,
    Transaction? transaction,
  }) async {
    if (!config.enableLogin) {
      throw SmsPasswordResetException(
        reason: SmsPasswordResetExceptionReason.invalid,
      );
    }
    if (!config.passwordValidationFunction(password)) {
      throw SmsPasswordResetException(
        reason: SmsPasswordResetExceptionReason.policyViolation,
      );
    }
    return DatabaseUtil.runInTransactionOrSavepoint(session.db, transaction, (
      transaction,
    ) async {
      final request = await utils.passwordReset.completePasswordReset(
        session,
        resetToken: resetToken,
        transaction: transaction,
      );
      final stored = config.phoneIdStore.requestFingerprint(phone);
      if (config.phoneIdStore.canonicalPhone(phone).isEmpty ||
          stored != request.phoneHash) {
        throw SmsPasswordResetException(
          reason: SmsPasswordResetExceptionReason.invalid,
        );
      }
      final authUserId = request.authUserId;
      if (authUserId == null || request.blockedReason != null) {
        throw SmsPasswordResetException(
          reason: SmsPasswordResetExceptionReason.invalid,
        );
      }
      final match = await config.phoneIdStore.matchPhone(
        session,
        phone: phone,
        transaction: transaction,
      );
      if (match.conflict) {
        throw SmsPasswordResetException(
          reason: SmsPasswordResetExceptionReason.phoneIdentityConflict,
        );
      }
      if (match.userId != authUserId) {
        throw SmsPasswordResetException(
          reason: SmsPasswordResetExceptionReason.invalid,
        );
      }
      final smsAccount = await SmsAccount.db.findFirstRow(
        session,
        where: (t) => t.authUserId.equals(authUserId),
        transaction: transaction,
      );
      if (smsAccount == null) {
        throw SmsPasswordResetException(
          reason: SmsPasswordResetExceptionReason.invalid,
        );
      }
      final samePassword = await utils.hashUtil.validateHashFromString(
        secret: password,
        hashString: smsAccount.passwordHash,
      );
      if (samePassword) {
        throw SmsPasswordResetException(
          reason: SmsPasswordResetExceptionReason.samePassword,
        );
      }
      final passwordHash = await utils.hashUtil.createHashFromString(
        secret: password,
      );
      await SmsAccount.db.updateRow(
        session,
        smsAccount.copyWith(passwordHash: passwordHash),
        transaction: transaction,
      );
      await SmsPasswordResetRequest.db.deleteRow(
        session,
        request,
        transaction: transaction,
      );
      // 改密后该号码未用完的登录码作废：哈希交集删请求，并显式删挑战。
      await utils.login.dropLoginRequestsMatchingPhone(
        session,
        phone: phone,
        transaction: transaction,
      );
      // 同一事务内只作废 [SmsIdp.method] 令牌。这次调用失败会连密码修改一起回滚。
      await _tokenManager.revokeAllTokens(
        session,
        authUserId: authUserId,
        method: SmsIdp.method,
        transaction: transaction,
      );
    });
  }

  Future<AuthSuccess> finishRegistration(
    Session session, {
    required String registrationToken,
    required String phone,
    required String password,
    Transaction? transaction,
  }) async {
    return DatabaseUtil.runInTransactionOrSavepoint(session.db, transaction, (
      transaction,
    ) async {
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
    });
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

  Future<AuthSuccess> loginWithPassword(
    Session session, {
    required String phone,
    required String password,
    Transaction? transaction,
  }) async {
    if (!config.enableLogin) {
      throw SmsLoginException(reason: SmsLoginExceptionReason.invalid);
    }

    final canonical = config.phoneIdStore.canonicalPhone(phone);
    if (canonical.isEmpty) {
      throw SmsLoginException(reason: SmsLoginExceptionReason.invalid);
    }
    final legacyNonce = config.phoneIdStore.hashLegacyPhone(phone);

    if (await _passwordLoginRateLimiter.hasTooManyAttempts(
      session,
      nonce: legacyNonce,
    )) {
      throw SmsLoginException(reason: SmsLoginExceptionReason.tooManyAttempts);
    }

    return DatabaseUtil.runInTransactionOrSavepoint(session.db, transaction, (
      transaction,
    ) async {
      final match = await config.phoneIdStore.matchPhone(
        session,
        phone: phone,
        transaction: transaction,
      );
      if (match.conflict) {
        throw SmsLoginException(
          reason: SmsLoginExceptionReason.phoneIdentityConflict,
        );
      }
      final authUserId = match.userId;
      if (authUserId == null) {
        throw SmsLoginException(reason: SmsLoginExceptionReason.invalid);
      }

      final smsAccount = await SmsAccount.db.findFirstRow(
        session,
        where: (t) => t.authUserId.equals(authUserId),
        transaction: transaction,
      );
      if (smsAccount == null) {
        throw SmsLoginException(reason: SmsLoginExceptionReason.invalid);
      }

      final passwordValid = await utils.hashUtil.validateHashFromString(
        secret: password,
        hashString: smsAccount.passwordHash,
      );
      if (!passwordValid) {
        throw SmsLoginException(reason: SmsLoginExceptionReason.invalid);
      }

      final authUser = await _authUsers.get(
        session,
        authUserId: authUserId,
        transaction: transaction,
      );
      await _rewriteOnLogin(
        session,
        phone: phone,
        authUserId: authUserId,
        transaction: transaction,
      );

      return _tokenManager.issueToken(
        session,
        authUserId: authUser.id,
        method: method,
        scopes: authUser.scopes,
        transaction: transaction,
      );
    });
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
    return utils.bind.startBind(
      session,
      authUserId: authUserId,
      phone: phone,
      transaction: transaction,
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
    return utils.login.startLogin(
      session,
      phone: phone,
      transaction: transaction,
    );
  }

  Future<UuidValue> startPasswordReset(
    Session session, {
    required String phone,
    Transaction? transaction,
  }) async {
    if (!config.enableLogin) {
      throw SmsPasswordResetException(
        reason: SmsPasswordResetExceptionReason.invalid,
      );
    }
    return utils.passwordReset.startPasswordReset(
      session,
      phone: phone,
      transaction: transaction,
    );
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
  }

  Future<SmsVerifyPasswordResetResult> verifyPasswordResetCode(
    Session session, {
    required UuidValue resetRequestId,
    required String verificationCode,
    Transaction? transaction,
  }) async {
    if (!config.enableLogin) {
      throw SmsPasswordResetException(
        reason: SmsPasswordResetExceptionReason.invalid,
      );
    }
    return DatabaseUtil.runInTransactionOrSavepoint(
      session.db,
      transaction,
      (transaction) => utils.passwordReset.verifyPasswordResetCode(
        session,
        resetRequestId: resetRequestId,
        verificationCode: verificationCode,
        transaction: transaction,
      ),
    );
  }

  Future<SmsVerifyBindResultV2> verifyBindCodeV2(
    Session session, {
    required UuidValue authUserId,
    required UuidValue bindRequestId,
    required String verificationCode,
    Transaction? transaction,
  }) async {
    return DatabaseUtil.runInTransactionOrSavepoint(session.db, transaction, (
      transaction,
    ) async {
      final bindToken = await utils.bind.verifyBindCode(
        session,
        bindRequestId: bindRequestId,
        verificationCode: verificationCode,
        transaction: transaction,
      );
      final request = await SmsBindRequest.db.findById(
        session,
        bindRequestId,
        transaction: transaction,
      );
      if (request == null || request.authUserId != authUserId) {
        throw SmsPhoneBindException(
          reason: SmsPhoneBindExceptionReason.invalid,
        );
      }

      final hashes = config.phoneIdStore.hashesOfFingerprint(request.phoneHash);
      final match = await config.phoneIdStore.matchHashes(
        session,
        hashes: hashes,
        legacyHash: hashes.length > 1 ? hashes[1] : hashes.first,
        canonicalHash: hashes.first,
        transaction: transaction,
      );
      if (match.conflict) {
        throw SmsPhoneBindException(
          reason: SmsPhoneBindExceptionReason.phoneIdentityConflict,
        );
      }
      final normalizedConflictOwnerAuthUserId = _normalizeConflictOwner(
        conflictOwnerAuthUserId: match.userId,
        currentAuthUserId: authUserId,
      );
      final hasConflict = normalizedConflictOwnerAuthUserId != null;
      final rowHash = match.storedHash ?? '';

      SmsBindAndLoginAvailability availability =
          const SmsBindAndLoginAvailability.enabled();
      if (hasConflict) {
        availability = await _resolveBindAndLoginAvailability(
          session,
          currentAuthUserId: authUserId,
          conflictAuthUserId: normalizedConflictOwnerAuthUserId,
          phoneHash: rowHash,
          transaction: transaction,
        );
      }

      return SmsVerifyBindResultV2(
        bindToken: bindToken,
        hasConflict: hasConflict,
        expectedConflictOwnerAuthUserId: normalizedConflictOwnerAuthUserId,
        bindAndLoginEnabled: hasConflict && availability.enabled,
        bindAndLoginDisabledReason: availability.enabled
            ? null
            : availability.disabledReason,
      );
    });
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
      (transaction) => utils.login.verifyLoginCode(
        session,
        loginRequestId: loginRequestId,
        verificationCode: verificationCode,
        transaction: transaction,
      ),
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
      (transaction) => utils.accountCreation.verifyRegistrationCode(
        session,
        accountRequestId: accountRequestId,
        verificationCode: verificationCode,
        transaction: transaction,
      ),
    );
  }

  Future<void> _rewriteOnLogin(
    Session session, {
    required String phone,
    required UuidValue authUserId,
    required Transaction transaction,
  }) async {
    try {
      await config.phoneIdStore.rewriteMatchedPhoneToCanonical(
        session,
        phone: phone,
        authUserId: authUserId,
        transaction: transaction,
      );
    } on PhoneIdentityConflictException {
      throw SmsLoginException(
        reason: SmsLoginExceptionReason.phoneIdentityConflict,
      );
    }
  }

  Future<SmsBindAndLoginExecutionResult> _executeBindAndLogin(
    Session session, {
    required UuidValue currentAuthUserId,
    required UuidValue conflictAuthUserId,
    required String phoneHash,
    required Transaction transaction,
  }) async {
    final executor = config.executeBindAndLogin;
    if (executor == null) {
      return SmsBindAndLoginExecutionResult(
        targetAuthUserId: conflictAuthUserId,
      );
    }
    return executor(
      session,
      currentAuthUserId: currentAuthUserId,
      conflictAuthUserId: conflictAuthUserId,
      phoneHash: phoneHash,
      transaction: transaction,
    );
  }

  Future<AuthSuccess> _issueTokenForAuthUser(
    Session session, {
    required UuidValue authUserId,
    required Transaction transaction,
  }) async {
    final authUser = await _authUsers.get(
      session,
      authUserId: authUserId,
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

  UuidValue? _normalizeConflictOwner({
    required UuidValue? conflictOwnerAuthUserId,
    required UuidValue currentAuthUserId,
  }) {
    if (conflictOwnerAuthUserId == null) return null;
    if (conflictOwnerAuthUserId == currentAuthUserId) return null;
    return conflictOwnerAuthUserId;
  }

  Future<SmsBindAndLoginAvailability> _resolveBindAndLoginAvailability(
    Session session, {
    required UuidValue currentAuthUserId,
    required UuidValue conflictAuthUserId,
    required String phoneHash,
    required Transaction transaction,
  }) async {
    final resolver = config.resolveBindAndLoginAvailability;
    if (resolver == null) {
      return const SmsBindAndLoginAvailability.enabled();
    }
    return resolver(
      session,
      currentAuthUserId: currentAuthUserId,
      conflictAuthUserId: conflictAuthUserId,
      phoneHash: phoneHash,
      transaction: transaction,
    );
  }
}

extension SmsIdpGetter on AuthServices {
  SmsIdp get smsIdp => AuthServices.getIdentityProvider<SmsIdp>();
}
