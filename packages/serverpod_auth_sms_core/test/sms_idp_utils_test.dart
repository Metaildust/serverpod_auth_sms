import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart';
import 'package:serverpod_auth_sms_core_server/src/phone/phone_id_store.dart';
import 'package:test/test.dart';

/// 只为读出 [SmsIdpConfig] 默认字段；不碰库。
class _StubPhoneIdStore extends PhoneIdStore {
  @override
  String hashPrepared(String prepared) => prepared;

  @override
  Future<UuidValue?> findAuthUserIdByPhoneHash(
    Session session, {
    required String phoneHash,
    Transaction? transaction,
  }) async =>
      null;

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
  }) async =>
      false;

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

SmsIdpConfig _defaultConfig() => SmsIdpConfig(
  secretHashPepper: 'test-pepper',
  phoneIdStore: _StubPhoneIdStore(),
);

/// 从 PHC 哈希串读出构造口实际写入的 m=（Argon2 memory KiB）。
int _memoryFromPhcHash(String hash) {
  final match = RegExp(r'm=(\d+)').firstMatch(hash);
  expect(match, isNotNull, reason: 'PHC 串须含 m= 参数: $hash');
  return int.parse(match!.group(1)!);
}

void main() {
  group('SmsAccountAlreadyRegisteredException', () {
    test('PhoneAlreadyBoundException 是 Exception', () {
      const exception = PhoneAlreadyBoundException();
      expect(exception, isA<Exception>());
    });

    test('PhoneRebindNotAllowedException 是 Exception', () {
      const exception = PhoneRebindNotAllowedException();
      expect(exception, isA<Exception>());
    });
  });

  group('Argon2HashUtil 参数测试', () {
    test('默认盐长度读自 SmsIdpConfig', () {
      expect(_defaultConfig().secretHashSaltLength, 16);
    });

    test('Argon2 内存读自生产常量', () {
      expect(smsIdpArgon2Memory, 19456);
    });

    test('构造路径 Argon2 内存接 smsIdpArgon2Memory', () async {
      final util = createSmsIdpArgon2HashUtil(
        hashPepper: 'test-pepper',
        hashSaltLength: 16,
      );
      final hash = await util.createHashFromString(secret: 'probe');
      expect(_memoryFromPhcHash(hash), smsIdpArgon2Memory);
      expect(smsIdpArgon2Memory, 19456);
    });
  });

  group('SecretChallengeUtil 配置测试', () {
    test('登录来源桶标识不是号码桶', () {
      expect(smsLoginRequestSource, isNot('login_request'));
      expect(smsLoginRequestSource, 'login_source');
    });

    test('注册绑定重置来源桶标识互异且不是号码桶', () {
      expect(smsRegistrationRequestSource, 'registration_source');
      expect(smsBindRequestSource, 'bind_source');
      expect(smsPasswordResetRequestSource, 'password_reset_source');
      expect(smsRegistrationRequestSource, isNot('registration_request'));
      expect(smsBindRequestSource, isNot('bind_request'));
      expect(smsPasswordResetRequestSource, isNot('password_reset_request'));
      expect(smsRegistrationRequestSource, isNot(smsLoginRequestSource));
      expect(smsBindRequestSource, isNot(smsLoginRequestSource));
      expect(smsPasswordResetRequestSource, isNot(smsLoginRequestSource));
      expect(smsRegistrationRequestSource, isNot(smsBindRequestSource));
      expect(
        smsRegistrationRequestSource,
        isNot(smsPasswordResetRequestSource),
      );
      expect(smsBindRequestSource, isNot(smsPasswordResetRequestSource));
      expect(smsRegistrationRequestSource, isNot('login_request'));
      expect(smsBindRequestSource, isNot('login_request'));
      expect(smsPasswordResetRequestSource, isNot('login_request'));
    });

    test('验证码过期时间读自 SmsIdpConfig 默认', () {
      final config = _defaultConfig();
      expect(
        config.registrationVerificationCodeLifetime,
        const Duration(minutes: 15),
      );
      expect(
        config.loginVerificationCodeLifetime,
        const Duration(minutes: 10),
      );
      expect(
        config.bindVerificationCodeLifetime,
        const Duration(minutes: 10),
      );
      expect(config.registrationRequestSourceRateLimit.maxAttempts, 60);
      expect(config.bindRequestSourceRateLimit.maxAttempts, 60);
      expect(config.passwordResetRequestSourceRateLimit.maxAttempts, 60);
    });

    test('来源桶标识不是号码桶，空和字面量 null 不是来源键', () {
      expect(smsLoginRequestSource, isNot('login_request'));
      expect(usableLoginSourceKey(null), isNull);
      expect(usableLoginSourceKey(''), isNull);
      expect(usableLoginSourceKey('   '), isNull);
      expect(usableLoginSourceKey('null'), isNull);
      expect(usableLoginSourceKey(' null '), isNull);
      expect(usableLoginSourceKey('gateway-a'), 'gateway-a');
    });
  });
}
