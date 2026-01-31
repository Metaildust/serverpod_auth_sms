import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import 'generated/protocol.dart';
import 'phone/phone_id_store.dart';
import 'sms_idp_config.dart';

class SmsAccountAlreadyRegisteredException implements Exception {}

class SmsIdpUtils {
  final Argon2HashUtil hashUtil;
  final SmsIdpAccountCreationUtil accountCreation;
  final SmsIdpLoginUtil login;
  final SmsIdpBindUtil bind;

  SmsIdpUtils({required SmsIdpConfig config, required AuthUsers authUsers})
    : hashUtil = Argon2HashUtil(
        hashPepper: config.secretHashPepper,
        fallbackHashPeppers: config.fallbackSecretHashPeppers,
        hashSaltLength: config.secretHashSaltLength,
        parameters: Argon2HashParameters(memory: 19456),
      ),
      accountCreation = SmsIdpAccountCreationUtil(
        config: config,
        authUsers: authUsers,
      ),
      login = SmsIdpLoginUtil(config: config),
      bind = SmsIdpBindUtil(config: config);

  static Future<T> withReplacedAccountRequestException<T>(
    Future<T> Function() fn,
  ) async {
    try {
      return await fn();
    } on ChallengeExpiredException {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.expired,
      );
    } on ChallengeRateLimitExceededException {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.tooManyAttempts,
      );
    } on ChallengeInvalidCompletionTokenException catch (_) {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.invalid,
      );
    } on ChallengeInvalidVerificationCodeException catch (_) {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.invalid,
      );
    } on ChallengeNotVerifiedException {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.invalid,
      );
    } on ChallengeRequestNotFoundException {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.invalid,
      );
    } on ChallengeAlreadyUsedException {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.invalid,
      );
    }
  }

  static Future<T> withReplacedLoginException<T>(
    Future<T> Function() fn,
  ) async {
    try {
      return await fn();
    } on ChallengeExpiredException {
      throw SmsLoginException(reason: SmsLoginExceptionReason.expired);
    } on ChallengeRateLimitExceededException {
      throw SmsLoginException(reason: SmsLoginExceptionReason.tooManyAttempts);
    } on ChallengeInvalidCompletionTokenException catch (_) {
      throw SmsLoginException(reason: SmsLoginExceptionReason.invalid);
    } on ChallengeInvalidVerificationCodeException catch (_) {
      throw SmsLoginException(reason: SmsLoginExceptionReason.invalid);
    } on ChallengeNotVerifiedException {
      throw SmsLoginException(reason: SmsLoginExceptionReason.invalid);
    } on ChallengeRequestNotFoundException {
      throw SmsLoginException(reason: SmsLoginExceptionReason.invalid);
    } on ChallengeAlreadyUsedException {
      throw SmsLoginException(reason: SmsLoginExceptionReason.invalid);
    }
  }

  static Future<T> withReplacedBindException<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on ChallengeExpiredException {
      throw SmsPhoneBindException(reason: SmsPhoneBindExceptionReason.expired);
    } on ChallengeRateLimitExceededException {
      throw SmsPhoneBindException(
        reason: SmsPhoneBindExceptionReason.tooManyAttempts,
      );
    } on ChallengeInvalidCompletionTokenException catch (_) {
      throw SmsPhoneBindException(reason: SmsPhoneBindExceptionReason.invalid);
    } on ChallengeInvalidVerificationCodeException catch (_) {
      throw SmsPhoneBindException(reason: SmsPhoneBindExceptionReason.invalid);
    } on ChallengeNotVerifiedException {
      throw SmsPhoneBindException(reason: SmsPhoneBindExceptionReason.invalid);
    } on ChallengeRequestNotFoundException {
      throw SmsPhoneBindException(reason: SmsPhoneBindExceptionReason.invalid);
    } on ChallengeAlreadyUsedException {
      throw SmsPhoneBindException(reason: SmsPhoneBindExceptionReason.invalid);
    }
  }
}

class SmsIdpAccountCreationUtil {
  final SmsIdpConfig _config;
  final AuthUsers _authUsers;
  final Argon2HashUtil _hashUtil;
  late final SecretChallengeUtil<SmsAccountRequest> _challengeUtil;
  late final DatabaseRateLimitedRequestAttemptUtil<String> _requestRateLimiter;

