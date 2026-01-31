import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart';

import 'generated/protocol.dart';

class PhoneIdHashStore extends PhoneIdStore {
  final String pepper;

  PhoneIdHashStore({required this.pepper});

  factory PhoneIdHashStore.fromPasswords(Serverpod serverpod) {
    final pepper = serverpod.getPassword('phoneHashPepper');
    if (pepper == null || pepper.isEmpty) {
      throw StateError('phoneHashPepper must be configured in passwords.');
    }
    return PhoneIdHashStore(pepper: pepper);
  }

  @override
  String hashPhone(String phone) {
    final normalized = normalizePhone(phone);
    final hmac = Hmac(sha256, utf8.encode(pepper));
    return hmac.convert(utf8.encode(normalized)).toString();
  }

  @override
  Future<UuidValue?> findAuthUserIdByPhoneHash(
    Session session, {
    required String phoneHash,
    Transaction? transaction,
  }) async {
    final row = await PhoneIdHash.db.findFirstRow(
      session,
      where: (t) => t.phoneHash.equals(phoneHash),
      transaction: transaction,
    );
    return row?.authUserId;
  }

  @override
  Future<bool> isPhoneBoundForUser(
    Session session, {
    required UuidValue authUserId,
    Transaction? transaction,
  }) async {
    final count = await PhoneIdHash.db.count(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      transaction: transaction,
    );
    return count > 0;
  }

  @override
  Future<void> bindPhone(
    Session session, {
    required UuidValue authUserId,
    required String phone,
    required bool allowRebind,
    Transaction? transaction,
  }) async {
    final normalized = normalizePhone(phone);
    final phoneHash = hashPhone(normalized);

    final existingByHash = await PhoneIdHash.db.findFirstRow(
      session,
      where: (t) => t.phoneHash.equals(phoneHash),
      transaction: transaction,
    );
    if (existingByHash != null && existingByHash.authUserId != authUserId) {
      throw const PhoneAlreadyBoundException();
    }

    final existingByUser = await PhoneIdHash.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      transaction: transaction,
    );
    if (existingByUser != null) {
      if (existingByUser.phoneHash == phoneHash) return;
      if (!allowRebind) throw const PhoneRebindNotAllowedException();
      await PhoneIdHash.db.updateRow(
        session,
        existingByUser.copyWith(phoneHash: phoneHash),
        transaction: transaction,
      );
      return;
    }

    await PhoneIdHash.db.insertRow(
      session,
      PhoneIdHash(authUserId: authUserId, phoneHash: phoneHash),
      transaction: transaction,
    );
  }
}
