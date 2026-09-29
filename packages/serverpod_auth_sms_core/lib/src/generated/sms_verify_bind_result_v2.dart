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
import 'sms_bind_and_login_disabled_reason.dart' as _i2;

/// SMS bind-code verification result (V2, conflict-aware).
abstract class SmsVerifyBindResultV2
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  SmsVerifyBindResultV2._({
    required this.bindToken,
    required this.hasConflict,
    this.expectedConflictOwnerAuthUserId,
    required this.bindAndLoginEnabled,
    this.bindAndLoginDisabledReason,
  });

  factory SmsVerifyBindResultV2({
    required String bindToken,
    required bool hasConflict,
    _i1.UuidValue? expectedConflictOwnerAuthUserId,
    required bool bindAndLoginEnabled,
    _i2.SmsBindAndLoginDisabledReason? bindAndLoginDisabledReason,
  }) = _SmsVerifyBindResultV2Impl;

  factory SmsVerifyBindResultV2.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SmsVerifyBindResultV2(
      bindToken: jsonSerialization['bindToken'] as String,
      hasConflict: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['hasConflict'],
      ),
      expectedConflictOwnerAuthUserId:
          jsonSerialization['expectedConflictOwnerAuthUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['expectedConflictOwnerAuthUserId'],
            ),
      bindAndLoginEnabled: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['bindAndLoginEnabled'],
      ),
      bindAndLoginDisabledReason:
          jsonSerialization['bindAndLoginDisabledReason'] == null
          ? null
          : _i2.SmsBindAndLoginDisabledReason.fromJson(
              (jsonSerialization['bindAndLoginDisabledReason'] as String),
            ),
    );
  }

  /// Verification token used by finishBindPhoneV2.
  String bindToken;

  /// Whether phone is currently bound by another account.
  bool hasConflict;

  /// Conflict owner snapshot. Used by finish phase recheck.
  _i1.UuidValue? expectedConflictOwnerAuthUserId;

  /// Whether bindAndLogin option is available.
  bool bindAndLoginEnabled;

  /// Why bindAndLogin is disabled (if disabled).
  _i2.SmsBindAndLoginDisabledReason? bindAndLoginDisabledReason;

  /// Returns a shallow copy of this [SmsVerifyBindResultV2]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SmsVerifyBindResultV2 copyWith({
    String? bindToken,
    bool? hasConflict,
    _i1.UuidValue? expectedConflictOwnerAuthUserId,
    bool? bindAndLoginEnabled,
    _i2.SmsBindAndLoginDisabledReason? bindAndLoginDisabledReason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_auth_sms_core.SmsVerifyBindResultV2',
      'bindToken': bindToken,
      'hasConflict': hasConflict,
      if (expectedConflictOwnerAuthUserId != null)
        'expectedConflictOwnerAuthUserId': expectedConflictOwnerAuthUserId
            ?.toJson(),
      'bindAndLoginEnabled': bindAndLoginEnabled,
      if (bindAndLoginDisabledReason != null)
        'bindAndLoginDisabledReason': bindAndLoginDisabledReason?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_auth_sms_core.SmsVerifyBindResultV2',
      'bindToken': bindToken,
      'hasConflict': hasConflict,
      if (expectedConflictOwnerAuthUserId != null)
        'expectedConflictOwnerAuthUserId': expectedConflictOwnerAuthUserId
            ?.toJson(),
      'bindAndLoginEnabled': bindAndLoginEnabled,
      if (bindAndLoginDisabledReason != null)
        'bindAndLoginDisabledReason': bindAndLoginDisabledReason?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SmsVerifyBindResultV2Impl extends SmsVerifyBindResultV2 {
  _SmsVerifyBindResultV2Impl({
    required String bindToken,
    required bool hasConflict,
    _i1.UuidValue? expectedConflictOwnerAuthUserId,
    required bool bindAndLoginEnabled,
    _i2.SmsBindAndLoginDisabledReason? bindAndLoginDisabledReason,
  }) : super._(
         bindToken: bindToken,
         hasConflict: hasConflict,
         expectedConflictOwnerAuthUserId: expectedConflictOwnerAuthUserId,
         bindAndLoginEnabled: bindAndLoginEnabled,
         bindAndLoginDisabledReason: bindAndLoginDisabledReason,
       );

  /// Returns a shallow copy of this [SmsVerifyBindResultV2]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SmsVerifyBindResultV2 copyWith({
    String? bindToken,
    bool? hasConflict,
    Object? expectedConflictOwnerAuthUserId = _Undefined,
    bool? bindAndLoginEnabled,
    Object? bindAndLoginDisabledReason = _Undefined,
  }) {
    return SmsVerifyBindResultV2(
      bindToken: bindToken ?? this.bindToken,
      hasConflict: hasConflict ?? this.hasConflict,
      expectedConflictOwnerAuthUserId:
          expectedConflictOwnerAuthUserId is _i1.UuidValue?
          ? expectedConflictOwnerAuthUserId
          : this.expectedConflictOwnerAuthUserId,
      bindAndLoginEnabled: bindAndLoginEnabled ?? this.bindAndLoginEnabled,
      bindAndLoginDisabledReason:
          bindAndLoginDisabledReason is _i2.SmsBindAndLoginDisabledReason?
          ? bindAndLoginDisabledReason
          : this.bindAndLoginDisabledReason,
    );
  }
}
