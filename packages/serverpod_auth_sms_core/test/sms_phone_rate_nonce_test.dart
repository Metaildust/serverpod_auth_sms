import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_sms_core_server/src/phone/phone_id_store.dart';
import 'package:serverpod_auth_sms_core_server/src/phone/phone_match.dart';
import 'package:serverpod_auth_sms_core_server/src/sms_idp_utils.dart';
import 'package:test/test.dart';

/// 旧哈希加前缀，用来区分「直接算规范哈希」和「再套一层旧函数」。
class _TagPhoneIdStore extends PhoneIdStore {
  @override
  String hashPrepared(String prepared) => prepared;

  @override
  String hashLegacyPhone(String phone) =>
      'legacy:${super.hashLegacyPhone(phone)}';

  @override
  Future<UuidValue?> findAuthUserIdByPhoneHash(
    Session session, {
    required String phoneHash,
    Transaction? transaction,
  }) async => null;

  @override
  Future<PhoneMatch> matchHashes(
    Session session, {
    required List<String> hashes,
    required String legacyHash,
    required String canonicalHash,
    Transaction? transaction,
  }) async =>
      PhoneMatch.none(legacyHash: legacyHash, canonicalHash: canonicalHash);

  @override
  Future<void> rewriteMatchedPhoneToCanonical(
    Session session, {
    required String phone,
    required UuidValue authUserId,
    Transaction? transaction,
  }) async {}

  @override
  Future<bool> isPhoneBoundForUser(
    Session session, {
    required UuidValue authUserId,
    Transaction? transaction,
  }) async => false;

  @override
  Future<void> bindPhone(
    Session session, {
    required UuidValue authUserId,
    required String phone,
    required bool allowRebind,
    Transaction? transaction,
  }) async {}

  @override
  Future<void> unbindPhoneByHash(
    Session session, {
    required UuidValue authUserId,
    required String phoneHash,
    Transaction? transaction,
  }) async {}
}

void main() {
  const dashed = '+86-138-0000-0000';
  const plain = '+8613800000000';

  test('注册或重置：带分隔符与规范串共用次数桶', () {
    final store = _TagPhoneIdStore();
    final dashedNonce = smsAccountPhoneRateNonce(store, dashed);
    final plainNonce = smsAccountPhoneRateNonce(store, plain);

    expect(dashedNonce, plainNonce);
    expect(dashedNonce, store.hashCanonicalPhone(dashed));
    expect(dashedNonce, isNot(startsWith('legacy:')));
    expect(
      dashedNonce,
      isNot(store.hashLegacyPhone(store.canonicalPhone(dashed))),
    );
  });

  test('绑定次数桶保留用户编号，号码部分共用规范指纹', () {
    final store = _TagPhoneIdStore();
    final userId = UuidValue.fromString('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa');
    final dashedNonce = smsBindPhoneRateNonce(
      store: store,
      authUserId: userId,
      phone: dashed,
    );
    final plainNonce = smsBindPhoneRateNonce(
      store: store,
      authUserId: userId,
      phone: plain,
    );

    expect(dashedNonce, plainNonce);
    expect(dashedNonce, '$userId:${store.hashCanonicalPhone(dashed)}');
    expect(dashedNonce, startsWith('$userId:'));
    expect(dashedNonce, isNot(contains('legacy:')));
  });
}