  SmsIdpAccountCreationUtil({
    required SmsIdpConfig config,
    required AuthUsers authUsers,
  }) : _config = config,
       _authUsers = authUsers,
       _hashUtil = Argon2HashUtil(
         hashPepper: config.secretHashPepper,
         fallbackHashPeppers: config.fallbackSecretHashPeppers,
         hashSaltLength: config.secretHashSaltLength,
         parameters: Argon2HashParameters(memory: 19456),
       ) {
    _challengeUtil = SecretChallengeUtil(
      hashUtil: _hashUtil,
      verificationConfig: _buildVerificationConfig(),
      completionConfig: _buildCompletionConfig(),
    );
    _requestRateLimiter = DatabaseRateLimitedRequestAttemptUtil(
      RateLimitedRequestAttemptConfig(
        domain: 'sms',
        source: 'registration_request',
        maxAttempts: _config.registrationRequestRateLimit.maxAttempts,
        timeframe: _config.registrationRequestRateLimit.timeframe,
      ),
    );
  }

  Future<UuidValue> startRegistration(
    Session session, {
    required String phone,
    required Transaction transaction,
  }) async {
    final normalized = _config.phoneIdStore.normalizePhone(phone);
    if (normalized.isEmpty) {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.invalid,
      );
    }
    final phoneHash = _config.phoneIdStore.hashPhone(normalized);

