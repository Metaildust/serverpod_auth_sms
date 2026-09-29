import 'dart:async';
import 'dart:math';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import 'generated/protocol.dart';
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

typedef ResolveBindAndLoginAvailabilityFunction =
    FutureOr<SmsBindAndLoginAvailability> Function(
      Session session, {
      required UuidValue currentAuthUserId,
      required UuidValue conflictAuthUserId,
      required String phoneHash,
      required Transaction? transaction,
    });

typedef ExecuteBindAndLoginFunction =
    FutureOr<SmsBindAndLoginExecutionResult> Function(
      Session session, {
      required UuidValue currentAuthUserId,
      required UuidValue conflictAuthUserId,
      required String phoneHash,
      required Transaction? transaction,
    });

class SmsBindAndLoginAvailability {
  final bool enabled;
  final SmsBindAndLoginDisabledReason? disabledReason;

  const SmsBindAndLoginAvailability.enabled()
    : enabled = true,
      disabledReason = null;

  const SmsBindAndLoginAvailability.disabled({
    this.disabledReason = SmsBindAndLoginDisabledReason.unknown,
  }) : enabled = false;
}

class SmsBindAndLoginExecutionResult {
  final UuidValue targetAuthUserId;

  /// When true, SMS module should delete current auth user after switching.
  final bool cleanupCurrentAuthUser;

  const SmsBindAndLoginExecutionResult({
    required this.targetAuthUserId,
    this.cleanupCurrentAuthUser = false,
  });
}

String defaultSmsVerificationCodeGenerator({int length = 6}) {
  final rng = Random.secure();
  return List.generate(length, (_) => rng.nextInt(10)).join();
}

