/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// 短信密码重置被拒绝的原因。
enum SmsPasswordResetExceptionReason implements _i1.SerializableModel {
  /// 无效的 token、验证码或手机号。
  invalid,

  /// 同一请求尝试次数过多。
  tooManyAttempts,

  /// 请求已过期。
  expired,

  /// 密码不符合策略。
  policyViolation,

  /// 新密码与旧密码相同。
  samePassword,

  /// 新旧写法对上两个账号。
  phoneIdentityConflict,

  /// 未知错误。
  unknown;

  static SmsPasswordResetExceptionReason fromJson(String name) {
    switch (name) {
      case 'invalid':
        return SmsPasswordResetExceptionReason.invalid;
      case 'tooManyAttempts':
        return SmsPasswordResetExceptionReason.tooManyAttempts;
      case 'expired':
        return SmsPasswordResetExceptionReason.expired;
      case 'policyViolation':
        return SmsPasswordResetExceptionReason.policyViolation;
      case 'samePassword':
        return SmsPasswordResetExceptionReason.samePassword;
      case 'phoneIdentityConflict':
        return SmsPasswordResetExceptionReason.phoneIdentityConflict;
      case 'unknown':
        return SmsPasswordResetExceptionReason.unknown;
      default:
        return SmsPasswordResetExceptionReason.unknown;
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