    if (await _requestRateLimiter.hasTooManyAttempts(
      session,
      nonce: phoneHash,
    )) {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.tooManyAttempts,
      );
    }

    final existingAccount = await _config.phoneIdStore
        .findAuthUserIdByPhoneHash(
          session,
          phoneHash: phoneHash,
          transaction: transaction,
        );
    if (existingAccount != null) {
      throw SmsAccountAlreadyRegisteredException();
    }

    await _requestRateLimiter.recordAttempt(session, nonce: phoneHash);

    final existingRequest = await SmsAccountRequest.db.findFirstRow(
      session,
      where: (t) => t.phoneHash.equals(phoneHash),
      transaction: transaction,
    );
    if (existingRequest != null) {
      await SmsAccountRequest.db.deleteRow(
        session,
        existingRequest,
        transaction: transaction,
      );
    }

    final verificationCode = _config.registrationVerificationCodeGenerator();
    final challenge = await _challengeUtil.createChallenge(
      session,
      verificationCode: verificationCode,
      transaction: transaction,
    );

    final request = await SmsAccountRequest.db.insertRow(
      session,
      SmsAccountRequest(phoneHash: phoneHash, challengeId: challenge.id!),
      transaction: transaction,
    );

    await _config.sendRegistrationVerificationCode?.call(
      session,
      phone: normalized,
      requestId: request.id!,
      verificationCode: verificationCode,
      transaction: transaction,
    );

    return request.id!;
  }

  Future<String> verifyRegistrationCode(
    Session session, {
    required UuidValue accountRequestId,
    required String verificationCode,
    required Transaction transaction,
  }) async {
    return SmsIdpUtils.withReplacedAccountRequestException(
      () => _challengeUtil.verifyChallenge(
        session,
        requestId: accountRequestId,
        verificationCode: verificationCode,
        transaction: transaction,
      ),
    );
  }

  Future<SmsAccountCreationResult> completeAccountCreation(
    Session session, {
    required String registrationToken,
    required String phone,
    required String password,
    required Transaction transaction,
  }) async {
    if (!_config.passwordValidationFunction(password)) {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.policyViolation,
      );
    }

    final request = await SmsIdpUtils.withReplacedAccountRequestException(
      () => _challengeUtil.completeChallenge(
        session,
        completionToken: registrationToken,
        transaction: transaction,
      ),
    );

    final normalized = _config.phoneIdStore.normalizePhone(phone);
    final phoneHash = _config.phoneIdStore.hashPhone(normalized);
    if (phoneHash != request.phoneHash) {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.invalid,
      );
    }

    await SmsAccountRequest.db.deleteRow(
      session,
      request,
      transaction: transaction,
    );

    final authUser = await _authUsers.create(session, transaction: transaction);

    final passwordHash = await _hashUtil.createHashFromString(secret: password);
    await SmsAccount.db.insertRow(
      session,
      SmsAccount(authUserId: authUser.id, passwordHash: passwordHash),
      transaction: transaction,
    );

    try {
      await _config.phoneIdStore.bindPhone(
        session,
        authUserId: authUser.id,
        phone: normalized,
        allowRebind: false,
        transaction: transaction,
      );
    } on PhoneAlreadyBoundException {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.invalid,
      );
    } on PhoneRebindNotAllowedException {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.invalid,
      );
    }

    await _config.onAfterAccountCreated?.call(
      session,
      authUserId: authUser.id,
      transaction: transaction,
    );
    await _config.onAfterPhoneBound?.call(
      session,
      authUserId: authUser.id,
      transaction: transaction,
    );

    return SmsAccountCreationResult(
      authUserId: authUser.id,
      scopes: authUser.scopes,
    );
  }

  SecretChallengeVerificationConfig<SmsAccountRequest>
  _buildVerificationConfig() {
    final limiter = DatabaseRateLimitedRequestAttemptUtil<UuidValue>(
      RateLimitedRequestAttemptConfig(
        domain: 'sms',
        source: 'registration_verify',
        maxAttempts: _config.registrationVerificationCodeAllowedAttempts,
        timeframe: _config.registrationVerificationCodeLifetime,
      ),
    );

    return SecretChallengeVerificationConfig(
      getRequest: (session, requestId, {required transaction}) async {
        return SmsAccountRequest.db.findById(
          session,
          requestId,
          transaction: transaction,
          include: SmsAccountRequest.include(
            challenge: SecretChallenge.include(),
          ),
        );
      },
      isAlreadyUsed: (request) => request.createAccountChallengeId != null,
      getChallenge: (request) => request.challenge!,
      isExpired: (request) => request.createdAt
          .add(_config.registrationVerificationCodeLifetime)
          .isBefore(DateTime.now()),
      onExpired: (session, request) async {
        await SmsAccountRequest.db.deleteRow(session, request);
      },
      linkCompletionToken:
          (
            session,
            request,
            completionChallenge, {
            required transaction,
          }) async {
            if (request.createAccountChallengeId != null) {
              throw ChallengeAlreadyUsedException();
            }
            await SmsAccountRequest.db.updateRow(
              session,
              request.copyWith(
                createAccountChallengeId: completionChallenge.id,
              ),
              transaction: transaction,
            );
          },
      rateLimiter: limiter,
    );
  }

  SecretChallengeCompletionConfig<SmsAccountRequest> _buildCompletionConfig() {
    final limiter = DatabaseRateLimitedRequestAttemptUtil<UuidValue>(
      RateLimitedRequestAttemptConfig(
        domain: 'sms',
        source: 'registration_complete',
        maxAttempts: _config.registrationVerificationCodeAllowedAttempts,
        timeframe: _config.registrationVerificationCodeLifetime,
      ),
    );
    return SecretChallengeCompletionConfig(
      getRequest: (session, requestId, {required transaction}) async {
        return SmsAccountRequest.db.findById(
          session,
          requestId,
          transaction: transaction,
          include: SmsAccountRequest.include(
            createAccountChallenge: SecretChallenge.include(),
          ),
        );
      },
      getCompletionChallenge: (request) => request.createAccountChallenge,
      isExpired: (request) => request.createdAt
          .add(_config.registrationVerificationCodeLifetime)
          .isBefore(DateTime.now()),
      onExpired: (session, request) async {
        await SmsAccountRequest.db.deleteRow(session, request);
      },
      rateLimiter: limiter,
    );
  }
}

class SmsIdpLoginUtil {
  final SmsIdpConfig _config;
  final Argon2HashUtil _hashUtil;
  late final SecretChallengeUtil<SmsLoginRequest> _challengeUtil;
  late final DatabaseRateLimitedRequestAttemptUtil<String> _requestRateLimiter;

