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
    final row = await PhoneIdCrypto.db.findFirstRow(
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
    final normalized = normalizePhone(phone);
    final phoneHash = hashPhone(normalized);

    final existingByHash = await PhoneIdCrypto.db.findFirstRow(
      session,
      where: (t) => t.phoneHash.equals(phoneHash),
      transaction: transaction,
    );
    if (existingByHash != null && existingByHash.authUserId != authUserId) {
      throw const PhoneAlreadyBoundException();
    }

    final secretBox = await _encryptPhone(normalized);
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
