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

  group('SmsSamePasswordBanter', () {
    test('创建启用的提示', () {
      final banter = SmsSamePasswordBanter(
        enabled: true,
        title: '提示标题',
        body: '提示内容',
      );
      expect(banter.enabled, isTrue);
      expect(banter.title, equals('提示标题'));
      expect(banter.body, equals('提示内容'));
    });

    test('创建禁用的提示', () {
      final banter = SmsSamePasswordBanter(enabled: false);
      expect(banter.enabled, isFalse);
      expect(banter.title, isNull);
      expect(banter.body, isNull);
    });

    test('序列化和反序列化', () {
      final original = SmsSamePasswordBanter(
        enabled: true,
        title: 'Title',
        body: 'Body',
      );
      final json = original.toJson();
      final restored = SmsSamePasswordBanter.fromJson(json);

      expect(restored.enabled, equals(original.enabled));
      expect(restored.title, equals(original.title));
      expect(restored.body, equals(original.body));
    });

    test('copyWith', () {
      final original = SmsSamePasswordBanter(
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

  group('SmsAccountRequestException (Client)', () {
    test('创建异常', () {
      final exception = SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.invalid,
      );
      expect(exception.reason, equals(SmsAccountRequestExceptionReason.invalid));
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

  group('Protocol 注册', () {
    test('Protocol 实例创建', () {
      final protocol = Protocol();
      expect(protocol, isNotNull);
    });
  });
}
