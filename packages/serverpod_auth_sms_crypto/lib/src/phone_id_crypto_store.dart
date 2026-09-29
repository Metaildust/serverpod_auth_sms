import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' hide Hmac;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart';

import 'generated/protocol.dart';

class PhoneIdCryptoStore extends PhoneIdStore {
  final String pepper;
  final SecretKey _secretKey;
  final Cipher _cipher = AesGcm.with256bits();

  PhoneIdCryptoStore({
    required this.pepper,
    required List<int> encryptionKeyBytes,
  }) : _secretKey = SecretKey(encryptionKeyBytes);

  factory PhoneIdCryptoStore.fromPasswords(Serverpod serverpod) {
    final pepper = serverpod.getPassword('phoneHashPepper');
    if (pepper == null || pepper.isEmpty) {
      throw StateError('phoneHashPepper must be configured in passwords.');
    }
    final keyBase64 = serverpod.getPassword('phoneEncryptionKey');
    if (keyBase64 == null || keyBase64.isEmpty) {
      throw StateError('phoneEncryptionKey must be configured in passwords.');
    }
    final keyBytes = base64Decode(keyBase64);
    if (keyBytes.length != 32) {
      throw StateError('phoneEncryptionKey must be a 32-byte base64 string.');
    }
    return PhoneIdCryptoStore(pepper: pepper, encryptionKeyBytes: keyBytes);
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
    final row = await PhoneIdCrypto.db.findFirstRow(
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
    final rows = await PhoneIdCrypto.db.find(
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
    final dbRows = await PhoneIdCrypto.db.find(
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
          PhoneStoredRow(
            userId: row.authUserId.uuid,
            phoneHash: row.phoneHash,
            plain: null,
          ),
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
    final secretBox = await _encryptPhone(updated.plain ?? canonicalPhone(phone));
    try {
      await PhoneIdCrypto.db.updateRow(
        session,
        row.copyWith(
          phoneHash: updated.phoneHash,
          phoneEncrypted: _toByteData(secretBox.cipherText),
          nonce: _toByteData(secretBox.nonce),
          mac: _toByteData(secretBox.mac.bytes),
        ),
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
    final count = await PhoneIdCrypto.db.count(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      transaction: transaction,
    );
    return count > 0;
  }

  @override
  Future<String?> getPhone(
    Session session, {
    required UuidValue authUserId,
    Transaction? transaction,
  }) async {
    final row = await PhoneIdCrypto.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      transaction: transaction,
    );
    if (row == null) return null;
    return _decryptPhone(row);
  }

  @override
  Future<void> bindPhone(
    Session session, {
    required UuidValue authUserId,
    required String phone,
    required bool allowRebind,
    Transaction? transaction,
  }) async {
    final canonical = canonicalPhone(phone);
    final phoneHash = hashCanonicalPhone(phone);

    final existingByHash = await PhoneIdCrypto.db.findFirstRow(
      session,
      where: (t) => t.phoneHash.equals(phoneHash),
      transaction: transaction,
    );
    if (existingByHash != null && existingByHash.authUserId != authUserId) {
      throw const PhoneAlreadyBoundException();
    }

    final secretBox = await _encryptPhone(canonical);
    final encrypted = _toByteData(secretBox.cipherText);
    final nonce = _toByteData(secretBox.nonce);
    final mac = _toByteData(secretBox.mac.bytes);

    final existingByUser = await PhoneIdCrypto.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      transaction: transaction,
    );
    if (existingByUser != null) {
      if (existingByUser.phoneHash == phoneHash) return;
      if (!allowRebind) throw const PhoneRebindNotAllowedException();
      await PhoneIdCrypto.db.updateRow(
        session,
        existingByUser.copyWith(
          phoneHash: phoneHash,
          phoneEncrypted: encrypted,
          nonce: nonce,
          mac: mac,
        ),
        transaction: transaction,
      );
      return;
    }

    await PhoneIdCrypto.db.insertRow(
      session,
      PhoneIdCrypto(
        authUserId: authUserId,
        phoneHash: phoneHash,
        phoneEncrypted: encrypted,
        nonce: nonce,
        mac: mac,
      ),
      transaction: transaction,
    );
  }

  /// 按给定哈希写入明文。用来准备「只有旧哈希、明文仍带横杠」的行，不改成规范串。
  Future<void> insertPlainRow(
    Session session, {
    required UuidValue authUserId,
    required String phoneHash,
    required String plain,
    Transaction? transaction,
  }) async {
    final secretBox = await _encryptPhone(plain);
    await PhoneIdCrypto.db.insertRow(
      session,
      PhoneIdCrypto(
        authUserId: authUserId,
        phoneHash: phoneHash,
        phoneEncrypted: _toByteData(secretBox.cipherText),
        nonce: _toByteData(secretBox.nonce),
        mac: _toByteData(secretBox.mac.bytes),
      ),
      transaction: transaction,
    );
  }

  Future<void> unbindPhoneByHash(
    Session session, {
    required UuidValue authUserId,
    required String phoneHash,
    Transaction? transaction,
  }) async {
    await PhoneIdCrypto.db.deleteWhere(
      session,
      where: (t) =>
          t.authUserId.equals(authUserId) & t.phoneHash.equals(phoneHash),
      transaction: transaction,
    );
  }

  Future<SecretBox> _encryptPhone(String normalized) async {
    final bytes = utf8.encode(normalized);
    final nonce = _cipher.newNonce();
    return _cipher.encrypt(bytes, secretKey: _secretKey, nonce: nonce);
  }

  Future<String> _decryptPhone(PhoneIdCrypto row) async {
    final secretBox = SecretBox(
      _toUint8List(row.phoneEncrypted),
      nonce: _toUint8List(row.nonce),
      mac: Mac(_toUint8List(row.mac)),
    );
    final clear = await _cipher.decrypt(secretBox, secretKey: _secretKey);
    return utf8.decode(clear);
  }

  Uint8List _toUint8List(ByteData data) {
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  ByteData _toByteData(List<int> bytes) {
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}
