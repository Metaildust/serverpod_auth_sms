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

/// The reason for why the phone bind request was rejected.
enum SmsPhoneBindExceptionReason implements _i1.SerializableModel {
  /// Invalid token, code, or phone.
  invalid,

  /// Too many attempts made for the same request.
  tooManyAttempts,

  /// Bind request expired.
  expired,

  /// Phone already bound to another account.
  phoneAlreadyBound,

  /// Unknown error occurred.
  unknown;

  static SmsPhoneBindExceptionReason fromJson(String name) {
    switch (name) {
      case 'invalid':
        return SmsPhoneBindExceptionReason.invalid;
      case 'tooManyAttempts':
        return SmsPhoneBindExceptionReason.tooManyAttempts;
      case 'expired':
        return SmsPhoneBindExceptionReason.expired;
      case 'phoneAlreadyBound':
        return SmsPhoneBindExceptionReason.phoneAlreadyBound;
      case 'unknown':
        return SmsPhoneBindExceptionReason.unknown;
      default:
        return SmsPhoneBindExceptionReason.unknown;
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