  SmsIdpLoginUtil({required SmsIdpConfig config})
    : _config = config,
      _hashUtil = Argon2HashUtil(
        hashPepper: config.secretHashPepper,
        fallbackHashPeppers: config.fallbackSecretHashPeppers,
        hashSaltLength: config.secretHashSaltLength,
        parameters: Argon2HashParameters(memory: 19456),
      ) {
    _challengeUtil = SecretChallengeUtil(
      hashUtil: _hashUtil,
      verificationConfig: _buildVerificationConfig(),
      completionConfig: _buildCompletionConfig(),
    );
    _requestRateLimiter = DatabaseRateLimitedRequestAttemptUtil(
      RateLimitedRequestAttemptConfig(
        domain: 'sms',
        source: 'login_request',
        maxAttempts: _config.loginRequestRateLimit.maxAttempts,
        timeframe: _config.loginRequestRateLimit.timeframe,
      ),
    );
  }

  Future<UuidValue> startLogin(
    Session session, {
    required String phone,
    required Transaction transaction,
  }) async {
    final normalized = _config.phoneIdStore.normalizePhone(phone);
    if (normalized.isEmpty) {
      throw SmsLoginException(reason: SmsLoginExceptionReason.invalid);
    }
    final phoneHash = _config.phoneIdStore.hashPhone(normalized);

    if (await _requestRateLimiter.hasTooManyAttempts(
      session,
      nonce: phoneHash,
    )) {
      throw SmsLoginException(reason: SmsLoginExceptionReason.tooManyAttempts);
    }

    await _requestRateLimiter.recordAttempt(session, nonce: phoneHash);

    final existingRequest = await SmsLoginRequest.db.findFirstRow(
      session,
      where: (t) => t.phoneHash.equals(phoneHash),
      transaction: transaction,
    );
    if (existingRequest != null) {
      await SmsLoginRequest.db.deleteRow(
        session,
        existingRequest,
        transaction: transaction,
      );
    }

    final verificationCode = _config.loginVerificationCodeGenerator();
    final challenge = await _challengeUtil.createChallenge(
      session,
      verificationCode: verificationCode,
      transaction: transaction,
    );

    final request = await SmsLoginRequest.db.insertRow(
      session,
      SmsLoginRequest(phoneHash: phoneHash, challengeId: challenge.id!),
      transaction: transaction,
    );

    await _config.sendLoginVerificationCode?.call(
      session,
      phone: normalized,
      requestId: request.id!,
      verificationCode: verificationCode,
      transaction: transaction,
    );

    return request.id!;
  }

  Future<SmsVerifyLoginResult> verifyLoginCode(
    Session session, {
    required UuidValue loginRequestId,
    required String verificationCode,
    required Transaction transaction,
  }) async {
    final token = await SmsIdpUtils.withReplacedLoginException(
      () => _challengeUtil.verifyChallenge(
        session,
        requestId: loginRequestId,
        verificationCode: verificationCode,
        transaction: transaction,
      ),
    );

    // 检查是否需要密码（新用户自动注册时）
    bool needsPassword = false;
    if (_config.requirePasswordOnUnregisteredLogin) {
      // 获取 request 来查找手机号哈希
      final request = await SmsLoginRequest.db.findById(
        session,
        loginRequestId,
        transaction: transaction,
      );
      if (request != null) {
        // 通过手机号哈希查找是否有已存在的账户
        final existingAuthUserId = await _config.phoneIdStore.findAuthUserIdByPhoneHash(
          session,
          phoneHash: request.phoneHash,
          transaction: transaction,
        );
        needsPassword = existingAuthUserId == null;
      }
    }

    return SmsVerifyLoginResult(token: token, needsPassword: needsPassword);
  }

  Future<SmsLoginRequest> completeLogin(
    Session session, {
    required String loginToken,
    required Transaction transaction,
  }) async {
    return SmsIdpUtils.withReplacedLoginException(
      () => _challengeUtil.completeChallenge(
        session,
        completionToken: loginToken,
        transaction: transaction,
      ),
    );
  }

