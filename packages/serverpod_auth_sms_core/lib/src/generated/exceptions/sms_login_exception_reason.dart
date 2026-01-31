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

/// The reason for why the SMS login was rejected.
enum SmsLoginExceptionReason implements _i1.SerializableModel {
  /// Invalid token, code, or phone.
  invalid,

  /// Too many attempts made for the same request.
  tooManyAttempts,

  /// Login request expired.
  expired,

  /// Password is required for unregistered phone.
  passwordRequired,

  /// Password does not match policy.
  policyViolation,

  /// Unknown error occurred.
  unknown;

  static SmsLoginExceptionReason fromJson(String name) {
    switch (name) {
      case 'invalid':
        return SmsLoginExceptionReason.invalid;
      case 'tooManyAttempts':
        return SmsLoginExceptionReason.tooManyAttempts;
      case 'expired':
        return SmsLoginExceptionReason.expired;
      case 'passwordRequired':
        return SmsLoginExceptionReason.passwordRequired;
      case 'policyViolation':
        return SmsLoginExceptionReason.policyViolation;
      case 'unknown':
        return SmsLoginExceptionReason.unknown;
      default:
        return SmsLoginExceptionReason.unknown;
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
