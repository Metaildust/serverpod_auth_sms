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

  group('SmsSamePasswordBanter', () {
    test('创建密码提示信息', () {
      final banter = SmsSamePasswordBanter(
        enabled: true,
        title: '提示标题',
        body: '提示内容',
      );

      expect(banter.enabled, isTrue);
      expect(banter.title, equals('提示标题'));
      expect(banter.body, equals('提示内容'));
    });

    test('创建禁用的提示信息', () {
      final banter = SmsSamePasswordBanter(enabled: false);

      expect(banter.enabled, isFalse);
      expect(banter.title, isNull);
      expect(banter.body, isNull);
    });

    test('SmsSamePasswordBanter 序列化', () {
      final banter = SmsSamePasswordBanter(
        enabled: true,
        title: 'Title',
        body: 'Body',
      );

      final json = banter.toJson();
      expect(json['enabled'], isTrue);
      expect(json['title'], equals('Title'));
      expect(json['body'], equals('Body'));
    });

    test('SmsSamePasswordBanter 反序列化', () {
      final original = SmsSamePasswordBanter(
        enabled: true,
        title: 'Original Title',
        body: 'Original Body',
      );

      final json = original.toJson();
      final restored = SmsSamePasswordBanter.fromJson(json);

      expect(restored.enabled, equals(original.enabled));
      expect(restored.title, equals(original.title));
      expect(restored.body, equals(original.body));
    });

    test('SmsSamePasswordBanter copyWith', () {
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
}
