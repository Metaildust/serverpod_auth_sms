import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';
import '../sms_idp.dart';

abstract class SmsIdpBaseEndpoint extends Endpoint {
  SmsIdp get smsIdp => AuthServices.instance.smsIdp;

  @unauthenticatedClientCall
  Future<AuthSuccess> finishLogin(
    Session session, {
    required String loginToken,
    required String phone,
    String? password,
  }) async {
    return smsIdp.finishLogin(
      session,
      loginToken: loginToken,
      phone: phone,
      password: password,
    );
  }

  @unauthenticatedClientCall
  Future<void> finishPasswordReset(
    Session session, {
    required String resetToken,
    required String phone,
    required String password,
  }) async {
    return smsIdp.finishPasswordReset(
      session,
      resetToken: resetToken,
      phone: phone,
      password: password,
    );
  }

  @unauthenticatedClientCall
  Future<AuthSuccess> finishRegistration(
    Session session, {
    required String registrationToken,
    required String phone,
    required String password,
  }) async {
    return smsIdp.finishRegistration(
      session,
      registrationToken: registrationToken,
      phone: phone,
      password: password,
    );
  }

  @unauthenticatedClientCall
  Future<AuthSuccess> loginWithPassword(
    Session session, {
    required String phone,
    required String password,
  }) async {
    return smsIdp.loginWithPassword(session, phone: phone, password: password);
  }

  @unauthenticatedClientCall
  Future<UuidValue> startLogin(Session session, {required String phone}) async {
    return smsIdp.startLogin(session, phone: phone);
  }

  @unauthenticatedClientCall
  Future<UuidValue> startPasswordReset(
    Session session, {
    required String phone,
  }) async {
    return smsIdp.startPasswordReset(session, phone: phone);
  }

  @unauthenticatedClientCall
  Future<UuidValue> startRegistration(
    Session session, {
    required String phone,
  }) async {
    return smsIdp.startRegistration(session, phone: phone);
  }

  @unauthenticatedClientCall
  Future<SmsVerifyLoginResult> verifyLoginCode(
    Session session, {
    required UuidValue loginRequestId,
    required String verificationCode,
  }) async {
    return smsIdp.verifyLoginCode(
      session,
      loginRequestId: loginRequestId,
      verificationCode: verificationCode,
    );
  }

  @unauthenticatedClientCall
  Future<SmsVerifyPasswordResetResult> verifyPasswordResetCode(
    Session session, {
    required UuidValue resetRequestId,
    required String verificationCode,
  }) async {
    return smsIdp.verifyPasswordResetCode(
      session,
      resetRequestId: resetRequestId,
      verificationCode: verificationCode,
    );
  }

  @unauthenticatedClientCall
  Future<String> verifyRegistrationCode(
    Session session, {
    required UuidValue accountRequestId,
    required String verificationCode,
  }) async {
    return smsIdp.verifyRegistrationCode(
      session,
      accountRequestId: accountRequestId,
      verificationCode: verificationCode,
    );
  }
}
