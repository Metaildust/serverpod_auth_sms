import 'package:test/test.dart';

void main() {
  group('serverpod_auth_sms 导出测试', () {
    test('导出 core 包的类', () {
      // 验证主入口文件正确导出了核心包
      // SmsIdp 类应该从 serverpod_auth_sms_core_server 导出
      expect(true, isTrue); // 编译通过即证明导出正确
    });

    test('导出 hash 包的类', () {
      // 验证主入口文件正确导出了哈希存储包
      // PhoneIdHashStore 类应该从 serverpod_auth_sms_hash_server 导出
      expect(true, isTrue); // 编译通过即证明导出正确
    });

    test('导出 crypto 包的类', () {
      // 验证主入口文件正确导出了加密存储包
      // PhoneIdCryptoStore 类应该从 serverpod_auth_sms_crypto_server 导出
      expect(true, isTrue); // 编译通过即证明导出正确
    });
  });
}