/// 包默认密码校验：与 client 包 `evaluateAuthPasswordPolicy` 六项布尔一致。
///
/// 因服务端包与客户端包不能互引，此处各放一份同口径实现；不得弱回「满 8 位即通过」。
bool defaultRegistrationPasswordValidationFunction(final String password) {
  final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
  final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
  final hasDigits = RegExp(r'[0-9]').hasMatch(password);
  final hasSpecialChars = RegExp(
    r'[\x21-\x2F\x3A-\x40\x5B-\x60\x7B-\x7E]',
  ).hasMatch(password);
  final hasMinLength = password.length >= 8;
  final isAllAscii =
      password.isNotEmpty &&
      password.runes.every((c) => c >= 0x20 && c <= 0x7E);
  return hasMinLength &&
      hasUppercase &&
      hasLowercase &&
      hasDigits &&
      hasSpecialChars &&
      isAllAscii;
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

  /// 短信验码登录时，若手机号对应的账号尚无 [SmsAccount]（包括全新手机号
  /// 以及已绑定原账号但未设过短信密码的情况），是否要求用户设置密码。
  ///
  /// 名称中的 "Unregistered" 是历史遗留；实际语义已扩展为
  /// "无 SmsAccount 记录即需设密码"，未来大版本可考虑更名。
  final bool requirePasswordOnUnregisteredLogin;
  final bool allowPhoneRebind;

  final Duration registrationVerificationCodeLifetime;
  final int registrationVerificationCodeAllowedAttempts;
  final String Function() registrationVerificationCodeGenerator;
  final SmsRateLimit registrationRequestRateLimit;

  /// 注册发码来源桶。只在 [resolveRegistrationSourceKey] 给出非空键时使用。
  final SmsRateLimit registrationRequestSourceRateLimit;

  /// 测试注入注册发码来源键。生产装配不传。
  final String? Function(Session session)? resolveRegistrationSourceKey;

  final Duration loginVerificationCodeLifetime;
  final int loginVerificationCodeAllowedAttempts;
  final String Function() loginVerificationCodeGenerator;
  final SmsRateLimit loginRequestRateLimit;

  /// 登录发码来源桶。只在 [resolveLoginSourceKey] 给出非空键时使用。
  final SmsRateLimit loginRequestSourceRateLimit;

  /// 测试注入登录发码来源键。生产装配不传。
  /// 返回空或字面量 null 时不走来源桶，也不读入口地址。
  final String? Function(Session session)? resolveLoginSourceKey;

  final Duration bindVerificationCodeLifetime;
  final int bindVerificationCodeAllowedAttempts;
  final String Function() bindVerificationCodeGenerator;
  final SmsRateLimit bindRequestRateLimit;

  /// 绑定发码来源桶。只在 [resolveBindSourceKey] 给出非空键时使用。
  final SmsRateLimit bindRequestSourceRateLimit;

  /// 测试注入绑定发码来源键。生产装配不传。
  final String? Function(Session session)? resolveBindSourceKey;

  /// 短信密码重置验证码有效期。
  final Duration passwordResetVerificationCodeLifetime;

  /// 短信密码重置验证码最大尝试次数。
  final int passwordResetVerificationCodeAllowedAttempts;

  /// 生成短信密码重置验证码。
  final String Function() passwordResetVerificationCodeGenerator;

  /// 短信密码重置发码限流。
  final SmsRateLimit passwordResetRequestRateLimit;

  /// 重置发码来源桶。只在 [resolvePasswordResetSourceKey] 给出非空键时使用。
  final SmsRateLimit passwordResetRequestSourceRateLimit;

  /// 测试注入重置发码来源键。生产装配不传。
  final String? Function(Session session)? resolvePasswordResetSourceKey;

  final SendSmsVerificationCodeFunction? sendRegistrationVerificationCode;
  final SendSmsVerificationCodeFunction? sendLoginVerificationCode;
  final SendSmsVerificationCodeFunction? sendBindVerificationCode;
  final SendSmsVerificationCodeFunction? sendPasswordResetVerificationCode;

  final PasswordValidationFunction passwordValidationFunction;
  final AfterAccountCreatedFunction? onAfterAccountCreated;
  final AfterPhoneBoundFunction? onAfterPhoneBound;
  final ResolveBindAndLoginAvailabilityFunction?
  resolveBindAndLoginAvailability;
  final ExecuteBindAndLoginFunction? executeBindAndLogin;

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
    this.registrationRequestSourceRateLimit = const SmsRateLimit(
      maxAttempts: 60,
      timeframe: Duration(minutes: 10),
    ),
    this.resolveRegistrationSourceKey,
    this.loginVerificationCodeLifetime = const Duration(minutes: 10),
    this.loginVerificationCodeAllowedAttempts = 3,
    this.loginVerificationCodeGenerator = defaultSmsVerificationCodeGenerator,
    this.loginRequestRateLimit = const SmsRateLimit(
      maxAttempts: 5,
      timeframe: Duration(minutes: 10),
    ),
    this.loginRequestSourceRateLimit = const SmsRateLimit(
      maxAttempts: 60,
      timeframe: Duration(minutes: 10),
    ),
    this.resolveLoginSourceKey,
    this.bindVerificationCodeLifetime = const Duration(minutes: 10),
    this.bindVerificationCodeAllowedAttempts = 3,
    this.bindVerificationCodeGenerator = defaultSmsVerificationCodeGenerator,
    this.bindRequestRateLimit = const SmsRateLimit(
      maxAttempts: 5,
      timeframe: Duration(minutes: 10),
    ),
    this.bindRequestSourceRateLimit = const SmsRateLimit(
      maxAttempts: 60,
      timeframe: Duration(minutes: 10),
    ),
    this.resolveBindSourceKey,
    this.passwordResetVerificationCodeLifetime = const Duration(minutes: 10),
    this.passwordResetVerificationCodeAllowedAttempts = 3,
    this.passwordResetVerificationCodeGenerator =
        defaultSmsVerificationCodeGenerator,
    this.passwordResetRequestRateLimit = const SmsRateLimit(
      maxAttempts: 5,
      timeframe: Duration(minutes: 10),
    ),
    this.passwordResetRequestSourceRateLimit = const SmsRateLimit(
      maxAttempts: 60,
      timeframe: Duration(minutes: 10),
    ),
    this.resolvePasswordResetSourceKey,
    this.sendRegistrationVerificationCode,
    this.sendLoginVerificationCode,
    this.sendBindVerificationCode,
    this.sendPasswordResetVerificationCode,
    this.passwordValidationFunction =
        defaultRegistrationPasswordValidationFunction,
    this.onAfterAccountCreated,
    this.onAfterPhoneBound,
    this.resolveBindAndLoginAvailability,
    this.executeBindAndLogin,
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
    super.registrationRequestSourceRateLimit,
    super.resolveRegistrationSourceKey,
    super.loginVerificationCodeLifetime,
    super.loginVerificationCodeAllowedAttempts,
    super.loginVerificationCodeGenerator,
    super.loginRequestRateLimit,
    super.loginRequestSourceRateLimit,
    super.resolveLoginSourceKey,
    super.bindVerificationCodeLifetime,
    super.bindVerificationCodeAllowedAttempts,
    super.bindVerificationCodeGenerator,
    super.bindRequestRateLimit,
    super.bindRequestSourceRateLimit,
    super.resolveBindSourceKey,
    super.passwordResetVerificationCodeLifetime,
    super.passwordResetVerificationCodeAllowedAttempts,
    super.passwordResetVerificationCodeGenerator,
    super.passwordResetRequestRateLimit,
    super.passwordResetRequestSourceRateLimit,
    super.resolvePasswordResetSourceKey,
    super.sendRegistrationVerificationCode,
    super.sendLoginVerificationCode,
    super.sendBindVerificationCode,
    super.sendPasswordResetVerificationCode,
    super.passwordValidationFunction,
    super.onAfterAccountCreated,
    super.onAfterPhoneBound,
    super.resolveBindAndLoginAvailability,
    super.executeBindAndLogin,
  }) : super(secretHashPepper: _getPasswordOrThrow('smsSecretHashPepper'));

  static String _getPasswordOrThrow(String key) {
    final value = Serverpod.instance.getPassword(key);
    if (value == null || value.isEmpty) {
      throw StateError('$key must be configured in passwords.');
    }
    return value;
  }
}
