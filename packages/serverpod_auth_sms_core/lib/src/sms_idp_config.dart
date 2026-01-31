import 'dart:async';
import 'dart:math';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import 'phone/phone_id_store.dart';
import 'sms_idp.dart';

typedef SendSmsVerificationCodeFunction =
    FutureOr<void> Function(
      Session session, {
      required String phone,
      required UuidValue requestId,
      required String verificationCode,
      required Transaction? transaction,
    });

typedef PasswordValidationFunction = bool Function(String password);

typedef AfterAccountCreatedFunction =
    FutureOr<void> Function(
      Session session, {
      required UuidValue authUserId,
      required Transaction? transaction,
    });

typedef AfterPhoneBoundFunction =
    FutureOr<void> Function(
      Session session, {
      required UuidValue authUserId,
      required Transaction? transaction,
    });

String defaultSmsVerificationCodeGenerator({int length = 6}) {
  final rng = Random.secure();
  return List.generate(length, (_) => rng.nextInt(10)).join();
}

bool defaultRegistrationPasswordValidationFunction(final String password) {
  return password.trim() == password && password.length >= 8;
}

/// SMS 速率限制配置。
///
/// 命名为 SmsRateLimit 以避免与 serverpod_auth_idp_server 的 RateLimit 冲突。
class SmsRateLimit {
  final int maxAttempts;
  final Duration timeframe;

  const SmsRateLimit({required this.maxAttempts, required this.timeframe});
}

class SmsIdpConfig extends IdentityProviderBuilder<SmsIdp> {
  final String secretHashPepper;
  final List<String> fallbackSecretHashPeppers;
  final int secretHashSaltLength;

  final bool enableRegistration;
  final bool enableLogin;
  final bool enableBind;
  final bool requirePasswordOnUnregisteredLogin;
  final bool allowPhoneRebind;

  final Duration registrationVerificationCodeLifetime;
  final int registrationVerificationCodeAllowedAttempts;
  final String Function() registrationVerificationCodeGenerator;
  final SmsRateLimit registrationRequestRateLimit;

  final Duration loginVerificationCodeLifetime;
  final int loginVerificationCodeAllowedAttempts;
  final String Function() loginVerificationCodeGenerator;
  final SmsRateLimit loginRequestRateLimit;

  final Duration bindVerificationCodeLifetime;
  final int bindVerificationCodeAllowedAttempts;
  final String Function() bindVerificationCodeGenerator;
  final SmsRateLimit bindRequestRateLimit;

  final SendSmsVerificationCodeFunction? sendRegistrationVerificationCode;
  final SendSmsVerificationCodeFunction? sendLoginVerificationCode;
  final SendSmsVerificationCodeFunction? sendBindVerificationCode;

  final PasswordValidationFunction passwordValidationFunction;
  final AfterAccountCreatedFunction? onAfterAccountCreated;
  final AfterPhoneBoundFunction? onAfterPhoneBound;

  final PhoneIdStore phoneIdStore;

  const SmsIdpConfig({
    required this.secretHashPepper,
    required this.phoneIdStore,
    this.fallbackSecretHashPeppers = const [],
    this.secretHashSaltLength = 16,
    this.enableRegistration = true,
    this.enableLogin = true,
    this.enableBind = true,
    this.requirePasswordOnUnregisteredLogin = true,
    this.allowPhoneRebind = false,
    this.registrationVerificationCodeLifetime = const Duration(minutes: 15),
    this.registrationVerificationCodeAllowedAttempts = 3,
    this.registrationVerificationCodeGenerator =
        defaultSmsVerificationCodeGenerator,
    this.registrationRequestRateLimit = const SmsRateLimit(
      maxAttempts: 5,
      timeframe: Duration(minutes: 15),
    ),
    this.loginVerificationCodeLifetime = const Duration(minutes: 10),
    this.loginVerificationCodeAllowedAttempts = 3,
    this.loginVerificationCodeGenerator = defaultSmsVerificationCodeGenerator,
    this.loginRequestRateLimit = const SmsRateLimit(
      maxAttempts: 5,
      timeframe: Duration(minutes: 10),
    ),
    this.bindVerificationCodeLifetime = const Duration(minutes: 10),
    this.bindVerificationCodeAllowedAttempts = 3,
    this.bindVerificationCodeGenerator = defaultSmsVerificationCodeGenerator,
    this.bindRequestRateLimit = const SmsRateLimit(
      maxAttempts: 5,
      timeframe: Duration(minutes: 10),
    ),
    this.sendRegistrationVerificationCode,
    this.sendLoginVerificationCode,
    this.sendBindVerificationCode,
    this.passwordValidationFunction =
        defaultRegistrationPasswordValidationFunction,
    this.onAfterAccountCreated,
    this.onAfterPhoneBound,
  });

  @override
  SmsIdp build({
    required TokenManager tokenManager,
    required AuthUsers authUsers,
    required UserProfiles userProfiles,
  }) {
    return SmsIdp(
      this,
      tokenManager: tokenManager,
      authUsers: authUsers,
      userProfiles: userProfiles,
    );
  }
}

class SmsIdpConfigFromPasswords extends SmsIdpConfig {
  SmsIdpConfigFromPasswords({
    required super.phoneIdStore,
    super.fallbackSecretHashPeppers,
    super.secretHashSaltLength,
    super.enableRegistration,
    super.enableLogin,
    super.enableBind,
    super.requirePasswordOnUnregisteredLogin,
    super.allowPhoneRebind,
    super.registrationVerificationCodeLifetime,
    super.registrationVerificationCodeAllowedAttempts,
    super.registrationVerificationCodeGenerator,
    super.registrationRequestRateLimit,
    super.loginVerificationCodeLifetime,
    super.loginVerificationCodeAllowedAttempts,
    super.loginVerificationCodeGenerator,
    super.loginRequestRateLimit,
    super.bindVerificationCodeLifetime,
    super.bindVerificationCodeAllowedAttempts,
    super.bindVerificationCodeGenerator,
    super.bindRequestRateLimit,
    super.sendRegistrationVerificationCode,
    super.sendLoginVerificationCode,
    super.sendBindVerificationCode,
    super.passwordValidationFunction,
    super.onAfterAccountCreated,
    super.onAfterPhoneBound,
  }) : super(secretHashPepper: _getPasswordOrThrow('smsSecretHashPepper'));

  static String _getPasswordOrThrow(String key) {
    final value = Serverpod.instance.getPassword(key);
    if (value == null || value.isEmpty) {
      throw StateError('$key must be configured in passwords.');
    }
    return value;
  }
}
