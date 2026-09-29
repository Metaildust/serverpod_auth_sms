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

/// 短信密码重置在验码成功后的拦截原因。
enum SmsPasswordResetBlockedReason implements _i1.SerializableModel {
  /// 该手机号已绑定账号，但尚未设置过短信密码。
  passwordNotSetYet,

  /// 未知原因。
  unknown;

  static SmsPasswordResetBlockedReason fromJson(String name) {
    switch (name) {
      case 'passwordNotSetYet':
        return SmsPasswordResetBlockedReason.passwordNotSetYet;
      case 'unknown':
        return SmsPasswordResetBlockedReason.unknown;
      default:
        return SmsPasswordResetBlockedReason.unknown;
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