  SecretChallengeVerificationConfig<SmsLoginRequest>
  _buildVerificationConfig() {
    final limiter = DatabaseRateLimitedRequestAttemptUtil<UuidValue>(
      RateLimitedRequestAttemptConfig(
        domain: 'sms',
        source: 'login_verify',
        maxAttempts: _config.loginVerificationCodeAllowedAttempts,
        timeframe: _config.loginVerificationCodeLifetime,
      ),
    );

    return SecretChallengeVerificationConfig(
      getRequest: (session, requestId, {required transaction}) async {
        return SmsLoginRequest.db.findById(
          session,
          requestId,
          transaction: transaction,
          include: SmsLoginRequest.include(
            challenge: SecretChallenge.include(),
          ),
        );
      },
      isAlreadyUsed: (request) => request.loginChallengeId != null,
      getChallenge: (request) => request.challenge!,
      isExpired: (request) => request.createdAt
          .add(_config.loginVerificationCodeLifetime)
          .isBefore(DateTime.now()),
      onExpired: (session, request) async {
        await SmsLoginRequest.db.deleteRow(session, request);
      },
      linkCompletionToken:
          (
            session,
            request,
            completionChallenge, {
            required transaction,
          }) async {
            if (request.loginChallengeId != null) {
              throw ChallengeAlreadyUsedException();
            }
            await SmsLoginRequest.db.updateRow(
              session,
              request.copyWith(loginChallengeId: completionChallenge.id),
              transaction: transaction,
            );
          },
      rateLimiter: limiter,
    );
  }

  SecretChallengeCompletionConfig<SmsLoginRequest> _buildCompletionConfig() {
    final limiter = DatabaseRateLimitedRequestAttemptUtil<UuidValue>(
      RateLimitedRequestAttemptConfig(
        domain: 'sms',
        source: 'login_complete',
        maxAttempts: _config.loginVerificationCodeAllowedAttempts,
        timeframe: _config.loginVerificationCodeLifetime,
      ),
    );
    return SecretChallengeCompletionConfig(
      getRequest: (session, requestId, {required transaction}) async {
        return SmsLoginRequest.db.findById(
          session,
          requestId,
          transaction: transaction,
          include: SmsLoginRequest.include(
            loginChallenge: SecretChallenge.include(),
          ),
        );
      },
      getCompletionChallenge: (request) => request.loginChallenge,
      isExpired: (request) => request.createdAt
          .add(_config.loginVerificationCodeLifetime)
          .isBefore(DateTime.now()),
      onExpired: (session, request) async {
        await SmsLoginRequest.db.deleteRow(session, request);
      },
      rateLimiter: limiter,
    );
  }
}

class SmsIdpBindUtil {
  final SmsIdpConfig _config;
  final Argon2HashUtil _hashUtil;
  late final SecretChallengeUtil<SmsBindRequest> _challengeUtil;
  late final DatabaseRateLimitedRequestAttemptUtil<String> _requestRateLimiter;

  SmsIdpBindUtil({required SmsIdpConfig config})
    : _config = config,
      _hashUtil = Argon2HashUtil(
        hashPepper: config.secretHashPepper,
        fallbackHashPeppers: config.fallbackSecretHashPeppers,
        hashSaltLength: config.secretHashSaltLength,
        parameters: Argon2HashParameters(memory: 19456),
      ) {
    _challengeUtil = SecretChallengeUtil(
      hashUtil: _hashUtil,
      verificationConfig: _buildVerificationConfig(),
      completionConfig: _buildCompletionConfig(),
    );
    _requestRateLimiter = DatabaseRateLimitedRequestAttemptUtil(
      RateLimitedRequestAttemptConfig(
        domain: 'sms',
        source: 'bind_request',
        maxAttempts: _config.bindRequestRateLimit.maxAttempts,
        timeframe: _config.bindRequestRateLimit.timeframe,
      ),
    );
  }

  Future<UuidValue> startBind(
    Session session, {
    required UuidValue authUserId,
    required String phone,
    required Transaction transaction,
  }) async {
    final normalized = _config.phoneIdStore.normalizePhone(phone);
    if (normalized.isEmpty) {
      throw SmsPhoneBindException(reason: SmsPhoneBindExceptionReason.invalid);
    }
    final phoneHash = _config.phoneIdStore.hashPhone(normalized);
    final nonce = '$authUserId:$phoneHash';

    if (await _requestRateLimiter.hasTooManyAttempts(session, nonce: nonce)) {
      throw SmsPhoneBindException(
        reason: SmsPhoneBindExceptionReason.tooManyAttempts,
      );
    }
    await _requestRateLimiter.recordAttempt(session, nonce: nonce);

    final existing = await SmsBindRequest.db.findFirstRow(
      session,
      where: (t) =>
          t.authUserId.equals(authUserId) & t.phoneHash.equals(phoneHash),
      transaction: transaction,
    );
    if (existing != null) {
      await SmsBindRequest.db.deleteRow(
        session,
        existing,
        transaction: transaction,
      );
    }

    final verificationCode = _config.bindVerificationCodeGenerator();
    final challenge = await _challengeUtil.createChallenge(
      session,
      verificationCode: verificationCode,
      transaction: transaction,
    );

    final request = await SmsBindRequest.db.insertRow(
      session,
      SmsBindRequest(
        authUserId: authUserId,
        phoneHash: phoneHash,
        challengeId: challenge.id!,
      ),
      transaction: transaction,
    );

    await _config.sendBindVerificationCode?.call(
      session,
      phone: normalized,
      requestId: request.id!,
      verificationCode: verificationCode,
      transaction: transaction,
    );

    return request.id!;
  }

