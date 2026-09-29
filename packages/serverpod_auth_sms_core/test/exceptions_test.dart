import 'package:serverpod_auth_sms_core_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('SmsAccountRequestException', () {
    test('创建invalid异常', () {
      final exception = SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.invalid,
      );
      expect(exception.reason, equals(SmsAccountRequestExceptionReason.invalid));
    });

    test('创建expired异常', () {
      final exception = SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.expired,
      );
      expect(exception.reason, equals(SmsAccountRequestExceptionReason.expired));
    });

    test('创建tooManyAttempts异常', () {
      final exception = SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.tooManyAttempts,
      );
      expect(
        exception.reason,
        equals(SmsAccountRequestExceptionReason.tooManyAttempts),
      );
    });

    test('创建policyViolation异常', () {
      final exception = SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.policyViolation,
      );
      expect(
        exception.reason,
        equals(SmsAccountRequestExceptionReason.policyViolation),
      );
    });

    test('序列化和反序列化', () {
      final original = SmsAccountRequestException(
        reason: SmsAccountRequestExceptionReason.expired,
      );
      final json = original.toJson();
      final restored = SmsAccountRequestException.fromJson(json);

      expect(restored.reason, equals(original.reason));
    });
  });

  group('SmsAccountRequestExceptionReason', () {
    test('包含所有预期的原因', () {
      expect(
        SmsAccountRequestExceptionReason.values,
        containsAll([
          SmsAccountRequestExceptionReason.invalid,
          SmsAccountRequestExceptionReason.expired,
          SmsAccountRequestExceptionReason.tooManyAttempts,
          SmsAccountRequestExceptionReason.policyViolation,
        ]),
      );
    });

    test('枚举序列化', () {
      for (final reason in SmsAccountRequestExceptionReason.values) {
        final json = reason.toJson();
        final restored = SmsAccountRequestExceptionReason.fromJson(json);
        expect(restored, equals(reason));
      }
    });
  });

  group('SmsLoginException', () {
    test('创建invalid异常', () {
      final exception = SmsLoginException(
        reason: SmsLoginExceptionReason.invalid,
      );
      expect(exception.reason, equals(SmsLoginExceptionReason.invalid));
    });

    test('创建expired异常', () {
      final exception = SmsLoginException(
        reason: SmsLoginExceptionReason.expired,
      );
      expect(exception.reason, equals(SmsLoginExceptionReason.expired));
    });

    test('创建tooManyAttempts异常', () {
      final exception = SmsLoginException(
        reason: SmsLoginExceptionReason.tooManyAttempts,
      );
      expect(exception.reason, equals(SmsLoginExceptionReason.tooManyAttempts));
    });

    test('创建passwordRequired异常', () {
      final exception = SmsLoginException(
        reason: SmsLoginExceptionReason.passwordRequired,
      );
      expect(exception.reason, equals(SmsLoginExceptionReason.passwordRequired));
    });

    test('创建policyViolation异常', () {
      final exception = SmsLoginException(
        reason: SmsLoginExceptionReason.policyViolation,
      );
      expect(exception.reason, equals(SmsLoginExceptionReason.policyViolation));
    });

    test('序列化和反序列化', () {
      final original = SmsLoginException(
        reason: SmsLoginExceptionReason.passwordRequired,
      );
      final json = original.toJson();
      final restored = SmsLoginException.fromJson(json);

      expect(restored.reason, equals(original.reason));
    });
  });

  group('SmsLoginExceptionReason', () {
    test('包含所有预期的原因', () {
      expect(
        SmsLoginExceptionReason.values,
        containsAll([
          SmsLoginExceptionReason.invalid,
          SmsLoginExceptionReason.expired,
          SmsLoginExceptionReason.tooManyAttempts,
          SmsLoginExceptionReason.passwordRequired,
          SmsLoginExceptionReason.policyViolation,
        ]),
      );
    });

    test('枚举序列化', () {
      for (final reason in SmsLoginExceptionReason.values) {
        final json = reason.toJson();
        final restored = SmsLoginExceptionReason.fromJson(json);
        expect(restored, equals(reason));
      }
    });
  });

  group('SmsPhoneBindException', () {
    test('创建invalid异常', () {
      final exception = SmsPhoneBindException(
        reason: SmsPhoneBindExceptionReason.invalid,
      );
      expect(exception.reason, equals(SmsPhoneBindExceptionReason.invalid));
    });

    test('创建expired异常', () {
      final exception = SmsPhoneBindException(
        reason: SmsPhoneBindExceptionReason.expired,
      );
      expect(exception.reason, equals(SmsPhoneBindExceptionReason.expired));
    });

    test('创建tooManyAttempts异常', () {
      final exception = SmsPhoneBindException(
        reason: SmsPhoneBindExceptionReason.tooManyAttempts,
      );
      expect(exception.reason, equals(SmsPhoneBindExceptionReason.tooManyAttempts));
    });

    test('创建phoneAlreadyBound异常', () {
      final exception = SmsPhoneBindException(
        reason: SmsPhoneBindExceptionReason.phoneAlreadyBound,
      );
      expect(
        exception.reason,
        equals(SmsPhoneBindExceptionReason.phoneAlreadyBound),
      );
    });

    test('序列化和反序列化', () {
      final original = SmsPhoneBindException(
        reason: SmsPhoneBindExceptionReason.phoneAlreadyBound,
      );
      final json = original.toJson();
      final restored = SmsPhoneBindException.fromJson(json);

      expect(restored.reason, equals(original.reason));
    });
  });

  group('SmsPhoneBindExceptionReason', () {
    test('包含所有预期的原因', () {
      expect(
        SmsPhoneBindExceptionReason.values,
        containsAll([
          SmsPhoneBindExceptionReason.invalid,
          SmsPhoneBindExceptionReason.expired,
          SmsPhoneBindExceptionReason.tooManyAttempts,
          SmsPhoneBindExceptionReason.phoneAlreadyBound,
        ]),
      );
    });

    test('枚举序列化', () {
      for (final reason in SmsPhoneBindExceptionReason.values) {
        final json = reason.toJson();
        final restored = SmsPhoneBindExceptionReason.fromJson(json);
        expect(restored, equals(reason));
      }
    });
  });
}
