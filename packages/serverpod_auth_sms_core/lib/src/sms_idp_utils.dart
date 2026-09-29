import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import 'generated/protocol.dart';
import 'phone/phone_id_store.dart';
import 'phone/phone_match.dart';
import 'sms_idp_config.dart';

/// 登录发码来源桶。号码桶仍是 login_request。
const String smsLoginRequestSource = 'login_source';

/// 注册发码来源桶。号码桶仍是 registration_request。
const String smsRegistrationRequestSource = 'registration_source';

/// 绑定发码来源桶。号码桶仍是 bind_request。
const String smsBindRequestSource = 'bind_source';

/// 重置发码来源桶。号码桶仍是 password_reset_request。
const String smsPasswordResetRequestSource = 'password_reset_source';

/// SMS 模块 Argon2 内存成本（KiB）。告白值与上游 email IdP 对齐。
const int smsIdpArgon2Memory = 19456;

/// 各入口共用的 Argon2 工具构造；memory 固定接 [smsIdpArgon2Memory]。
Argon2HashUtil createSmsIdpArgon2HashUtil({
  required String hashPepper,
  List<String> fallbackHashPeppers = const [],
  required int hashSaltLength,
}) {
  return Argon2HashUtil(
    hashPepper: hashPepper,
    fallbackHashPeppers: fallbackHashPeppers,
    hashSaltLength: hashSaltLength,
    parameters: Argon2HashParameters(memory: smsIdpArgon2Memory),
  );
}

/// 空串、空白和字面量 null 都不当来源键，避免所有请求挤进同一个公共桶。
String? usableLoginSourceKey(String? raw) {
  if (raw == null) {
    return null;
  }
  final trimmed = raw.trim();
  if (trimmed.isEmpty || trimmed == 'null') {
    return null;
  }
  return trimmed;
}

/// 登录请求 [phoneHash] 是否与本次号码的 {legacy,canonical} 哈希集合命中。
///
/// 不得只比「整串 fingerprint 相等」：横杠发码、纯数字改密时整串不同，
/// 但仍须按 [hashesFromPhoneFingerprint] 与目标集合的交集删除。
bool smsLoginRequestMatchesPhoneHashes({
  required String phoneHash,
  required String legacyHash,
  required String canonicalHash,
}) {
  final target = <String>{legacyHash, canonicalHash};
  final fingerprint = phoneRequestFingerprint(
    legacyHash: legacyHash,
    canonicalHash: canonicalHash,
  );
  if (phoneHash == fingerprint) {
    return true;
  }
  return hashesFromPhoneFingerprint(
    phoneHash,
  ).any(target.contains);
}

/// 同一号码（或同一来源键）先拿库级咨询锁，再在这把锁里插入并计数。
/// 锁跟这次事务一起提交，调用返回时已经放开，短信发送不占这把锁。
/// 锁名带上桶和键，不同号码、不同来源不会挤在一把全站锁上。
/// 跨过上限的那一次用保存点撤回，已经提交的次数不退回。
Future<bool> smsTooManyUnderLock(
  Session session, {
  required String lockName,
  required DatabaseRateLimitedRequestAttemptUtil<String> limiter,
  required String nonce,
  Future<void> Function(Transaction tx)? afterAllowed,
}) {
  return session.db.transaction((tx) async {
    await session.db.unsafeQuery(
      'SELECT pg_advisory_xact_lock(hashtextextended(@fingerprint::text, 0))',
      parameters: QueryParameters.named({'fingerprint': lockName}),
      transaction: tx,
    );
    final save = await tx.createSavepoint();
    await limiter.recordAttempt(
      session,
      nonce: nonce,
      transaction: tx,
    );
    final count = await limiter.countAttempts(
      session,
      nonce: nonce,
      transaction: tx,
    );
    final max = limiter.config.maxAttempts;
    if (max != null && count > max) {
      await save.rollback();
      return true;
    }
    await save.release();
    if (afterAllowed != null) {
      await afterAllowed(tx);
    }
    return false;
  });
}

class SmsAccountAlreadyRegisteredException implements Exception {}

