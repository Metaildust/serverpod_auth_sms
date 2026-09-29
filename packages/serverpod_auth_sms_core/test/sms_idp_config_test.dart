import 'package:serverpod_auth_sms_core_server/src/sms_idp_config.dart';
import 'package:test/test.dart';

void main() {
  group('defaultSmsVerificationCodeGenerator', () {
    test('默认生成6位数字验证码', () {
      final code = defaultSmsVerificationCodeGenerator();
      expect(code.length, equals(6));
      expect(int.tryParse(code), isNotNull);
    });

    test('自定义长度验证码', () {
      final code4 = defaultSmsVerificationCodeGenerator(length: 4);
      expect(code4.length, equals(4));
      expect(int.tryParse(code4), isNotNull);

      final code8 = defaultSmsVerificationCodeGenerator(length: 8);
      expect(code8.length, equals(8));
      expect(int.tryParse(code8), isNotNull);
    });

    test('生成的验证码是随机的', () {
      final codes = <String>{};
      for (var i = 0; i < 100; i++) {
        codes.add(defaultSmsVerificationCodeGenerator());
      }
      // 100次生成应该有多个不同的值（极低概率全相同）
      expect(codes.length, greaterThan(50));
    });

    test('长度为0时返回空字符串', () {
      final code = defaultSmsVerificationCodeGenerator(length: 0);
      expect(code, equals(''));
    });

    test('长度为1时返回单个数字', () {
      final code = defaultSmsVerificationCodeGenerator(length: 1);
      expect(code.length, equals(1));
      expect(int.tryParse(code), isNotNull);
      expect(int.parse(code), inInclusiveRange(0, 9));
    });

    test('验证码只包含数字0-9', () {
      for (var i = 0; i < 50; i++) {
        final code = defaultSmsVerificationCodeGenerator();
        expect(RegExp(r'^[0-9]+$').hasMatch(code), isTrue);
      }
    });
  });

  group('defaultRegistrationPasswordValidationFunction', () {
    // 与 client 包 evaluateAuthPasswordPolicy 布尔口径对齐（满 8 位不够）。
    test('仅数字或仅小写的满 8 位密码不通过', () {
      expect(defaultRegistrationPasswordValidationFunction('12345678'), isFalse);
      expect(defaultRegistrationPasswordValidationFunction('abcdefgh'), isFalse);
    });

    test('符合六项的 ValidPass123! 通过', () {
      expect(
        defaultRegistrationPasswordValidationFunction('ValidPass123!'),
        isTrue,
      );
    });

    test('少于8位密码无效', () {
      expect(defaultRegistrationPasswordValidationFunction(''), isFalse);
      expect(defaultRegistrationPasswordValidationFunction('1234567'), isFalse);
      expect(defaultRegistrationPasswordValidationFunction('Abc12!x'), isFalse);
    });

    test('缺任一类字符不通过', () {
      expect(
        defaultRegistrationPasswordValidationFunction('a1b2c3d4e5'),
        isFalse,
      );
      expect(
        defaultRegistrationPasswordValidationFunction('Abcdefgh'),
        isFalse,
      );
      expect(
        defaultRegistrationPasswordValidationFunction('Abcdefg1'),
        isFalse,
      );
      expect(
        defaultRegistrationPasswordValidationFunction('!@#\$%^&*()'),
        isFalse,
      );
    });

    test('中间有空格但缺其它类时不通过', () {
      expect(
        defaultRegistrationPasswordValidationFunction('1234 5678'),
        isFalse,
      );
      expect(
        defaultRegistrationPasswordValidationFunction('abc def gh'),
        isFalse,
      );
    });

    test('很长但缺类字符的密码不通过', () {
      expect(
        defaultRegistrationPasswordValidationFunction('a' * 100),
        isFalse,
      );
    });

    test('符合六项结构的密码通过', () {
      expect(
        defaultRegistrationPasswordValidationFunction('Pass@123!'),
        isTrue,
      );
      expect(
        defaultRegistrationPasswordValidationFunction('Abcd12!x'),
        isTrue,
      );
    });

    test('包含非 ASCII 字符的密码不通过', () {
      expect(
        defaultRegistrationPasswordValidationFunction('密码12345678'),
        isFalse,
      );
      expect(
        defaultRegistrationPasswordValidationFunction('パスワード123'),
        isFalse,
      );
      expect(
        defaultRegistrationPasswordValidationFunction('ValidPass123！xyz'),
        isFalse,
      );
    });
  });

  group('SmsRateLimit', () {
    test('创建速率限制配置', () {
      const rateLimit = SmsRateLimit(
        maxAttempts: 5,
        timeframe: Duration(minutes: 15),
      );

      expect(rateLimit.maxAttempts, equals(5));
      expect(rateLimit.timeframe, equals(const Duration(minutes: 15)));
    });

    test('不同的速率限制配置', () {
      const limit1 = SmsRateLimit(
        maxAttempts: 3,
        timeframe: Duration(minutes: 5),
      );
      const limit2 = SmsRateLimit(
        maxAttempts: 10,
        timeframe: Duration(hours: 1),
      );

      expect(limit1.maxAttempts, equals(3));
      expect(limit1.timeframe.inMinutes, equals(5));
      expect(limit2.maxAttempts, equals(10));
      expect(limit2.timeframe.inHours, equals(1));
    });

    test('边界值测试', () {
      const zeroLimit = SmsRateLimit(
        maxAttempts: 0,
        timeframe: Duration.zero,
      );
      expect(zeroLimit.maxAttempts, equals(0));
      expect(zeroLimit.timeframe, equals(Duration.zero));

      const largeLimit = SmsRateLimit(
        maxAttempts: 1000000,
        timeframe: Duration(days: 365),
      );
      expect(largeLimit.maxAttempts, equals(1000000));
      expect(largeLimit.timeframe.inDays, equals(365));
    });
  });
}
