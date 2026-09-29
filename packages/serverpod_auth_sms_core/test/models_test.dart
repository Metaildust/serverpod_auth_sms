import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_sms_core_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('SmsAccount', () {
    test('创建 SmsAccount', () {
      final authUserId = const Uuid().v7obj();
      final account = SmsAccount(
        authUserId: authUserId,
        passwordHash: 'hashed_password',
      );

      expect(account.authUserId, equals(authUserId));
      expect(account.passwordHash, equals('hashed_password'));
    });

    test('SmsAccount 序列化', () {
      final authUserId = const Uuid().v7obj();
      final account = SmsAccount(
        authUserId: authUserId,
        passwordHash: 'test_hash',
      );

      final json = account.toJson();
      expect(json, isA<Map>());
      expect(json['authUserId'], isNotNull);
      expect(json['passwordHash'], equals('test_hash'));
    });

    test('SmsAccount 反序列化', () {
      final authUserId = const Uuid().v7obj();
      final original = SmsAccount(
        authUserId: authUserId,
        passwordHash: 'original_hash',
      );

      final json = original.toJson();
      final restored = SmsAccount.fromJson(json);

      expect(restored.authUserId, equals(original.authUserId));
      expect(restored.passwordHash, equals(original.passwordHash));
    });

    test('SmsAccount copyWith', () {
      final authUserId = const Uuid().v7obj();
      final original = SmsAccount(
        authUserId: authUserId,
        passwordHash: 'original_hash',
      );

      final copied = original.copyWith(passwordHash: 'new_hash');

      expect(original.passwordHash, equals('original_hash'));
      expect(copied.passwordHash, equals('new_hash'));
      expect(copied.authUserId, equals(original.authUserId));
    });
  });

  group('SmsAccountRequest', () {
    test('创建 SmsAccountRequest', () {
      final challengeId = const Uuid().v7obj();
      final request = SmsAccountRequest(
        phoneHash: 'phone_hash_value',
        challengeId: challengeId,
      );

      expect(request.phoneHash, equals('phone_hash_value'));
      expect(request.challengeId, equals(challengeId));
    });

    test('SmsAccountRequest 序列化', () {
      final challengeId = const Uuid().v7obj();
      final request = SmsAccountRequest(
        phoneHash: 'test_phone_hash',
        challengeId: challengeId,
      );

      final json = request.toJson();
      expect(json, isA<Map>());
      expect(json['phoneHash'], equals('test_phone_hash'));
    });
  });

  group('SmsLoginRequest', () {
    test('创建 SmsLoginRequest', () {
      final challengeId = const Uuid().v7obj();
      final request = SmsLoginRequest(
        phoneHash: 'login_phone_hash',
        challengeId: challengeId,
      );

      expect(request.phoneHash, equals('login_phone_hash'));
      expect(request.challengeId, equals(challengeId));
    });

    test('SmsLoginRequest 序列化', () {
      final challengeId = const Uuid().v7obj();
      final request = SmsLoginRequest(
        phoneHash: 'test_login_hash',
        challengeId: challengeId,
      );

      final json = request.toJson();
      expect(json, isA<Map>());
      expect(json['phoneHash'], equals('test_login_hash'));
    });
  });

  group('SmsBindRequest', () {
    test('创建 SmsBindRequest', () {
      final authUserId = const Uuid().v7obj();
      final challengeId = const Uuid().v7obj();
      final request = SmsBindRequest(
        authUserId: authUserId,
        phoneHash: 'bind_phone_hash',
        challengeId: challengeId,
      );

      expect(request.authUserId, equals(authUserId));
      expect(request.phoneHash, equals('bind_phone_hash'));
      expect(request.challengeId, equals(challengeId));
    });

    test('SmsBindRequest 序列化', () {
      final authUserId = const Uuid().v7obj();
      final challengeId = const Uuid().v7obj();
      final request = SmsBindRequest(
        authUserId: authUserId,
        phoneHash: 'test_bind_hash',
        challengeId: challengeId,
      );

      final json = request.toJson();
      expect(json, isA<Map>());
      expect(json['phoneHash'], equals('test_bind_hash'));
    });
  });

  group('SmsPasswordResetRequest', () {
    test('创建 SmsPasswordResetRequest', () {
      final authUserId = const Uuid().v7obj();
      final challengeId = const Uuid().v7obj();
      final request = SmsPasswordResetRequest(
        phoneHash: 'reset_phone_hash',
        authUserId: authUserId,
        blockedReason: null,
        challengeId: challengeId,
      );

      expect(request.phoneHash, equals('reset_phone_hash'));
      expect(request.authUserId, equals(authUserId));
      expect(request.challengeId, equals(challengeId));
      expect(request.blockedReason, isNull);
    });

    test('SmsPasswordResetRequest 支持拦截原因', () {
      final challengeId = const Uuid().v7obj();
      final request = SmsPasswordResetRequest(
        phoneHash: 'blocked_hash',
        blockedReason: SmsPasswordResetBlockedReason.passwordNotSetYet,
        challengeId: challengeId,
      );

      expect(
        request.blockedReason,
        SmsPasswordResetBlockedReason.passwordNotSetYet,
      );
      expect(request.authUserId, isNull);
    });
  });

  group('SmsVerifyLoginResult', () {
    test('创建不需要密码的结果', () {
      final result = SmsVerifyLoginResult(
        token: 'test_token',
        needsPassword: false,
      );
      expect(result.needsPassword, isFalse);
      expect(result.token, equals('test_token'));
    });

    test('创建需要密码的结果', () {
      final result = SmsVerifyLoginResult(
        token: 'test_token_2',
        needsPassword: true,
      );
      expect(result.needsPassword, isTrue);
    });

    test('SmsVerifyLoginResult 序列化', () {
      final result = SmsVerifyLoginResult(
        token: 'serialize_token',
        needsPassword: true,
      );
      final json = result.toJson();
      expect(json['needsPassword'], isTrue);
      expect(json['token'], equals('serialize_token'));
    });

    test('SmsVerifyLoginResult 反序列化', () {
      final original = SmsVerifyLoginResult(
        token: 'original_token',
        needsPassword: true,
      );
      final json = original.toJson();
      final restored = SmsVerifyLoginResult.fromJson(json);
      expect(restored.needsPassword, equals(original.needsPassword));
      expect(restored.token, equals(original.token));
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
        SmsPasswordResetBlockedReason.passwordNotSetYet,
      );
    });

    test('SmsVerifyPasswordResetResult 序列化', () {
      final result = SmsVerifyPasswordResetResult(
        resetToken: 'serialize_reset_token',
        blockedReason: null,
      );

      final json = result.toJson();
      expect(json['resetToken'], equals('serialize_reset_token'));
      expect(json['blockedReason'], isNull);
    });

    test('SmsVerifyPasswordResetResult 反序列化', () {
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

  group('SmsSamePasswordBanner', () {
    test('创建密码提示信息', () {
      final banner = SmsSamePasswordBanner(
        enabled: true,
        title: '提示标题',
        body: '提示内容',
      );

      expect(banner.enabled, isTrue);
      expect(banner.title, equals('提示标题'));
      expect(banner.body, equals('提示内容'));
    });

    test('创建禁用的提示信息', () {
      final banner = SmsSamePasswordBanner(enabled: false);

      expect(banner.enabled, isFalse);
      expect(banner.title, isNull);
      expect(banner.body, isNull);
    });

    test('SmsSamePasswordBanner 序列化', () {
      final banner = SmsSamePasswordBanner(
        enabled: true,
        title: 'Title',
        body: 'Body',
      );

      final json = banner.toJson();
      expect(json['enabled'], isTrue);
      expect(json['title'], equals('Title'));
      expect(json['body'], equals('Body'));
    });

    test('SmsSamePasswordBanner 反序列化', () {
      final original = SmsSamePasswordBanner(
        enabled: true,
        title: 'Original Title',
        body: 'Original Body',
      );

      final json = original.toJson();
      final restored = SmsSamePasswordBanner.fromJson(json);

      expect(restored.enabled, equals(original.enabled));
      expect(restored.title, equals(original.title));
      expect(restored.body, equals(original.body));
    });

    test('SmsSamePasswordBanner copyWith', () {
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
}
