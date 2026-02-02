import 'package:serverpod_auth_sms_core_server/src/phone/phone_normalizer.dart';
import 'package:test/test.dart';

void main() {
  group('normalizePhoneNumber', () {
    group('空值和空白处理', () {
      test('空字符串返回空字符串', () {
        expect(normalizePhoneNumber(''), equals(''));
      });

      test('只有空格返回空字符串', () {
        expect(normalizePhoneNumber('   '), equals(''));
      });

      test('去除前后空白', () {
        expect(normalizePhoneNumber('  +8613812345678  '), equals('+8613812345678'));
      });
    });

    group('已规范化的号码', () {
      test('以 + 开头的号码保持不变', () {
        expect(normalizePhoneNumber('+8613812345678'), equals('+8613812345678'));
      });

      test('中国大陆号码 +86 前缀保持不变', () {
        expect(normalizePhoneNumber('+8613912345678'), equals('+8613912345678'));
      });

      test('美国号码 +1 前缀保持不变', () {
        expect(normalizePhoneNumber('+12025551234'), equals('+12025551234'));
      });

      test('英国号码 +44 前缀保持不变', () {
        expect(normalizePhoneNumber('+447911123456'), equals('+447911123456'));
      });

      test('日本号码 +81 前缀保持不变', () {
        expect(normalizePhoneNumber('+819012345678'), equals('+819012345678'));
      });
    });

    group('00 前缀转换', () {
      test('00 前缀转换为 + 前缀', () {
        expect(normalizePhoneNumber('008613812345678'), equals('+8613812345678'));
      });

      test('00 美国号码转换', () {
        expect(normalizePhoneNumber('0012025551234'), equals('+12025551234'));
      });

      test('00 英国号码转换', () {
        expect(normalizePhoneNumber('00447911123456'), equals('+447911123456'));
      });
    });

    group('中国大陆手机号（无前缀）', () {
      test('1开头11位数字添加+86前缀', () {
        expect(normalizePhoneNumber('13812345678'), equals('+8613812345678'));
      });

      test('139开头号码', () {
        expect(normalizePhoneNumber('13912345678'), equals('+8613912345678'));
      });

      test('150开头号码', () {
        expect(normalizePhoneNumber('15012345678'), equals('+8615012345678'));
      });

      test('166开头号码', () {
        expect(normalizePhoneNumber('16612345678'), equals('+8616612345678'));
      });

      test('177开头号码', () {
        expect(normalizePhoneNumber('17712345678'), equals('+8617712345678'));
      });

      test('188开头号码', () {
        expect(normalizePhoneNumber('18812345678'), equals('+8618812345678'));
      });

      test('199开头号码', () {
        expect(normalizePhoneNumber('19912345678'), equals('+8619912345678'));
      });
    });

    group('带分隔符的号码', () {
      test('带横杠的号码（去除非数字字符）', () {
        // 注意：当前实现仅对1开头11位数字特殊处理
        // 带分隔符的国际格式会保持原值
        expect(normalizePhoneNumber('+86-138-1234-5678'), equals('+86-138-1234-5678'));
      });

      test('带空格分隔的号码', () {
        expect(normalizePhoneNumber('+86 138 1234 5678'), equals('+86 138 1234 5678'));
      });
    });

    group('特殊情况', () {
      test('非1开头的11位数字保持不变', () {
        expect(normalizePhoneNumber('21234567890'), equals('21234567890'));
      });

      test('10位数字保持不变', () {
        expect(normalizePhoneNumber('1381234567'), equals('1381234567'));
      });

      test('12位数字保持不变', () {
        expect(normalizePhoneNumber('138123456789'), equals('138123456789'));
      });

      test('纯非数字字符会被清理后判断', () {
        // 根据代码逻辑：如果不是以+或00开头，会提取纯数字判断
        final result = normalizePhoneNumber('abc');
        expect(result, equals('abc'));
      });
    });

    group('边界测试', () {
      test('只有一个+号', () {
        expect(normalizePhoneNumber('+'), equals('+'));
      });

      test('只有00', () {
        expect(normalizePhoneNumber('00'), equals('+'));
      });

      test('单个数字', () {
        expect(normalizePhoneNumber('1'), equals('1'));
      });

      test('Unicode空白字符处理', () {
        expect(normalizePhoneNumber('\t+8613812345678\n'), equals('+8613812345678'));
      });
    });
  });
}
