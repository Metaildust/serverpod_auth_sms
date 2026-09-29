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
  String hashPrepared(String prepared) {
    final hmac = Hmac(sha256, utf8.encode(pepper));
    return hmac.convert(utf8.encode(prepared)).toString();
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
  Future<PhoneMatch> matchHashes(
    Session session, {
    required List<String> hashes,
    required String legacyHash,
    required String canonicalHash,
    Transaction? transaction,
  }) async {
    final unique = hashes.toSet().toList();
    if (unique.isEmpty) {
      return PhoneMatch.none(
        legacyHash: legacyHash,
        canonicalHash: canonicalHash,
      );
    }
    final rows = await PhoneIdHash.db.find(
      session,
      where: (t) => unique.length == 1
          ? t.phoneHash.equals(unique.first)
          : (t.phoneHash.equals(unique[0]) | t.phoneHash.equals(unique[1])),
      transaction: transaction,
    );
    final userIds = <UuidValue>[];
    for (final row in rows) {
      if (!userIds.contains(row.authUserId)) {
        userIds.add(row.authUserId);
      }
    }
    return PhoneMatch(
      userIds: userIds,
      storedHash: userIds.length == 1 ? rows.first.phoneHash : null,
      legacyHash: legacyHash,
      canonicalHash: canonicalHash,
    );
  }

  @override
  Future<void> rewriteMatchedPhoneToCanonical(
    Session session, {
    required String phone,
    required UuidValue authUserId,
    Transaction? transaction,
  }) async {
    final legacy = hashLegacyPhone(phone);
    final canon = hashCanonicalPhone(phone);
    final unique = {legacy, canon}.toList();
    final dbRows = await PhoneIdHash.db.find(
      session,
      where: (t) => unique.length == 1
          ? t.phoneHash.equals(unique.first)
          : (t.phoneHash.equals(unique[0]) | t.phoneHash.equals(unique[1])),
      transaction: transaction,
    );
    final plan = rewriteAfterSuccessfulLogin(
      rawPhone: phone,
      rows: [
        for (final row in dbRows)
          PhoneStoredRow(userId: row.authUserId.uuid, phoneHash: row.phoneHash),
      ],
    );
    if (plan.status != PhoneLoginRewrite.one || plan.userId != authUserId.uuid) {
      throw const PhoneIdentityConflictException();
    }
    final current = dbRows.where((row) => row.authUserId == authUserId);
    if (current.length != 1) {
      throw const PhoneIdentityConflictException();
    }
    final row = current.single;
    final updated = plan.rows.singleWhere((item) => item.userId == authUserId.uuid);
    if (row.phoneHash == updated.phoneHash) return;
    try {
      await PhoneIdHash.db.updateRow(
        session,
        row.copyWith(phoneHash: updated.phoneHash),
        transaction: transaction,
      );
    } on DatabaseException catch (error) {
      if (isPhoneHashUniqueViolation(error)) {
        throw const PhoneIdentityConflictException();
      }
      rethrow;
    }
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
    final phoneHash = hashCanonicalPhone(phone);

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

  Future<void> unbindPhoneByHash(
    Session session, {
    required UuidValue authUserId,
    required String phoneHash,
    Transaction? transaction,
  }) async {
    await PhoneIdHash.db.deleteWhere(
      session,
      where: (t) =>
          t.authUserId.equals(authUserId) & t.phoneHash.equals(phoneHash),
      transaction: transaction,
    );
  }
}
