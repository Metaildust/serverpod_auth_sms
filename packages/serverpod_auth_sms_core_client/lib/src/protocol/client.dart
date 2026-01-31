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
import 'dart:async' as _i2;
import 'package:serverpod_auth_sms_core_client/src/protocol/sms_same_password_banter.dart'
    as _i3;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i4;
import 'package:serverpod_auth_sms_core_client/src/protocol/sms_login_result.dart'
    as _i5;

/// {@category Endpoint}
abstract class EndpointSmsAuthUiBase extends _i1.EndpointRef {
  EndpointSmsAuthUiBase(_i1.EndpointCaller caller) : super(caller);

  _i2.Future<_i3.SmsSamePasswordBanter> getSamePasswordBanter();
}

/// {@category Endpoint}
abstract class EndpointSmsIdpBase extends _i1.EndpointRef {
  EndpointSmsIdpBase(_i1.EndpointCaller caller) : super(caller);

  _i2.Future<_i1.UuidValue> startRegistration({required String phone});

  _i2.Future<String> verifyRegistrationCode({
    required _i1.UuidValue accountRequestId,
    required String verificationCode,
  });

  _i2.Future<_i4.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String phone,
    required String password,
  });

  _i2.Future<_i1.UuidValue> startLogin({required String phone});

  _i2.Future<_i5.SmsVerifyLoginResult> verifyLoginCode({
    required _i1.UuidValue loginRequestId,
    required String verificationCode,
  });

  _i2.Future<_i4.AuthSuccess> finishLogin({
    required String loginToken,
    required String phone,
    String? password,
  });
}

/// {@category Endpoint}
abstract class EndpointSmsPhoneBindBase extends _i1.EndpointRef {
  EndpointSmsPhoneBindBase(_i1.EndpointCaller caller) : super(caller);

  _i2.Future<bool> isPhoneBound();

  _i2.Future<_i1.UuidValue> startBindPhone({required String phone});

  _i2.Future<String> verifyBindCode({
    required _i1.UuidValue bindRequestId,
    required String verificationCode,
  });

  _i2.Future<void> finishBindPhone({
    required String bindToken,
    required String phone,
  });
}

class Caller extends _i1.ModuleEndpointCaller {
  Caller(_i1.ServerpodClientShared client) : super(client) {}

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {};
}
