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
import '../exceptions/sms_password_reset_exception_reason.dart' as _i2;

abstract class SmsPasswordResetException
    implements _i1.SerializableException, _i1.SerializableModel {
  SmsPasswordResetException._({required this.reason});

  factory SmsPasswordResetException({
    required _i2.SmsPasswordResetExceptionReason reason,
  }) = _SmsPasswordResetExceptionImpl;

  factory SmsPasswordResetException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SmsPasswordResetException(
      reason: _i2.SmsPasswordResetExceptionReason.fromJson(
        (jsonSerialization['reason'] as String),
      ),
    );
  }

  _i2.SmsPasswordResetExceptionReason reason;

  /// Returns a shallow copy of this [SmsPasswordResetException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SmsPasswordResetException copyWith({
    _i2.SmsPasswordResetExceptionReason? reason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_auth_sms_core.SmsPasswordResetException',
      'reason': reason.toJson(),
    };
  }

  @override
  String toString() {
    return 'SmsPasswordResetException(reason: $reason)';
  }
}

class _SmsPasswordResetExceptionImpl extends SmsPasswordResetException {
  _SmsPasswordResetExceptionImpl({
    required _i2.SmsPasswordResetExceptionReason reason,
  }) : super._(reason: reason);

  /// Returns a shallow copy of this [SmsPasswordResetException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SmsPasswordResetException copyWith({
    _i2.SmsPasswordResetExceptionReason? reason,
  }) {
    return SmsPasswordResetException(reason: reason ?? this.reason);
  }
}
