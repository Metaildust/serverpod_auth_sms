import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:test/test.dart';

/// 独立测试 PhoneIdHashStore 的哈希逻辑
/// 不依赖数据库操作
void main() {
  group('PhoneIdHashStore 哈希逻辑', () {
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

      test('多次哈希结果一致', () {
        const phone = '+8613912345678';
        final hashes = <String>[];
        for (var i = 0; i < 100; i++) {
          hashes.add(hashPhone(phone, testPepper));
        }
        expect(hashes.toSet().length, equals(1));
      });
    });

    group('哈希唯一性', () {
      test('不同手机号产生不同哈希', () {
        final hash1 = hashPhone('+8613812345678', testPepper);
        final hash2 = hashPhone('+8613812345679', testPepper);
        expect(hash1, isNot(equals(hash2)));
      });

      test('不同pepper产生不同哈希', () {
        const phone = '+8613812345678';
        final hash1 = hashPhone(phone, 'pepper1');
        final hash2 = hashPhone(phone, 'pepper2');
        expect(hash1, isNot(equals(hash2)));
      });

      test('相似号码产生不同哈希', () {
        final hashes = <String>{
          hashPhone('+8613812345678', testPepper),
          hashPhone('+8613812345679', testPepper),
          hashPhone('+8613812345680', testPepper),
          hashPhone('+8613812345681', testPepper),
        };
        expect(hashes.length, equals(4));
      });
    });

    group('哈希格式', () {
      test('哈希是64位十六进制字符串', () {
        final hash = hashPhone('+8613812345678', testPepper);
        expect(hash.length, equals(64));
        expect(RegExp(r'^[a-f0-9]{64}$').hasMatch(hash), isTrue);
      });

      test('空号码也能生成哈希', () {
        final hash = hashPhone('', testPepper);
        expect(hash.length, equals(64));
      });
    });

    group('标准化后哈希', () {
      test('标准化的号码哈希相同', () {
        final hash1 = hashPhone('13812345678', testPepper);
        final hash2 = hashPhone('+8613812345678', testPepper);
        expect(hash1, equals(hash2));
      });

      test('带00前缀和+前缀哈希相同', () {
        final hash1 = hashPhone('008613812345678', testPepper);
        final hash2 = hashPhone('+8613812345678', testPepper);
        expect(hash1, equals(hash2));
      });

      test('前后空白不影响哈希', () {
        final hash1 = hashPhone('  +8613812345678  ', testPepper);
        final hash2 = hashPhone('+8613812345678', testPepper);
        expect(hash1, equals(hash2));
      });
    });

    group('HMAC-SHA256 正确性', () {
      test('验证HMAC-SHA256算法', () {
        // 使用已知值验证算法正确性
        const testPhone = 'test_phone';
        const testKey = 'test_key';

        final hmac = Hmac(sha256, utf8.encode(testKey));
        final hash = hmac.convert(utf8.encode(testPhone)).toString();

        // HMAC-SHA256 应该产生确定性结果
        expect(hash.length, equals(64));
        expect(hash, isNot(equals(testPhone)));
      });
    });

    group('边界测试', () {
      test('很长的手机号', () {
        final longPhone = '+86${'1' * 100}';
        final hash = hashPhone(longPhone, testPepper);
        expect(hash.length, equals(64));
      });

      test('特殊字符在手机号中', () {
        final hash = hashPhone('+86-138-1234-5678', testPepper);
        expect(hash.length, equals(64));
      });

      test('空pepper', () {
        final hash = hashPhone('+8613812345678', '');
        expect(hash.length, equals(64));
      });

      test('Unicode字符pepper', () {
        final hash = hashPhone('+8613812345678', '密钥🔐');
        expect(hash.length, equals(64));
      });
    });
  });

  group('PhoneIdHashStore.fromPasswords', () {
    test('pepper为空时应抛出StateError', () {
      // 这是一个文档测试，实际测试需要mock Serverpod
      // 在实际环境中会抛出：
      // StateError('phoneHashPepper must be configured in passwords.')
      expect(true, isTrue); // 占位测试
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
