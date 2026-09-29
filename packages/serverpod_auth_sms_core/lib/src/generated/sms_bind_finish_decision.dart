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

/// User decision for phone-bind conflict.
enum SmsBindFinishDecision implements _i1.SerializableModel {
  /// Keep phone on old account, migrate current WeChat (if any), and sign in old account.
  bindAndLogin,

  /// Move phone from old account to current account.
  registerNew;

  static SmsBindFinishDecision fromJson(String name) {
    switch (name) {
      case 'bindAndLogin':
        return SmsBindFinishDecision.bindAndLogin;
      case 'registerNew':
        return SmsBindFinishDecision.registerNew;
      default:
        return SmsBindFinishDecision.registerNew;
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
