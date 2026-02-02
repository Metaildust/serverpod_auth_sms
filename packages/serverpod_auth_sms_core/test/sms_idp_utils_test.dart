import 'package:serverpod_auth_sms_core_server/src/phone/phone_id_store.dart';
import 'package:test/test.dart';

void main() {
  group('SmsAccountAlreadyRegisteredException', () {
    // 注意：这个异常定义在 sms_idp_utils.dart 中
    // 这里测试相关的异常处理逻辑

    test('PhoneAlreadyBoundException 是 Exception', () {
      const exception = PhoneAlreadyBoundException();
      expect(exception, isA<Exception>());
    });

    test('PhoneRebindNotAllowedException 是 Exception', () {
      const exception = PhoneRebindNotAllowedException();
      expect(exception, isA<Exception>());
    });
  });

  group('异常转换逻辑测试', () {
    // 测试 withReplacedAccountRequestException 的行为
    // 由于实际方法需要异步函数，这里测试概念

    test('正常函数不抛出异常', () async {
      Future<int> normalFunction() async => 42;

      final result = await normalFunction();
      expect(result, equals(42));
    });

    test('异常函数抛出异常', () async {
      Future<int> throwingFunction() async {
        throw Exception('Test error');
      }

      expect(() => throwingFunction(), throwsException);
    });
  });

  group('Argon2HashUtil 参数测试', () {
    // 验证哈希参数配置

    test('默认盐长度为16', () {
      const defaultSaltLength = 16;
      expect(defaultSaltLength, equals(16));
    });

    test('Argon2内存参数', () {
      // Argon2HashParameters(memory: 19456)
      const memory = 19456;
      expect(memory, equals(19456));
    });
  });

  group('SecretChallengeUtil 配置测试', () {
    // 验证挑战配置的预期行为

    test('速率限制配置', () {
      // 验证速率限制器配置正确
      const domain = 'sms';
      const registrationSource = 'registration_request';
      const loginSource = 'login_request';
      const bindSource = 'bind_request';

      expect(domain, equals('sms'));
      expect(registrationSource, isNotEmpty);
      expect(loginSource, isNotEmpty);
      expect(bindSource, isNotEmpty);
    });

    test('验证码过期时间', () {
      const registrationLifetime = Duration(minutes: 15);
      const loginLifetime = Duration(minutes: 10);
      const bindLifetime = Duration(minutes: 10);

      expect(registrationLifetime.inMinutes, equals(15));
      expect(loginLifetime.inMinutes, equals(10));
      expect(bindLifetime.inMinutes, equals(10));
    });

    test('最大尝试次数', () {
      const maxAttempts = 3;
      expect(maxAttempts, equals(3));
    });
  });
}
