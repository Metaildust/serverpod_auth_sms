import 'package:serverpod/serverpod.dart';

import 'phone_normalizer.dart';

class PhoneAlreadyBoundException implements Exception {
  final String message;
  const PhoneAlreadyBoundException([this.message = 'Phone already bound']);

  @override
  String toString() => 'PhoneAlreadyBoundException: $message';
}

class PhoneRebindNotAllowedException implements Exception {
  final String message;
  const PhoneRebindNotAllowedException([this.message = 'Phone rebind disabled']);

  @override
  String toString() => 'PhoneRebindNotAllowedException: $message';
}

abstract class PhoneIdStore {
  String normalizePhone(String phone) => normalizePhoneNumber(phone);

  String hashPhone(String phone);

  Future<UuidValue?> findAuthUserIdByPhoneHash(
    Session session, {
    required String phoneHash,
    Transaction? transaction,
  });

  Future<UuidValue?> findAuthUserIdByPhone(
    Session session, {
    required String phone,
    Transaction? transaction,
  }) async {
    final normalized = normalizePhone(phone);
    return findAuthUserIdByPhoneHash(
      session,
      phoneHash: hashPhone(normalized),
      transaction: transaction,
    );
  }

  Future<bool> isPhoneBoundForUser(
    Session session, {
    required UuidValue authUserId,
    Transaction? transaction,
  });

  Future<void> bindPhone(
    Session session, {
    required UuidValue authUserId,
    required String phone,
    required bool allowRebind,
    Transaction? transaction,
  });

  Future<String?> getPhone(
    Session session, {
    required UuidValue authUserId,
    Transaction? transaction,
  }) async {
    return null;
  }
}
