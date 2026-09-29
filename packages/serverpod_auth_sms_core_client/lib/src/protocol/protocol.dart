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
import 'exceptions/sms_account_request_exception.dart' as _i2;
import 'exceptions/sms_account_request_exception_reason.dart' as _i3;
import 'exceptions/sms_login_exception.dart' as _i4;
import 'exceptions/sms_login_exception_reason.dart' as _i5;
import 'exceptions/sms_password_reset_exception.dart' as _i6;
import 'exceptions/sms_password_reset_exception_reason.dart' as _i7;
import 'exceptions/sms_phone_bind_exception.dart' as _i8;
import 'exceptions/sms_phone_bind_exception_reason.dart' as _i9;
import 'sms_bind_and_login_disabled_reason.dart' as _i10;
import 'sms_bind_finish_decision.dart' as _i11;
import 'sms_login_result.dart' as _i12;
import 'sms_password_reset_blocked_reason.dart' as _i13;
import 'sms_same_password_banner.dart' as _i14;
import 'sms_verify_bind_result_v2.dart' as _i15;
import 'sms_verify_password_reset_result.dart' as _i16;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i17;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i18;
export 'exceptions/sms_account_request_exception.dart';
export 'exceptions/sms_account_request_exception_reason.dart';
export 'exceptions/sms_login_exception.dart';
export 'exceptions/sms_login_exception_reason.dart';
export 'exceptions/sms_password_reset_exception.dart';
export 'exceptions/sms_password_reset_exception_reason.dart';
export 'exceptions/sms_phone_bind_exception.dart';
export 'exceptions/sms_phone_bind_exception_reason.dart';
export 'sms_bind_and_login_disabled_reason.dart';
export 'sms_bind_finish_decision.dart';
export 'sms_login_result.dart';
export 'sms_password_reset_blocked_reason.dart';
export 'sms_same_password_banner.dart';
export 'sms_verify_bind_result_v2.dart';
export 'sms_verify_password_reset_result.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    if (className == null) return null;
    if (!className.startsWith('serverpod_auth_sms_core.')) return className;
    return className.substring(24);
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.SmsAccountRequestException) {
      return _i2.SmsAccountRequestException.fromJson(data) as T;
    }
    if (t == _i3.SmsAccountRequestExceptionReason) {
      return _i3.SmsAccountRequestExceptionReason.fromJson(data) as T;
    }
    if (t == _i4.SmsLoginException) {
      return _i4.SmsLoginException.fromJson(data) as T;
    }
    if (t == _i5.SmsLoginExceptionReason) {
      return _i5.SmsLoginExceptionReason.fromJson(data) as T;
    }
    if (t == _i6.SmsPasswordResetException) {
      return _i6.SmsPasswordResetException.fromJson(data) as T;
    }
    if (t == _i7.SmsPasswordResetExceptionReason) {
      return _i7.SmsPasswordResetExceptionReason.fromJson(data) as T;
    }
    if (t == _i8.SmsPhoneBindException) {
      return _i8.SmsPhoneBindException.fromJson(data) as T;
    }
    if (t == _i9.SmsPhoneBindExceptionReason) {
      return _i9.SmsPhoneBindExceptionReason.fromJson(data) as T;
    }
    if (t == _i10.SmsBindAndLoginDisabledReason) {
      return _i10.SmsBindAndLoginDisabledReason.fromJson(data) as T;
    }
    if (t == _i11.SmsBindFinishDecision) {
      return _i11.SmsBindFinishDecision.fromJson(data) as T;
    }
    if (t == _i12.SmsVerifyLoginResult) {
      return _i12.SmsVerifyLoginResult.fromJson(data) as T;
    }
    if (t == _i13.SmsPasswordResetBlockedReason) {
      return _i13.SmsPasswordResetBlockedReason.fromJson(data) as T;
    }
    if (t == _i14.SmsSamePasswordBanner) {
      return _i14.SmsSamePasswordBanner.fromJson(data) as T;
    }
    if (t == _i15.SmsVerifyBindResultV2) {
      return _i15.SmsVerifyBindResultV2.fromJson(data) as T;
    }
    if (t == _i16.SmsVerifyPasswordResetResult) {
      return _i16.SmsVerifyPasswordResetResult.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.SmsAccountRequestException?>()) {
      return (data != null
              ? _i2.SmsAccountRequestException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i3.SmsAccountRequestExceptionReason?>()) {
      return (data != null
              ? _i3.SmsAccountRequestExceptionReason.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i4.SmsLoginException?>()) {
      return (data != null ? _i4.SmsLoginException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.SmsLoginExceptionReason?>()) {
      return (data != null ? _i5.SmsLoginExceptionReason.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.SmsPasswordResetException?>()) {
      return (data != null
              ? _i6.SmsPasswordResetException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i7.SmsPasswordResetExceptionReason?>()) {
      return (data != null
              ? _i7.SmsPasswordResetExceptionReason.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i8.SmsPhoneBindException?>()) {
      return (data != null ? _i8.SmsPhoneBindException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i9.SmsPhoneBindExceptionReason?>()) {
      return (data != null
              ? _i9.SmsPhoneBindExceptionReason.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i10.SmsBindAndLoginDisabledReason?>()) {
      return (data != null
              ? _i10.SmsBindAndLoginDisabledReason.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i11.SmsBindFinishDecision?>()) {
      return (data != null ? _i11.SmsBindFinishDecision.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i12.SmsVerifyLoginResult?>()) {
      return (data != null ? _i12.SmsVerifyLoginResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i13.SmsPasswordResetBlockedReason?>()) {
      return (data != null
              ? _i13.SmsPasswordResetBlockedReason.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i14.SmsSamePasswordBanner?>()) {
      return (data != null ? _i14.SmsSamePasswordBanner.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i15.SmsVerifyBindResultV2?>()) {
      return (data != null ? _i15.SmsVerifyBindResultV2.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.SmsVerifyPasswordResetResult?>()) {
      return (data != null
              ? _i16.SmsVerifyPasswordResetResult.fromJson(data)
              : null)
          as T;
    }
    try {
      return _i17.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i18.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.SmsAccountRequestException => 'SmsAccountRequestException',
      _i3.SmsAccountRequestExceptionReason =>
        'SmsAccountRequestExceptionReason',
      _i4.SmsLoginException => 'SmsLoginException',
      _i5.SmsLoginExceptionReason => 'SmsLoginExceptionReason',
      _i6.SmsPasswordResetException => 'SmsPasswordResetException',
      _i7.SmsPasswordResetExceptionReason => 'SmsPasswordResetExceptionReason',
      _i8.SmsPhoneBindException => 'SmsPhoneBindException',
      _i9.SmsPhoneBindExceptionReason => 'SmsPhoneBindExceptionReason',
      _i10.SmsBindAndLoginDisabledReason => 'SmsBindAndLoginDisabledReason',
      _i11.SmsBindFinishDecision => 'SmsBindFinishDecision',
      _i12.SmsVerifyLoginResult => 'SmsVerifyLoginResult',
      _i13.SmsPasswordResetBlockedReason => 'SmsPasswordResetBlockedReason',
      _i14.SmsSamePasswordBanner => 'SmsSamePasswordBanner',
      _i15.SmsVerifyBindResultV2 => 'SmsVerifyBindResultV2',
      _i16.SmsVerifyPasswordResetResult => 'SmsVerifyPasswordResetResult',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'serverpod_auth_sms_core.',
        '',
      );
    }

    switch (data) {
      case _i2.SmsAccountRequestException():
        return 'SmsAccountRequestException';
      case _i3.SmsAccountRequestExceptionReason():
        return 'SmsAccountRequestExceptionReason';
      case _i4.SmsLoginException():
        return 'SmsLoginException';
      case _i5.SmsLoginExceptionReason():
        return 'SmsLoginExceptionReason';
      case _i6.SmsPasswordResetException():
        return 'SmsPasswordResetException';
      case _i7.SmsPasswordResetExceptionReason():
        return 'SmsPasswordResetExceptionReason';
      case _i8.SmsPhoneBindException():
        return 'SmsPhoneBindException';
      case _i9.SmsPhoneBindExceptionReason():
        return 'SmsPhoneBindExceptionReason';
      case _i10.SmsBindAndLoginDisabledReason():
        return 'SmsBindAndLoginDisabledReason';
      case _i11.SmsBindFinishDecision():
        return 'SmsBindFinishDecision';
      case _i12.SmsVerifyLoginResult():
        return 'SmsVerifyLoginResult';
      case _i13.SmsPasswordResetBlockedReason():
        return 'SmsPasswordResetBlockedReason';
      case _i14.SmsSamePasswordBanner():
        return 'SmsSamePasswordBanner';
      case _i15.SmsVerifyBindResultV2():
        return 'SmsVerifyBindResultV2';
      case _i16.SmsVerifyPasswordResetResult():
        return 'SmsVerifyPasswordResetResult';
    }
    className = _i17.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    className = _i18.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'SmsAccountRequestException') {
      return deserialize<_i2.SmsAccountRequestException>(data['data']);
    }
    if (dataClassName == 'SmsAccountRequestExceptionReason') {
      return deserialize<_i3.SmsAccountRequestExceptionReason>(data['data']);
    }
    if (dataClassName == 'SmsLoginException') {
      return deserialize<_i4.SmsLoginException>(data['data']);
    }
    if (dataClassName == 'SmsLoginExceptionReason') {
      return deserialize<_i5.SmsLoginExceptionReason>(data['data']);
    }
    if (dataClassName == 'SmsPasswordResetException') {
      return deserialize<_i6.SmsPasswordResetException>(data['data']);
    }
    if (dataClassName == 'SmsPasswordResetExceptionReason') {
      return deserialize<_i7.SmsPasswordResetExceptionReason>(data['data']);
    }
    if (dataClassName == 'SmsPhoneBindException') {
      return deserialize<_i8.SmsPhoneBindException>(data['data']);
    }
    if (dataClassName == 'SmsPhoneBindExceptionReason') {
      return deserialize<_i9.SmsPhoneBindExceptionReason>(data['data']);
    }
    if (dataClassName == 'SmsBindAndLoginDisabledReason') {
      return deserialize<_i10.SmsBindAndLoginDisabledReason>(data['data']);
    }
    if (dataClassName == 'SmsBindFinishDecision') {
      return deserialize<_i11.SmsBindFinishDecision>(data['data']);
    }
    if (dataClassName == 'SmsVerifyLoginResult') {
      return deserialize<_i12.SmsVerifyLoginResult>(data['data']);
    }
    if (dataClassName == 'SmsPasswordResetBlockedReason') {
      return deserialize<_i13.SmsPasswordResetBlockedReason>(data['data']);
    }
    if (dataClassName == 'SmsSamePasswordBanner') {
      return deserialize<_i14.SmsSamePasswordBanner>(data['data']);
    }
    if (dataClassName == 'SmsVerifyBindResultV2') {
      return deserialize<_i15.SmsVerifyBindResultV2>(data['data']);
    }
    if (dataClassName == 'SmsVerifyPasswordResetResult') {
      return deserialize<_i16.SmsVerifyPasswordResetResult>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i17.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i18.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i17.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i18.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
