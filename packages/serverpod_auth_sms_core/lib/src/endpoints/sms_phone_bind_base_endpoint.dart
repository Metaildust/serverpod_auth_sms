import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../sms_idp.dart';

abstract class SmsPhoneBindBaseEndpoint extends Endpoint {
  SmsIdp get smsIdp => AuthServices.instance.smsIdp;

  Future<bool> isPhoneBound(Session session) async {
    final authUserId = _requireAuthUserId(session);
    return smsIdp.isPhoneBound(session, authUserId: authUserId);
  }

  Future<UuidValue> startBindPhone(
    Session session, {
    required String phone,
  }) async {
    final authUserId = _requireAuthUserId(session);
    return smsIdp.startBindPhone(
      session,
      authUserId: authUserId,
      phone: phone,
    );
  }

  Future<String> verifyBindCode(
    Session session, {
    required UuidValue bindRequestId,
    required String verificationCode,
  }) async {
    _requireAuthUserId(session);
    return smsIdp.verifyBindCode(
      session,
      bindRequestId: bindRequestId,
      verificationCode: verificationCode,
    );
  }

  Future<void> finishBindPhone(
    Session session, {
    required String bindToken,
    required String phone,
  }) async {
    final authUserId = _requireAuthUserId(session);
    await smsIdp.finishBindPhone(
      session,
      authUserId: authUserId,
      bindToken: bindToken,
      phone: phone,
    );
  }

  UuidValue _requireAuthUserId(Session session) {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.unauthenticated,
      );
    }
    return authInfo.authUserId;
  }
}