class SmsIdpUtils {
  final Argon2HashUtil hashUtil;
  final SmsIdpAccountCreationUtil accountCreation;
  final SmsIdpLoginUtil login;
  final SmsIdpPasswordResetUtil passwordReset;
  final SmsIdpBindUtil bind;

  SmsIdpUtils({required SmsIdpConfig config, required AuthUsers authUsers})
    : hashUtil = createSmsIdpArgon2HashUtil(
        hashPepper: config.secretHashPepper,
        fallbackHashPeppers: config.fallbackSecretHashPeppers,
        hashSaltLength: config.secretHashSaltLength,
      ),
      accountCreation = SmsIdpAccountCreationUtil(
        config: config,
        authUsers: authUsers,
      ),
      login = SmsIdpLoginUtil(config: config),
      passwordReset = SmsIdpPasswordResetUtil(config: config),
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

  static Future<T> withReplacedPasswordResetException<T>(
    Future<T> Function() fn,
  ) async {
    try {
      return await fn();
    } on ChallengeExpiredException {
      throw SmsPasswordResetException(
        reason: SmsPasswordResetExceptionReason.expired,
      );
    } on ChallengeRateLimitExceededException {
      throw SmsPasswordResetException(
        reason: SmsPasswordResetExceptionReason.tooManyAttempts,
      );
    } on ChallengeInvalidCompletionTokenException catch (_) {
      throw SmsPasswordResetException(
        reason: SmsPasswordResetExceptionReason.invalid,
      );
    } on ChallengeInvalidVerificationCodeException catch (_) {
      throw SmsPasswordResetException(
        reason: SmsPasswordResetExceptionReason.invalid,
      );
    } on ChallengeNotVerifiedException {
      throw SmsPasswordResetException(
        reason: SmsPasswordResetExceptionReason.invalid,
      );
    } on ChallengeRequestNotFoundException {
      throw SmsPasswordResetException(
        reason: SmsPasswordResetExceptionReason.invalid,
      );
    } on ChallengeAlreadyUsedException {
      throw SmsPasswordResetException(
        reason: SmsPasswordResetExceptionReason.invalid,
      );
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
  late final DatabaseRateLimitedRequestAttemptUtil<String> _sourceRateLimiter;

  SmsIdpAccountCreationUtil({
    required SmsIdpConfig config,
    required AuthUsers authUsers,
  }) : _config = config,
       _authUsers = authUsers,
       _hashUtil = createSmsIdpArgon2HashUtil(
         hashPepper: config.secretHashPepper,
         fallbackHashPeppers: config.fallbackSecretHashPeppers,
         hashSaltLength: config.secretHashSaltLength,
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
    _sourceRateLimiter = DatabaseRateLimitedRequestAttemptUtil(
      RateLimitedRequestAttemptConfig(
        domain: 'sms',
        source: smsRegistrationRequestSource,
        maxAttempts: _config.registrationRequestSourceRateLimit.maxAttempts,
        timeframe: _config.registrationRequestSourceRateLimit.timeframe,
      ),
    );
  }

  Future<UuidValue> startRegistration(
    Session session, {
    required String phone,
    Transaction? transaction,
  }) async {
    final canonical = _config.phoneIdStore.canonicalPhone(phone);
    if (canonical.isEmpty) {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.invalid,
      );
    }
    final nonce = _config.phoneIdStore.hashLegacyPhone(phone);
    final stored = _config.phoneIdStore.requestFingerprint(phone);

    final sourceKey = usableLoginSourceKey(
      _config.resolveRegistrationSourceKey?.call(session),
    );
    if (sourceKey != null &&
        await smsTooManyUnderLock(
          session,
          lockName: 'sms-registration-source:$sourceKey',
          limiter: _sourceRateLimiter,
          nonce: sourceKey,
        )) {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.tooManyAttempts,
      );
    }

    final verificationCode = _config.registrationVerificationCodeGenerator();
    SmsAccountRequest? request;
    Object? deferredError;
    final phoneTooMany = await smsTooManyUnderLock(
      session,
      lockName: 'sms-registration-phone:$nonce',
      limiter: _requestRateLimiter,
      nonce: nonce,
      afterAllowed: (tx) async {
        final existing = await _config.phoneIdStore.matchPhone(
          session,
          phone: phone,
          transaction: tx,
        );
        if (existing.conflict) {
          deferredError = SmsAccountRequestException(
            reason: SmsAccountRequestExceptionReason.phoneIdentityConflict,
          );
          return;
        }
        if (existing.userId != null) {
          deferredError = SmsAccountAlreadyRegisteredException();
          return;
        }

        final existingRequest = await SmsAccountRequest.db.findFirstRow(
          session,
          where: (t) => t.phoneHash.equals(stored),
          transaction: tx,
        );
        if (existingRequest != null) {
          await SmsAccountRequest.db.deleteRow(
            session,
            existingRequest,
            transaction: tx,
          );
        }

        final challenge = await _challengeUtil.createChallenge(
          session,
          verificationCode: verificationCode,
          transaction: tx,
        );

        request = await SmsAccountRequest.db.insertRow(
          session,
          SmsAccountRequest(phoneHash: stored, challengeId: challenge.id!),
          transaction: tx,
        );
      },
    );
    if (phoneTooMany) {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.tooManyAttempts,
      );
    }
    if (deferredError != null) {
      throw deferredError!;
    }

