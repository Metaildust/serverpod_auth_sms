import 'package:serverpod/serverpod.dart';

import 'phone_match.dart';
import 'phone_normalizer.dart';

class PhoneAlreadyBoundException implements Exception {
  final String message;
  const PhoneAlreadyBoundException([this.message = 'Phone already bound']);

  @override
  String toString() => 'PhoneAlreadyBoundException: $message';
}

class PhoneRebindNotAllowedException implements Exception {
  final String message;
  const PhoneRebindNotAllowedException([
    this.message = 'Phone rebind disabled',
  ]);

  @override
  String toString() => 'PhoneRebindNotAllowedException: $message';
}

abstract class PhoneIdStore {
  String normalizePhone(String phone) => normalizePhoneNumber(phone);

  String canonicalPhone(String phone) => canonicalPhoneNumber(phone);

  /// HMAC，不再做规范化。新旧哈希都走这里，避免套两层函数。
  String hashPrepared(String prepared);

  /// 旧哈希 = HMAC(旧函数(原始输入))。
  String hashLegacyPhone(String phone) =>
      hashPrepared(normalizePhoneNumber(phone));

  /// 新哈希 = HMAC(新函数(原始输入))。禁止再经 [hashPhone]。
  String hashCanonicalPhone(String phone) =>
      hashPrepared(canonicalPhoneNumber(phone));

  /// 兼容旧调用：仍然只算旧哈希。双读不得只用它。
  String hashPhone(String phone) => hashLegacyPhone(phone);

  String requestFingerprint(String phone) => phoneRequestFingerprint(
    legacyHash: hashLegacyPhone(phone),
    canonicalHash: hashCanonicalPhone(phone),
  );

  List<String> hashesOfFingerprint(String stored) =>
      hashesFromPhoneFingerprint(stored);

  Future<UuidValue?> findAuthUserIdByPhoneHash(
    Session session, {
    required String phoneHash,
    Transaction? transaction,
  });

  Future<PhoneMatch> matchPhone(
    Session session, {
    required String phone,
    Transaction? transaction,
  }) {
    return matchHashes(
      session,
      hashes: [
        hashLegacyPhone(phone),
        hashCanonicalPhone(phone),
      ],
      legacyHash: hashLegacyPhone(phone),
      canonicalHash: hashCanonicalPhone(phone),
      transaction: transaction,
    );
  }

  Future<PhoneMatch> matchFingerprint(
    Session session, {
    required String fingerprint,
    required String legacyHash,
    required String canonicalHash,
    Transaction? transaction,
  }) {
    return matchHashes(
      session,
      hashes: hashesOfFingerprint(fingerprint),
      legacyHash: legacyHash,
      canonicalHash: canonicalHash,
      transaction: transaction,
    );
  }

  Future<PhoneMatch> matchHashes(
    Session session, {
    required List<String> hashes,
    required String legacyHash,
    required String canonicalHash,
    Transaction? transaction,
  });

  /// 登录成功的同一事务里只改这一行。冲突或唯一约束时抛 [PhoneIdentityConflictException]，不改行。
  Future<void> rewriteMatchedPhoneToCanonical(
    Session session, {
    required String phone,
    required UuidValue authUserId,
    Transaction? transaction,
  });

  /// 登录成功且只命中一个用户时，把这一行改成规范哈希。规范哈希被别人占用则整笔冲突、原样返回。
  PhoneLoginRewriteResult rewriteAfterSuccessfulLogin({
    required String rawPhone,
    required List<PhoneStoredRow> rows,
  }) {
    final legacy = hashLegacyPhone(rawPhone);
    final canon = hashCanonicalPhone(rawPhone);
    final hits = rows
        .where((row) => row.phoneHash == legacy || row.phoneHash == canon)
        .toList();
    final users = hits.map((row) => row.userId).toSet();
    if (users.length > 1) {
      return PhoneLoginRewriteResult(
        status: PhoneLoginRewrite.conflict,
        rows: rows,
      );
    }
    if (users.isEmpty) {
      return PhoneLoginRewriteResult(
        status: PhoneLoginRewrite.none,
        rows: rows,
      );
    }
    final userId = users.single;
    final canonicalPlain = canonicalPhoneNumber(rawPhone);
    final next = [
      for (final row in rows)
        if (row.userId == userId && row.phoneHash != canon)
          PhoneStoredRow(
            userId: row.userId,
            phoneHash: canon,
            plain: canonicalPlain,
          )
        else
          row,
    ];
    return PhoneLoginRewriteResult(
      status: PhoneLoginRewrite.one,
      rows: next,
      userId: userId,
    );
  }

  Future<UuidValue?> findAuthUserIdByPhone(
    Session session, {
    required String phone,
    Transaction? transaction,
  }) async {
    final match = await matchPhone(
      session,
      phone: phone,
      transaction: transaction,
    );
    if (match.conflict) {
      throw const PhoneIdentityConflictException();
    }
    return match.userId;
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

  Future<void> unbindPhoneByHash(
    Session session, {
    required UuidValue authUserId,
    required String phoneHash,
    Transaction? transaction,
  });

  Future<void> unbindPhone(
    Session session, {
    required UuidValue authUserId,
    required String phone,
    Transaction? transaction,
  }) async {
    final match = await matchPhone(
      session,
      phone: phone,
      transaction: transaction,
    );
    // 删双读得到的那一格，同时删旧哈希和新哈希。禁止只算 HMAC(旧函数(旧函数(原始)))。
    final hashes = <String>{
      hashLegacyPhone(phone),
      hashCanonicalPhone(phone),
    };
    final stored = match.storedHash;
    if (stored != null && stored.isNotEmpty) {
      hashes.add(stored);
    }
    for (final phoneHash in hashes) {
      await unbindPhoneByHash(
        session,
        authUserId: authUserId,
        phoneHash: phoneHash,
        transaction: transaction,
      );
    }
  }

  Future<String?> getPhone(
    Session session, {
    required UuidValue authUserId,
    Transaction? transaction,
  }) async {
    return null;
  }
}

/// 对原始号码双读。两个用户时抛错，不挑其中一个，也不改行。
Future<UuidValue?> findSingleUserByPhone(
  PhoneIdStore store,
  Session session, {
  required String phone,
  Transaction? transaction,
}) async {
  final match = await store.matchPhone(
    session,
    phone: phone,
    transaction: transaction,
  );
  if (match.conflict) {
    throw const PhoneIdentityConflictException();
  }
  return match.userId;
}
