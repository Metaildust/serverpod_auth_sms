import 'package:serverpod_auth_sms_core_client/serverpod_auth_sms_core_client.dart'
    show evaluateAuthPasswordPolicy, validateAuthPasswordPolicy;
import 'package:serverpod_auth_sms_core_client/src/protocol/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('SmsVerifyLoginResult', () {
    test('创建登录结果', () {
      final result = SmsVerifyLoginResult(
        token: 'test_token',
        needsPassword: false,
      );
      expect(result.needsPassword, isFalse);
      expect(result.token, equals('test_token'));
    });

    test('需要密码的登录结果', () {
      final result = SmsVerifyLoginResult(
        token: 'test_token_2',
        needsPassword: true,
      );
      expect(result.needsPassword, isTrue);
    });

    test('序列化和反序列化', () {
      final original = SmsVerifyLoginResult(
        token: 'original_token',
        needsPassword: true,
      );
      final json = original.toJson();
      final restored = SmsVerifyLoginResult.fromJson(json);

      expect(restored.needsPassword, equals(original.needsPassword));
      expect(restored.token, equals(original.token));
    });

    test('copyWith', () {
      final original = SmsVerifyLoginResult(
        token: 'original',
        needsPassword: false,
      );
      final copied = original.copyWith(needsPassword: true);

      expect(original.needsPassword, isFalse);
      expect(copied.needsPassword, isTrue);
      expect(copied.token, equals('original'));
    });
  });

  group('SmsSamePasswordBanner', () {
    test('创建启用的提示', () {
      final banner = SmsSamePasswordBanner(
        enabled: true,
        title: '提示标题',
        body: '提示内容',
      );
      expect(banner.enabled, isTrue);
      expect(banner.title, equals('提示标题'));
      expect(banner.body, equals('提示内容'));
    });

    test('创建禁用的提示', () {
      final banner = SmsSamePasswordBanner(enabled: false);
      expect(banner.enabled, isFalse);
      expect(banner.title, isNull);
      expect(banner.body, isNull);
    });

    test('序列化和反序列化', () {
      final original = SmsSamePasswordBanner(
        enabled: true,
        title: 'Title',
        body: 'Body',
      );
      final json = original.toJson();
      final restored = SmsSamePasswordBanner.fromJson(json);

      expect(restored.enabled, equals(original.enabled));
      expect(restored.title, equals(original.title));
      expect(restored.body, equals(original.body));
    });

    test('copyWith', () {
      final original = SmsSamePasswordBanner(
        enabled: false,
        title: 'Old Title',
      );
      final copied = original.copyWith(enabled: true, body: 'New Body');

      expect(original.enabled, isFalse);
      expect(copied.enabled, isTrue);
      expect(copied.title, equals('Old Title'));
      expect(copied.body, equals('New Body'));
    });
  });

  group('SmsVerifyPasswordResetResult', () {
    test('创建可继续完成重置的结果', () {
      final result = SmsVerifyPasswordResetResult(
        resetToken: 'reset_token',
        blockedReason: null,
      );
      expect(result.resetToken, equals('reset_token'));
      expect(result.blockedReason, isNull);
    });

    test('创建被拦截的结果', () {
      final result = SmsVerifyPasswordResetResult(
        resetToken: null,
        blockedReason: SmsPasswordResetBlockedReason.passwordNotSetYet,
      );
      expect(result.resetToken, isNull);
      expect(
        result.blockedReason,
        equals(SmsPasswordResetBlockedReason.passwordNotSetYet),
      );
    });

    test('序列化和反序列化', () {
      final original = SmsVerifyPasswordResetResult(
        resetToken: null,
        blockedReason: SmsPasswordResetBlockedReason.passwordNotSetYet,
      );
      final json = original.toJson();
      final restored = SmsVerifyPasswordResetResult.fromJson(json);

      expect(restored.resetToken, equals(original.resetToken));
      expect(restored.blockedReason, equals(original.blockedReason));
    });
  });

  group('SmsAccountRequestException (Client)', () {
    test('创建异常', () {
      final exception = SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.invalid,
      );
      expect(
        exception.reason,
        equals(SmsAccountRequestExceptionReason.invalid),
      );
    });

    test('所有异常原因', () {
      for (final reason in SmsAccountRequestExceptionReason.values) {
        final exception = SmsAccountRequestException(reason: reason);
        expect(exception.reason, equals(reason));
      }
    });

    test('序列化和反序列化', () {
      for (final reason in SmsAccountRequestExceptionReason.values) {
        final original = SmsAccountRequestException(reason: reason);
        final json = original.toJson();
        final restored = SmsAccountRequestException.fromJson(json);
        expect(restored.reason, equals(original.reason));
      }
    });
  });

  group('SmsLoginException (Client)', () {
    test('创建异常', () {
      final exception = SmsLoginException(
        reason: SmsLoginExceptionReason.invalid,
      );
      expect(exception.reason, equals(SmsLoginExceptionReason.invalid));
    });

    test('所有异常原因', () {
      for (final reason in SmsLoginExceptionReason.values) {
        final exception = SmsLoginException(reason: reason);
        expect(exception.reason, equals(reason));
      }
    });

    test('序列化和反序列化', () {
      for (final reason in SmsLoginExceptionReason.values) {
        final original = SmsLoginException(reason: reason);
        final json = original.toJson();
        final restored = SmsLoginException.fromJson(json);
        expect(restored.reason, equals(original.reason));
      }
    });
  });

  group('SmsPhoneBindException (Client)', () {
    test('创建异常', () {
      final exception = SmsPhoneBindException(
        reason: SmsPhoneBindExceptionReason.invalid,
      );
      expect(exception.reason, equals(SmsPhoneBindExceptionReason.invalid));
    });

    test('所有异常原因', () {
      for (final reason in SmsPhoneBindExceptionReason.values) {
        final exception = SmsPhoneBindException(reason: reason);
        expect(exception.reason, equals(reason));
      }
    });

    test('序列化和反序列化', () {
      for (final reason in SmsPhoneBindExceptionReason.values) {
        final original = SmsPhoneBindException(reason: reason);
        final json = original.toJson();
        final restored = SmsPhoneBindException.fromJson(json);
        expect(restored.reason, equals(original.reason));
      }
    });
  });

  group('SmsPasswordResetException (Client)', () {
    test('创建异常', () {
      final exception = SmsPasswordResetException(
        reason: SmsPasswordResetExceptionReason.invalid,
      );
      expect(exception.reason, equals(SmsPasswordResetExceptionReason.invalid));
    });

    test('所有异常原因', () {
      for (final reason in SmsPasswordResetExceptionReason.values) {
        final exception = SmsPasswordResetException(reason: reason);
        expect(exception.reason, equals(reason));
      }
    });

    test('序列化和反序列化', () {
      for (final reason in SmsPasswordResetExceptionReason.values) {
        final original = SmsPasswordResetException(reason: reason);
        final json = original.toJson();
        final restored = SmsPasswordResetException.fromJson(json);
        expect(restored.reason, equals(original.reason));
      }
    });
  });

  group('Protocol 注册', () {
    test('Protocol 实例创建', () {
      final protocol = Protocol();
      expect(protocol, isNotNull);
    });
  });

  group('共享认证密码策略', () {
    test('仅数字或仅小写的满 8 位密码不通过', () {
      expect(validateAuthPasswordPolicy('12345678'), isFalse);
      expect(validateAuthPasswordPolicy('abcdefgh'), isFalse);
      expect(evaluateAuthPasswordPolicy('12345678').isValid, isFalse);
      expect(evaluateAuthPasswordPolicy('abcdefgh').isValid, isFalse);
    });

    test('合法半角密码通过校验', () {
      final result = evaluateAuthPasswordPolicy('ValidPass123!');

      expect(result.hasMinLength, isTrue);
      expect(result.hasUppercase, isTrue);
      expect(result.hasLowercase, isTrue);
      expect(result.hasDigits, isTrue);
      expect(result.hasSpecialChars, isTrue);
      expect(result.isAllAscii, isTrue);
      expect(result.isValid, isTrue);
      expect(validateAuthPasswordPolicy('ValidPass123!'), isTrue);
    });

    test('全角符号密码不通过校验', () {
      final result = evaluateAuthPasswordPolicy('ValidPass123！xyz');

      expect(result.hasSpecialChars, isFalse);
      expect(result.isAllAscii, isFalse);
      expect(result.isValid, isFalse);
      expect(validateAuthPasswordPolicy('ValidPass123！xyz'), isFalse);
    });

    test('默认 minLength 下 8 位合法结构密码通过', () {
      const password = 'Abcd12!x';
      final result = evaluateAuthPasswordPolicy(password);

      expect(result.hasMinLength, isTrue);
      expect(result.isValid, isTrue);
      expect(validateAuthPasswordPolicy(password), isTrue);
    });

    test('minLength 为 12 时 8 位合法结构密码不满足最小长度', () {
      const password = 'Abcd12!x';
      final result = evaluateAuthPasswordPolicy(password, minLength: 12);

      expect(result.hasMinLength, isFalse);
      expect(result.isValid, isFalse);
      expect(validateAuthPasswordPolicy(password, minLength: 12), isFalse);
    });
  });
}