  Future<String> verifyBindCode(
    Session session, {
    required UuidValue bindRequestId,
    required String verificationCode,
    required Transaction transaction,
  }) async {
    return SmsIdpUtils.withReplacedBindException(
      () => _challengeUtil.verifyChallenge(
        session,
        requestId: bindRequestId,
        verificationCode: verificationCode,
        transaction: transaction,
      ),
    );
  }

  Future<SmsBindRequest> completeBind(
    Session session, {
    required String bindToken,
    required Transaction transaction,
  }) async {
    return SmsIdpUtils.withReplacedBindException(
      () => _challengeUtil.completeChallenge(
        session,
        completionToken: bindToken,
        transaction: transaction,
      ),
    );
  }

  SecretChallengeVerificationConfig<SmsBindRequest> _buildVerificationConfig() {
    final limiter = DatabaseRateLimitedRequestAttemptUtil<UuidValue>(
      RateLimitedRequestAttemptConfig(
        domain: 'sms',
        source: 'bind_verify',
        maxAttempts: _config.bindVerificationCodeAllowedAttempts,
        timeframe: _config.bindVerificationCodeLifetime,
      ),
    );

    return SecretChallengeVerificationConfig(
      getRequest: (session, requestId, {required transaction}) async {
        return SmsBindRequest.db.findById(
          session,
          requestId,
          transaction: transaction,
          include: SmsBindRequest.include(challenge: SecretChallenge.include()),
        );
      },
      isAlreadyUsed: (request) => request.bindChallengeId != null,
      getChallenge: (request) => request.challenge!,
      isExpired: (request) => request.createdAt
          .add(_config.bindVerificationCodeLifetime)
          .isBefore(DateTime.now()),
      onExpired: (session, request) async {
        await SmsBindRequest.db.deleteRow(session, request);
      },
      linkCompletionToken:
          (
            session,
            request,
            completionChallenge, {
            required transaction,
          }) async {
            if (request.bindChallengeId != null) {
              throw ChallengeAlreadyUsedException();
            }
            await SmsBindRequest.db.updateRow(
              session,
              request.copyWith(bindChallengeId: completionChallenge.id),
              transaction: transaction,
            );
          },
      rateLimiter: limiter,
    );
  }

  SecretChallengeCompletionConfig<SmsBindRequest> _buildCompletionConfig() {
    final limiter = DatabaseRateLimitedRequestAttemptUtil<UuidValue>(
      RateLimitedRequestAttemptConfig(
        domain: 'sms',
        source: 'bind_complete',
        maxAttempts: _config.bindVerificationCodeAllowedAttempts,
        timeframe: _config.bindVerificationCodeLifetime,
      ),
    );

    return SecretChallengeCompletionConfig(
      getRequest: (session, requestId, {required transaction}) async {
        return SmsBindRequest.db.findById(
          session,
          requestId,
          transaction: transaction,
          include: SmsBindRequest.include(
            bindChallenge: SecretChallenge.include(),
          ),
        );
      },
      getCompletionChallenge: (request) => request.bindChallenge,
      isExpired: (request) => request.createdAt
          .add(_config.bindVerificationCodeLifetime)
          .isBefore(DateTime.now()),
      onExpired: (session, request) async {
        await SmsBindRequest.db.deleteRow(session, request);
      },
      rateLimiter: limiter,
    );
  }
}

class SmsAccountCreationResult {
  final UuidValue authUserId;
  final Set<Scope> scopes;

  SmsAccountCreationResult({required this.authUserId, required this.scopes});
}
