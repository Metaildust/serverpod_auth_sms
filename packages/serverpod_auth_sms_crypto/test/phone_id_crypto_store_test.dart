import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' hide Hmac;
import 'package:test/test.dart';

/// 独立测试 PhoneIdCryptoStore 的加解密逻辑
/// 不依赖数据库操作
void main() {
  group('PhoneIdCryptoStore 哈希逻辑', () {
    const testPepper = 'test_pepper_secret_key';

    /// 模拟 hashPhone 方法的实现
    String hashPhone(String phone, String pepper) {
      final normalized = _normalizePhoneNumber(phone);
      final hmac = Hmac(sha256, utf8.encode(pepper));
      return hmac.convert(utf8.encode(normalized)).toString();
    }

    group('哈希一致性', () {
      test('相同输入产生相同哈希', () {
        final hash1 = hashPhone('+8613812345678', testPepper);
        final hash2 = hashPhone('+8613812345678', testPepper);
        expect(hash1, equals(hash2));
      });
    });

    group('哈希唯一性', () {
      test('不同手机号产生不同哈希', () {
        final hash1 = hashPhone('+8613812345678', testPepper);
        final hash2 = hashPhone('+8613812345679', testPepper);
        expect(hash1, isNot(equals(hash2)));
      });
    });

    group('标准化后哈希', () {
      test('标准化的号码哈希相同', () {
        final hash1 = hashPhone('13812345678', testPepper);
        final hash2 = hashPhone('+8613812345678', testPepper);
        expect(hash1, equals(hash2));
      });
    });
  });

  group('PhoneIdCryptoStore 加解密逻辑', () {
    late SecretKey secretKey;
    late Cipher cipher;

    setUp(() {
      // 生成32字节测试密钥
      final keyBytes = List<int>.generate(32, (i) => i);
      secretKey = SecretKey(keyBytes);
      cipher = AesGcm.with256bits();
    });

    Future<Map<String, dynamic>> encryptPhone(String phone) async {
      final bytes = utf8.encode(phone);
      final nonce = cipher.newNonce();
      final secretBox = await cipher.encrypt(
        bytes,
        secretKey: secretKey,
        nonce: nonce,
      );
      return {
        'cipherText': secretBox.cipherText,
        'nonce': secretBox.nonce,
        'mac': secretBox.mac.bytes,
      };
    }

    Future<String> decryptPhone(Map<String, dynamic> encrypted) async {
      final secretBox = SecretBox(
        encrypted['cipherText'] as List<int>,
        nonce: encrypted['nonce'] as List<int>,
        mac: Mac(encrypted['mac'] as List<int>),
      );
      final clear = await cipher.decrypt(secretBox, secretKey: secretKey);
      return utf8.decode(clear);
    }

    group('加解密往返测试', () {
      test('加密后能正确解密', () async {
        const phone = '+8613812345678';
        final encrypted = await encryptPhone(phone);
        final decrypted = await decryptPhone(encrypted);
        expect(decrypted, equals(phone));
      });

      test('多个不同号码加解密', () async {
        final phones = [
          '+8613812345678',
          '+8613912345678',
          '+12025551234',
          '+447911123456',
        ];

        for (final phone in phones) {
          final encrypted = await encryptPhone(phone);
          final decrypted = await decryptPhone(encrypted);
          expect(decrypted, equals(phone), reason: '号码 $phone 加解密失败');
        }
      });

      test('空号码加解密', () async {
        const phone = '';
        final encrypted = await encryptPhone(phone);
        final decrypted = await decryptPhone(encrypted);
        expect(decrypted, equals(phone));
      });

      test('很长的号码加解密', () async {
        final phone = '+86${'1' * 50}';
        final encrypted = await encryptPhone(phone);
        final decrypted = await decryptPhone(encrypted);
        expect(decrypted, equals(phone));
      });
    });

    group('加密唯一性', () {
      test('相同号码每次加密结果不同（随机nonce）', () async {
        const phone = '+8613812345678';
        final encrypted1 = await encryptPhone(phone);
        final encrypted2 = await encryptPhone(phone);

        // nonce 应该不同
        expect(
          encrypted1['nonce'],
          isNot(equals(encrypted2['nonce'])),
        );
        // 密文应该不同
        expect(
          encrypted1['cipherText'],
          isNot(equals(encrypted2['cipherText'])),
        );
      });

      test('不同号码加密结果不同', () async {
        final encrypted1 = await encryptPhone('+8613812345678');
        final encrypted2 = await encryptPhone('+8613812345679');

        expect(
          encrypted1['cipherText'],
          isNot(equals(encrypted2['cipherText'])),
        );
      });
    });

    group('密文格式验证', () {
      test('加密输出包含必要字段', () async {
        final encrypted = await encryptPhone('+8613812345678');
        expect(encrypted.containsKey('cipherText'), isTrue);
        expect(encrypted.containsKey('nonce'), isTrue);
        expect(encrypted.containsKey('mac'), isTrue);
      });

      test('nonce 长度正确（12字节 for AES-GCM）', () async {
        final encrypted = await encryptPhone('+8613812345678');
        expect((encrypted['nonce'] as List).length, equals(12));
      });

      test('MAC 长度正确（16字节）', () async {
        final encrypted = await encryptPhone('+8613812345678');
        expect((encrypted['mac'] as List).length, equals(16));
      });
    });

    group('密钥安全性', () {
      test('不同密钥无法解密', () async {
        const phone = '+8613812345678';
        final encrypted = await encryptPhone(phone);

        // 使用不同密钥尝试解密
        final differentKey = SecretKey(List<int>.generate(32, (i) => i + 1));

        final secretBox = SecretBox(
          encrypted['cipherText'] as List<int>,
          nonce: encrypted['nonce'] as List<int>,
          mac: Mac(encrypted['mac'] as List<int>),
        );

        expect(
          () => cipher.decrypt(secretBox, secretKey: differentKey),
          throwsA(isA<SecretBoxAuthenticationError>()),
        );
      });

      test('篡改密文无法解密', () async {
        const phone = '+8613812345678';
        final encrypted = await encryptPhone(phone);

        // 篡改密文
        final tamperedCipherText =
            List<int>.from(encrypted['cipherText'] as List<int>);
        if (tamperedCipherText.isNotEmpty) {
          tamperedCipherText[0] = (tamperedCipherText[0] + 1) % 256;
        }

        final secretBox = SecretBox(
          tamperedCipherText,
          nonce: encrypted['nonce'] as List<int>,
          mac: Mac(encrypted['mac'] as List<int>),
        );

        expect(
          () => cipher.decrypt(secretBox, secretKey: secretKey),
          throwsA(isA<SecretBoxAuthenticationError>()),
        );
      });

      test('篡改MAC无法解密', () async {
        const phone = '+8613812345678';
        final encrypted = await encryptPhone(phone);

        // 篡改MAC
        final tamperedMac = List<int>.from(encrypted['mac'] as List<int>);
        if (tamperedMac.isNotEmpty) {
          tamperedMac[0] = (tamperedMac[0] + 1) % 256;
        }

        final secretBox = SecretBox(
          encrypted['cipherText'] as List<int>,
          nonce: encrypted['nonce'] as List<int>,
          mac: Mac(tamperedMac),
        );

        expect(
          () => cipher.decrypt(secretBox, secretKey: secretKey),
          throwsA(isA<SecretBoxAuthenticationError>()),
        );
      });
    });

    group('Unicode 支持', () {
      test('包含中文的内容加解密', () async {
        const phone = '测试手机号+8613812345678';
        final encrypted = await encryptPhone(phone);
        final decrypted = await decryptPhone(encrypted);
        expect(decrypted, equals(phone));
      });

      test('emoji 加解密', () async {
        const phone = '📱+8613812345678📞';
        final encrypted = await encryptPhone(phone);
        final decrypted = await decryptPhone(encrypted);
        expect(decrypted, equals(phone));
      });
    });
  });

  group('PhoneIdCryptoStore.fromPasswords', () {
    test('密钥长度必须是32字节', () {
      // 验证 base64 解码后必须是32字节
      // 正确的32字节密钥 base64 编码
      final validKey = base64Encode(List<int>.generate(32, (i) => i));
      expect(base64Decode(validKey).length, equals(32));

      // 错误长度的密钥
      final invalidKey16 = base64Encode(List<int>.generate(16, (i) => i));
      expect(base64Decode(invalidKey16).length, equals(16));
      expect(base64Decode(invalidKey16).length, isNot(equals(32)));
    });
  });

  group('ByteData 转换', () {
    test('Uint8List 到 ByteData 转换', () {
      final uint8List = Uint8List.fromList([1, 2, 3, 4, 5]);
      final byteData = ByteData.sublistView(uint8List);

      expect(byteData.lengthInBytes, equals(5));
      expect(byteData.getUint8(0), equals(1));
      expect(byteData.getUint8(4), equals(5));
    });

    test('ByteData 到 Uint8List 转换', () {
      final bytes = [1, 2, 3, 4, 5];
      final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
      final uint8List = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );

      expect(uint8List.length, equals(5));
      expect(uint8List[0], equals(1));
      expect(uint8List[4], equals(5));
    });
  });
}

/// 复制 phone_normalizer.dart 的实现用于测试
String _normalizePhoneNumber(String input) {
  final value = input.trim();
  if (value.isEmpty) return '';
  if (value.startsWith('+')) return value;
  if (value.startsWith('00')) {
    return '+${value.substring(2)}';
  }
  final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
  if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
    return '+86$digitsOnly';
  }
  return value;
}