    final saved = request!;
    try {
      await _config.sendRegistrationVerificationCode?.call(
        session,
        phone: canonical,
        requestId: saved.id!,
        verificationCode: verificationCode,
        transaction: transaction,
      );
    } catch (_) {
      await _dropRegistrationRequest(session, saved);
      rethrow;
    }

    return saved.id!;
  }

  Future<void> _dropRegistrationRequest(
    Session session,
    SmsAccountRequest request,
  ) async {
    final current = await SmsAccountRequest.db.findById(session, request.id!);
    if (current == null) {
      return;
    }
    final challengeId = current.challengeId;
    await SmsAccountRequest.db.deleteRow(session, current);
    await session.db.unsafeExecute(
      'DELETE FROM serverpod_auth_idp_secret_challenge WHERE id = @id::uuid',
      parameters: QueryParameters.named({'id': challengeId.toString()}),
    );
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

    final stored = _config.phoneIdStore.requestFingerprint(phone);
    if (stored != request.phoneHash) {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.invalid,
      );
    }

    final existing = await _config.phoneIdStore.matchPhone(
      session,
      phone: phone,
      transaction: transaction,
    );
    if (existing.conflict) {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.phoneIdentityConflict,
      );
    }
    if (existing.userId != null) {
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
        phone: phone,
        allowRebind: false,
        transaction: transaction,
      );
    } on PhoneIdentityConflictException {
      throw SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.phoneIdentityConflict,
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
            final updated = await SmsAccountRequest.db.updateWhere(
              session,
              columnValues: (t) => [
                t.createAccountChallengeId(completionChallenge.id!),
              ],
              where: (t) =>
                  t.id.equals(request.id!) &
                  t.createAccountChallengeId.equals(null),
              transaction: transaction,
            );
            if (updated.isEmpty) {
              throw ChallengeAlreadyUsedException();
            }
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
  late final DatabaseRateLimitedRequestAttemptUtil<String> _sourceRateLimiter;

  SmsIdpLoginUtil({required SmsIdpConfig config})
    : _config = config,
      _hashUtil = createSmsIdpArgon2HashUtil(
        hashPepper: config.secretHashPepper,
        fallbackHashPeppers: config.fallbackSecretHashPeppers,
        hashSaltLength: config.secretHashSaltLength,
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
    _sourceRateLimiter = DatabaseRateLimitedRequestAttemptUtil(
      RateLimitedRequestAttemptConfig(
        domain: 'sms',
        source: smsLoginRequestSource,
        maxAttempts: _config.loginRequestSourceRateLimit.maxAttempts,
        timeframe: _config.loginRequestSourceRateLimit.timeframe,
      ),
    );
  }

  Future<UuidValue> startLogin(
    Session session, {
    required String phone,
    Transaction? transaction,
  }) async {
    final canonical = _config.phoneIdStore.canonicalPhone(phone);
    if (canonical.isEmpty) {
      throw SmsLoginException(reason: SmsLoginExceptionReason.invalid);
    }
    // 登录发码次数按规范串哈希计。带横杠和规范串共用同一 nonce，不各计 5 次。
    final nonce = _config.phoneIdStore.hashCanonicalPhone(phone);
    final stored = _config.phoneIdStore.requestFingerprint(phone);

    final sourceKey = usableLoginSourceKey(
      _config.resolveLoginSourceKey?.call(session),
    );
    if (sourceKey != null &&
        await smsTooManyUnderLock(
          session,
          lockName: 'sms-login-source:$sourceKey',
          limiter: _sourceRateLimiter,
          nonce: sourceKey,
        )) {
      throw SmsLoginException(reason: SmsLoginExceptionReason.tooManyAttempts);
    }

    final verificationCode = _config.loginVerificationCodeGenerator();
    SmsLoginRequest? request;
    final phoneTooMany = await smsTooManyUnderLock(
      session,
      lockName: 'sms-login-phone:$nonce',
      limiter: _requestRateLimiter,
      nonce: nonce,
      afterAllowed: (tx) async {
        final existingRequest = await SmsLoginRequest.db.findFirstRow(
          session,
          where: (t) => t.phoneHash.equals(stored),
          transaction: tx,
        );
        if (existingRequest != null) {
          await SmsLoginRequest.db.deleteRow(
            session,
            existingRequest,
            transaction: tx,
          );
        }
        final challenge = await _challengeUtil.createChallenge(
          session,
          verificationCode: verificationCode,
          transaction: tx,
        );
        request = await SmsLoginRequest.db.insertRow(
          session,
          SmsLoginRequest(phoneHash: stored, challengeId: challenge.id!),
          transaction: tx,
        );
      },
    );
    if (phoneTooMany) {
      throw SmsLoginException(reason: SmsLoginExceptionReason.tooManyAttempts);
    }

    final saved = request!;
    try {
      await _config.sendLoginVerificationCode?.call(
        session,
        phone: canonical,
        requestId: saved.id!,
        verificationCode: verificationCode,
        transaction: transaction,
      );
    } catch (_) {
      await _dropLoginRequest(session, saved);
      rethrow;
    }

    return saved.id!;
  }

  Future<void> _dropLoginRequest(
    Session session,
    SmsLoginRequest request, {
    Transaction? transaction,
  }) async {
    final current = await SmsLoginRequest.db.findById(
      session,
      request.id!,
      transaction: transaction,
    );
    if (current == null) {
      return;
    }
    // FK 是 request → challenge；删 request 不会级联删 challenge，必须显式删。
    final challengeId = current.challengeId;
    final loginChallengeId = current.loginChallengeId;
    await SmsLoginRequest.db.deleteRow(
      session,
      current,
      transaction: transaction,
    );
    await session.db.unsafeExecute(
      'DELETE FROM serverpod_auth_idp_secret_challenge WHERE id = @id::uuid',
      parameters: QueryParameters.named({'id': challengeId.toString()}),
      transaction: transaction,
    );
    if (loginChallengeId != null) {
      await session.db.unsafeExecute(
        'DELETE FROM serverpod_auth_idp_secret_challenge WHERE id = @id::uuid',
        parameters: QueryParameters.named({'id': loginChallengeId.toString()}),
        transaction: transaction,
      );
    }
  }

  /// 同一事务内按哈希交集删除该号码的登录请求，并显式删 challenge / loginChallenge。
  Future<void> dropLoginRequestsMatchingPhone(
    Session session, {
    required String phone,
    required Transaction transaction,
  }) async {
    final store = _config.phoneIdStore;
    final legacyHash = store.hashLegacyPhone(phone);
    final canonicalHash = store.hashCanonicalPhone(phone);
    final fingerprint = store.requestFingerprint(phone);
    final hashes = <String>{legacyHash, canonicalHash};

    final candidates = await SmsLoginRequest.db.find(
      session,
      where: (t) {
        var expr = t.phoneHash.equals(fingerprint);
        for (final hash in hashes) {
          expr =
              expr |
              t.phoneHash.equals(hash) |
              t.phoneHash.like('$hash|%') |
              t.phoneHash.like('%|$hash');
        }
        return expr;
      },
      transaction: transaction,
    );

    for (final row in candidates) {
      if (!smsLoginRequestMatchesPhoneHashes(
        phoneHash: row.phoneHash,
        legacyHash: legacyHash,
        canonicalHash: canonicalHash,
      )) {
        continue;
      }
      await _dropLoginRequest(session, row, transaction: transaction);
    }
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

    // 检查是否需要密码：
    // - 手机号未绑定任何账号时，需要设密码创建短信账号
    // - 手机号已绑定原账号但还没有短信密码时，也需要补设密码
    bool needsPassword = false;
    if (_config.requirePasswordOnUnregisteredLogin) {
      // 获取 request 来查找手机号哈希
      final request = await SmsLoginRequest.db.findById(
        session,
        loginRequestId,
        transaction: transaction,
      );
      if (request != null) {
        final hashes = _config.phoneIdStore.hashesOfFingerprint(
          request.phoneHash,
        );
        final match = await _config.phoneIdStore.matchHashes(
          session,
          hashes: hashes,
          legacyHash: hashes.length > 1 ? hashes[1] : hashes.first,
          canonicalHash: hashes.first,
          transaction: transaction,
        );
        if (match.conflict) {
          throw SmsLoginException(
            reason: SmsLoginExceptionReason.phoneIdentityConflict,
          );
        }
        final existingAuthUserId = match.userId;
        if (existingAuthUserId == null) {
          needsPassword = true;
        } else {
          final smsAccount = await SmsAccount.db.findFirstRow(
            session,
            where: (t) => t.authUserId.equals(existingAuthUserId),
            transaction: transaction,
          );
          needsPassword = smsAccount == null;
        }
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
            final updated = await SmsLoginRequest.db.updateWhere(
              session,
              columnValues: (t) => [
                t.loginChallengeId(completionChallenge.id!),
              ],
              where: (t) =>
                  t.id.equals(request.id!) & t.loginChallengeId.equals(null),
              transaction: transaction,
            );
            if (updated.isEmpty) {
              throw ChallengeAlreadyUsedException();
            }
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

class SmsIdpPasswordResetUtil {
  final SmsIdpConfig _config;
  final Argon2HashUtil _hashUtil;
  late final SecretChallengeUtil<SmsPasswordResetRequest> _challengeUtil;
  late final DatabaseRateLimitedRequestAttemptUtil<String> _requestRateLimiter;
  late final DatabaseRateLimitedRequestAttemptUtil<String> _sourceRateLimiter;

  SmsIdpPasswordResetUtil({required SmsIdpConfig config})
    : _config = config,
      _hashUtil = createSmsIdpArgon2HashUtil(
        hashPepper: config.secretHashPepper,
        fallbackHashPeppers: config.fallbackSecretHashPeppers,
        hashSaltLength: config.secretHashSaltLength,
      ) {
    _challengeUtil = SecretChallengeUtil(
      hashUtil: _hashUtil,
      verificationConfig: _buildVerificationConfig(),
      completionConfig: _buildCompletionConfig(),
    );
    _requestRateLimiter = DatabaseRateLimitedRequestAttemptUtil(
      RateLimitedRequestAttemptConfig(
        domain: 'sms',
        source: 'password_reset_request',
        maxAttempts: _config.passwordResetRequestRateLimit.maxAttempts,
        timeframe: _config.passwordResetRequestRateLimit.timeframe,
      ),
    );
    _sourceRateLimiter = DatabaseRateLimitedRequestAttemptUtil(
      RateLimitedRequestAttemptConfig(
        domain: 'sms',
        source: smsPasswordResetRequestSource,
        maxAttempts: _config.passwordResetRequestSourceRateLimit.maxAttempts,
        timeframe: _config.passwordResetRequestSourceRateLimit.timeframe,
      ),
    );
  }

  Future<UuidValue> startPasswordReset(
    Session session, {
    required String phone,
    Transaction? transaction,
  }) async {
    final canonical = _config.phoneIdStore.canonicalPhone(phone);
    if (canonical.isEmpty) {
      throw SmsPasswordResetException(
        reason: SmsPasswordResetExceptionReason.invalid,
      );
    }
    final nonce = _config.phoneIdStore.hashLegacyPhone(phone);
    final stored = _config.phoneIdStore.requestFingerprint(phone);

    final sourceKey = usableLoginSourceKey(
      _config.resolvePasswordResetSourceKey?.call(session),
    );
    if (sourceKey != null &&
        await smsTooManyUnderLock(
          session,
          lockName: 'sms-password-reset-source:$sourceKey',
          limiter: _sourceRateLimiter,
          nonce: sourceKey,
        )) {
      throw SmsPasswordResetException(
        reason: SmsPasswordResetExceptionReason.tooManyAttempts,
      );
    }

    final verificationCode = _config.passwordResetVerificationCodeGenerator();
    SmsPasswordResetRequest? request;
    var shouldSendVerificationCode = false;
    Object? deferredError;
    final phoneTooMany = await smsTooManyUnderLock(
      session,
      lockName: 'sms-password-reset-phone:$nonce',
      limiter: _requestRateLimiter,
      nonce: nonce,
      afterAllowed: (tx) async {
        final existingRequest = await SmsPasswordResetRequest.db.findFirstRow(
          session,
          where: (t) => t.phoneHash.equals(stored),
          transaction: tx,
        );
        if (existingRequest != null) {
          await SmsPasswordResetRequest.db.deleteRow(
            session,
            existingRequest,
            transaction: tx,
          );
        }

        final existing = await _config.phoneIdStore.matchPhone(
          session,
          phone: phone,
          transaction: tx,
        );
        if (existing.conflict) {
          deferredError = SmsPasswordResetException(
            reason: SmsPasswordResetExceptionReason.phoneIdentityConflict,
          );
          return;
        }
        final existingAuthUserId = existing.userId;
        UuidValue? resettableAuthUserId;
        SmsPasswordResetBlockedReason? blockedReason;
        if (existingAuthUserId != null) {
          final smsAccount = await SmsAccount.db.findFirstRow(
            session,
            where: (t) => t.authUserId.equals(existingAuthUserId),
            transaction: tx,
          );
          if (smsAccount == null) {
            blockedReason = SmsPasswordResetBlockedReason.passwordNotSetYet;
            shouldSendVerificationCode = true;
          } else {
            resettableAuthUserId = existingAuthUserId;
            shouldSendVerificationCode = true;
          }
        }

        final challenge = await _challengeUtil.createChallenge(
          session,
          verificationCode: verificationCode,
          transaction: tx,
        );

        request = await SmsPasswordResetRequest.db.insertRow(
          session,
          SmsPasswordResetRequest(
            phoneHash: stored,
            authUserId: resettableAuthUserId,
            blockedReason: blockedReason,
            challengeId: challenge.id!,
          ),
          transaction: tx,
        );
      },
    );
    if (phoneTooMany) {
      throw SmsPasswordResetException(
        reason: SmsPasswordResetExceptionReason.tooManyAttempts,
      );
    }
    if (deferredError != null) {
      throw deferredError!;
    }

    final saved = request!;
    if (shouldSendVerificationCode) {
      try {
        await _config.sendPasswordResetVerificationCode?.call(
          session,
          phone: canonical,
          requestId: saved.id!,
          verificationCode: verificationCode,
          transaction: transaction,
        );
      } catch (_) {
        await _dropPasswordResetRequest(session, saved);
        rethrow;
      }
    }

    return saved.id!;
  }

  Future<void> _dropPasswordResetRequest(
    Session session,
    SmsPasswordResetRequest request,
  ) async {
    final current = await SmsPasswordResetRequest.db.findById(
      session,
      request.id!,
    );
    if (current == null) {
      return;
    }
    final challengeId = current.challengeId;
    await SmsPasswordResetRequest.db.deleteRow(session, current);
    await session.db.unsafeExecute(
      'DELETE FROM serverpod_auth_idp_secret_challenge WHERE id = @id::uuid',
      parameters: QueryParameters.named({'id': challengeId.toString()}),
    );
  }

  Future<SmsVerifyPasswordResetResult> verifyPasswordResetCode(
    Session session, {
    required UuidValue resetRequestId,
    required String verificationCode,
    required Transaction transaction,
  }) async {
    final resetToken = await SmsIdpUtils.withReplacedPasswordResetException(
      () => _challengeUtil.verifyChallenge(
        session,
        requestId: resetRequestId,
        verificationCode: verificationCode,
        transaction: transaction,
      ),
    );
    final request = await SmsPasswordResetRequest.db.findById(
      session,
      resetRequestId,
      transaction: transaction,
    );
    if (request == null) {
      throw SmsPasswordResetException(
        reason: SmsPasswordResetExceptionReason.invalid,
      );
    }
    if (request.blockedReason != null) {
      return SmsVerifyPasswordResetResult(
        resetToken: null,
        blockedReason: request.blockedReason,
      );
    }
    if (request.authUserId == null) {
      throw SmsPasswordResetException(
        reason: SmsPasswordResetExceptionReason.invalid,
      );
    }
    return SmsVerifyPasswordResetResult(
      resetToken: resetToken,
      blockedReason: null,
    );
  }

  Future<SmsPasswordResetRequest> completePasswordReset(
    Session session, {
    required String resetToken,
    required Transaction transaction,
  }) async {
    return SmsIdpUtils.withReplacedPasswordResetException(
      () => _challengeUtil.completeChallenge(
        session,
        completionToken: resetToken,
        transaction: transaction,
      ),
    );
  }

  SecretChallengeVerificationConfig<SmsPasswordResetRequest>
  _buildVerificationConfig() {
    final limiter = DatabaseRateLimitedRequestAttemptUtil<UuidValue>(
      RateLimitedRequestAttemptConfig(
        domain: 'sms',
        source: 'password_reset_verify',
        maxAttempts: _config.passwordResetVerificationCodeAllowedAttempts,
        timeframe: _config.passwordResetVerificationCodeLifetime,
      ),
    );

    return SecretChallengeVerificationConfig(
      getRequest: (session, requestId, {required transaction}) async {
        return SmsPasswordResetRequest.db.findById(
          session,
          requestId,
          transaction: transaction,
          include: SmsPasswordResetRequest.include(
            challenge: SecretChallenge.include(),
          ),
        );
      },
      isAlreadyUsed: (request) => request.resetChallengeId != null,
      getChallenge: (request) => request.challenge!,
      isExpired: (request) => request.createdAt
          .add(_config.passwordResetVerificationCodeLifetime)
          .isBefore(DateTime.now()),
      onExpired: (session, request) async {
        await SmsPasswordResetRequest.db.deleteRow(session, request);
      },
      linkCompletionToken:
          (
            session,
            request,
            completionChallenge, {
            required transaction,
          }) async {
            final updated = await SmsPasswordResetRequest.db.updateWhere(
              session,
              columnValues: (t) => [
                t.resetChallengeId(completionChallenge.id!),
              ],
              where: (t) =>
                  t.id.equals(request.id!) & t.resetChallengeId.equals(null),
              transaction: transaction,
            );
            if (updated.isEmpty) {
              throw ChallengeAlreadyUsedException();
            }
          },
      rateLimiter: limiter,
    );
  }

  SecretChallengeCompletionConfig<SmsPasswordResetRequest>
  _buildCompletionConfig() {
    final limiter = DatabaseRateLimitedRequestAttemptUtil<UuidValue>(
      RateLimitedRequestAttemptConfig(
        domain: 'sms',
        source: 'password_reset_complete',
        maxAttempts: _config.passwordResetVerificationCodeAllowedAttempts,
        timeframe: _config.passwordResetVerificationCodeLifetime,
      ),
    );
    return SecretChallengeCompletionConfig(
      getRequest: (session, requestId, {required transaction}) async {
        return SmsPasswordResetRequest.db.findById(
          session,
          requestId,
          transaction: transaction,
          include: SmsPasswordResetRequest.include(
            resetChallenge: SecretChallenge.include(),
          ),
        );
      },
      getCompletionChallenge: (request) => request.resetChallenge,
      isExpired: (request) => request.createdAt
          .add(_config.passwordResetVerificationCodeLifetime)
          .isBefore(DateTime.now()),
      onExpired: (session, request) async {
        await SmsPasswordResetRequest.db.deleteRow(session, request);
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
  late final DatabaseRateLimitedRequestAttemptUtil<String> _sourceRateLimiter;

  SmsIdpBindUtil({required SmsIdpConfig config})
    : _config = config,
      _hashUtil = createSmsIdpArgon2HashUtil(
        hashPepper: config.secretHashPepper,
        fallbackHashPeppers: config.fallbackSecretHashPeppers,
        hashSaltLength: config.secretHashSaltLength,
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
    _sourceRateLimiter = DatabaseRateLimitedRequestAttemptUtil(
      RateLimitedRequestAttemptConfig(
        domain: 'sms',
        source: smsBindRequestSource,
        maxAttempts: _config.bindRequestSourceRateLimit.maxAttempts,
        timeframe: _config.bindRequestSourceRateLimit.timeframe,
      ),
    );
  }

  Future<UuidValue> startBind(
    Session session, {
    required UuidValue authUserId,
    required String phone,
    Transaction? transaction,
  }) async {
    final canonical = _config.phoneIdStore.canonicalPhone(phone);
    if (canonical.isEmpty) {
      throw SmsPhoneBindException(reason: SmsPhoneBindExceptionReason.invalid);
    }
    final legacy = _config.phoneIdStore.hashLegacyPhone(phone);
    final stored = _config.phoneIdStore.requestFingerprint(phone);
    final nonce = '$authUserId:$legacy';

    final sourceKey = usableLoginSourceKey(
      _config.resolveBindSourceKey?.call(session),
    );
    if (sourceKey != null &&
        await smsTooManyUnderLock(
          session,
          lockName: 'sms-bind-source:$sourceKey',
          limiter: _sourceRateLimiter,
          nonce: sourceKey,
        )) {
      throw SmsPhoneBindException(
        reason: SmsPhoneBindExceptionReason.tooManyAttempts,
      );
    }

    final verificationCode = _config.bindVerificationCodeGenerator();
    SmsBindRequest? request;
    final phoneTooMany = await smsTooManyUnderLock(
      session,
      lockName: 'sms-bind-phone:$nonce',
      limiter: _requestRateLimiter,
      nonce: nonce,
      afterAllowed: (tx) async {
        final existing = await SmsBindRequest.db.findFirstRow(
          session,
          where: (t) =>
              t.authUserId.equals(authUserId) & t.phoneHash.equals(stored),
          transaction: tx,
        );
        if (existing != null) {
          await SmsBindRequest.db.deleteRow(
            session,
            existing,
            transaction: tx,
          );
        }

        final challenge = await _challengeUtil.createChallenge(
          session,
          verificationCode: verificationCode,
          transaction: tx,
        );

        request = await SmsBindRequest.db.insertRow(
          session,
          SmsBindRequest(
            authUserId: authUserId,
            phoneHash: stored,
            challengeId: challenge.id!,
          ),
          transaction: tx,
        );
      },
    );
    if (phoneTooMany) {
      throw SmsPhoneBindException(
        reason: SmsPhoneBindExceptionReason.tooManyAttempts,
      );
    }

    final saved = request!;
    try {
      await _config.sendBindVerificationCode?.call(
        session,
        phone: canonical,
        requestId: saved.id!,
        verificationCode: verificationCode,
        transaction: transaction,
      );
    } catch (_) {
      await _dropBindRequest(session, saved);
      rethrow;
    }

    return saved.id!;
  }

  Future<void> _dropBindRequest(
    Session session,
    SmsBindRequest request,
  ) async {
    final current = await SmsBindRequest.db.findById(session, request.id!);
    if (current == null) {
      return;
    }
    final challengeId = current.challengeId;
    await SmsBindRequest.db.deleteRow(session, current);
    await session.db.unsafeExecute(
      'DELETE FROM serverpod_auth_idp_secret_challenge WHERE id = @id::uuid',
      parameters: QueryParameters.named({'id': challengeId.toString()}),
    );
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
            final updated = await SmsBindRequest.db.updateWhere(
              session,
              columnValues: (t) => [t.bindChallengeId(completionChallenge.id!)],
              where: (t) =>
                  t.id.equals(request.id!) & t.bindChallengeId.equals(null),
              transaction: transaction,
            );
            if (updated.isEmpty) {
              throw ChallengeAlreadyUsedException();
            }
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
