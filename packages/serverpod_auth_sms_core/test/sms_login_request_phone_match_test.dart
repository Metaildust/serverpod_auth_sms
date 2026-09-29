import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart';
import 'package:test/test.dart';

void main() {
  group('smsLoginRequestMatchesPhoneHashes', () {
    // 模拟 HMAC 结果：64 字符段，便于 fingerprint 双段解析。
    const canon = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    const legacyDashed =
        'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';

    test('整串 fingerprint 不同但哈希交集仍命中（横杠发码 / 纯数字改密）', () {
      final storedDashed = phoneRequestFingerprint(
        legacyHash: legacyDashed,
        canonicalHash: canon,
      );
      // 纯数字改密：legacy == canonical == canon，整串 fingerprint 只是 canon。
      final digitFingerprint = phoneRequestFingerprint(
        legacyHash: canon,
        canonicalHash: canon,
      );
      expect(storedDashed, isNot(digitFingerprint));
      expect(
        smsLoginRequestMatchesPhoneHashes(
          phoneHash: storedDashed,
          legacyHash: canon,
          canonicalHash: canon,
        ),
        isTrue,
      );
    });

    test('纯数字发码指纹在横杠改密目标集合下仍命中', () {
      final storedDigit = phoneRequestFingerprint(
        legacyHash: canon,
        canonicalHash: canon,
      );
      expect(
        smsLoginRequestMatchesPhoneHashes(
          phoneHash: storedDigit,
          legacyHash: legacyDashed,
          canonicalHash: canon,
        ),
        isTrue,
      );
    });

    test('禁止只认整串相等：其它号码的双段指纹不相交', () {
      const otherLegacy =
          'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc';
      final otherStored = phoneRequestFingerprint(
        legacyHash: otherLegacy,
        canonicalHash: otherLegacy,
      );
      expect(
        smsLoginRequestMatchesPhoneHashes(
          phoneHash: otherStored,
          legacyHash: canon,
          canonicalHash: canon,
        ),
        isFalse,
      );
    });
  });
}
