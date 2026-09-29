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

import 'package:serverpod/serverpod.dart' as _i1;
import 'sms_password_reset_blocked_reason.dart' as _i2;

/// 短信密码重置验证码验证结果。
abstract class SmsVerifyPasswordResetResult
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  SmsVerifyPasswordResetResult._({
    this.resetToken,
    this.blockedReason,
  });

  factory SmsVerifyPasswordResetResult({
    String? resetToken,
    _i2.SmsPasswordResetBlockedReason? blockedReason,
  }) = _SmsVerifyPasswordResetResultImpl;

  factory SmsVerifyPasswordResetResult.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SmsVerifyPasswordResetResult(
      resetToken: jsonSerialization['resetToken'] as String?,
      blockedReason: jsonSerialization['blockedReason'] == null
          ? null
          : _i2.SmsPasswordResetBlockedReason.fromJson(
              (jsonSerialization['blockedReason'] as String),
            ),
    );
  }

  /// 验证成功后的 token，用于 finishPasswordReset。
  String? resetToken;

  /// 验码成功但被拦截的原因。
  _i2.SmsPasswordResetBlockedReason? blockedReason;

  /// Returns a shallow copy of this [SmsVerifyPasswordResetResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SmsVerifyPasswordResetResult copyWith({
    String? resetToken,
    _i2.SmsPasswordResetBlockedReason? blockedReason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_auth_sms_core.SmsVerifyPasswordResetResult',
      if (resetToken != null) 'resetToken': resetToken,
      if (blockedReason != null) 'blockedReason': blockedReason?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_auth_sms_core.SmsVerifyPasswordResetResult',
      if (resetToken != null) 'resetToken': resetToken,
      if (blockedReason != null) 'blockedReason': blockedReason?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SmsVerifyPasswordResetResultImpl extends SmsVerifyPasswordResetResult {
  _SmsVerifyPasswordResetResultImpl({
    String? resetToken,
    _i2.SmsPasswordResetBlockedReason? blockedReason,
  }) : super._(
         resetToken: resetToken,
         blockedReason: blockedReason,
       );

  /// Returns a shallow copy of this [SmsVerifyPasswordResetResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SmsVerifyPasswordResetResult copyWith({
    Object? resetToken = _Undefined,
    Object? blockedReason = _Undefined,
  }) {
    return SmsVerifyPasswordResetResult(
      resetToken: resetToken is String? ? resetToken : this.resetToken,
      blockedReason: blockedReason is _i2.SmsPasswordResetBlockedReason?
          ? blockedReason
          : this.blockedReason,
    );
  }
}
