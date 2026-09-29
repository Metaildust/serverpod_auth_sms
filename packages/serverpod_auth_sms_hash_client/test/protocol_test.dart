import 'package:serverpod_auth_sms_hash_client/src/protocol/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('Protocol 注册', () {
    test('Protocol 实例创建', () {
      final protocol = Protocol();
      expect(protocol, isNotNull);
    });

    test('Protocol 序列化管理器', () {
      final protocol = Protocol();
      // 验证 protocol 可以正常初始化
      expect(protocol.runtimeType.toString(), contains('Protocol'));
    });
  });
}
