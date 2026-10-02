import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('相对已发 0.2.0 删了旧绑定方法，版本升到 0.3.0', () {
    final client = File(
      'lib/src/protocol/client.dart',
    ).readAsStringSync();
    expect(RegExp(r'verifyBindCode\(').hasMatch(client), isFalse);
    expect(RegExp(r'finishBindPhone\(').hasMatch(client), isFalse);
    expect(client, contains('verifyBindCodeV2('));
    expect(client, contains('finishBindPhoneV2('));

    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(
      RegExp(r'^version:\s*0\.3\.0\s*$', multiLine: true).hasMatch(pubspec),
      isTrue,
    );

    final changelog = File('CHANGELOG.md').readAsStringSync();
    final notes = RegExp(
      r'^## 0\.3\.0\s*$([\s\S]*?)(?=^## |\z)',
      multiLine: true,
    ).firstMatch(changelog);
    expect(notes, isNotNull);
    final section = notes!.group(1)!;
    expect(section, contains('verifyBindCode'));
    expect(section, contains('finishBindPhone'));
  });
}
