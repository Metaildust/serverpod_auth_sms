import 'package:serverpod/serverpod.dart';

/// 同一号码对上两个不同用户。不签发、不合并、不改行。
class PhoneIdentityConflictException implements Exception {
  const PhoneIdentityConflictException();

  @override
  String toString() => 'PhoneIdentityConflictException';
}

/// 查找结果。两个用户时 [conflict] 为真，不得取其中一个。
class PhoneMatch {
  const PhoneMatch({
    required this.userIds,
    required this.storedHash,
    required this.legacyHash,
    required this.canonicalHash,
  });

  final List<UuidValue> userIds;
  final String? storedHash;
  final String legacyHash;
  final String canonicalHash;

  bool get conflict => userIds.length > 1;
  bool get empty => userIds.isEmpty;
  UuidValue? get userId => userIds.length == 1 ? userIds.single : null;

  static PhoneMatch none({
    required String legacyHash,
    required String canonicalHash,
  }) {
    return PhoneMatch(
      userIds: const [],
      storedHash: null,
      legacyHash: legacyHash,
      canonicalHash: canonicalHash,
    );
  }
}

/// 内存中的一行号码存储，供登录改写和两种存储的测试共用。
class PhoneStoredRow {
  const PhoneStoredRow({
    required this.userId,
    required this.phoneHash,
    this.plain,
  });

  final String userId;
  final String phoneHash;
  final String? plain;
}

enum PhoneLoginRewrite { none, one, conflict }

class PhoneLoginRewriteResult {
  const PhoneLoginRewriteResult({
    required this.status,
    required this.rows,
    this.userId,
  });

  final PhoneLoginRewrite status;
  final List<PhoneStoredRow> rows;
  final String? userId;

  bool get loggedIn => status == PhoneLoginRewrite.one;
}

/// 登录请求里记下的指纹。新旧哈希相同则只存一个；不同则 `规范哈希|旧哈希`。
/// 限流 nonce 不使用这个串。
String phoneRequestFingerprint({
  required String legacyHash,
  required String canonicalHash,
}) {
  if (legacyHash == canonicalHash) return canonicalHash;
  return '$canonicalHash|$legacyHash';
}

/// 从请求指纹还原要查的哈希。旧的单段指纹只查那一个。
List<String> hashesFromPhoneFingerprint(String stored) {
  final parts = stored.split('|');
  if (parts.length == 2 && parts.every((part) => part.length == 64)) {
    return parts;
  }
  return [stored];
}

bool isPhoneHashUniqueViolation(Object error) {
  if (error is DatabaseQueryException && error.code == '23505') {
    return true;
  }
  final message = error.toString().toLowerCase();
  return message.contains('23505') || message.contains('duplicate key');
}
