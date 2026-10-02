import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('哈希存储升到 0.1.8，核心下界是 ^0.2.0', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(
      RegExp(r'^version:\s*0\.1\.8\s*$', multiLine: true).hasMatch(pubspec),
      isTrue,
    );
    expect(pubspec, contains('serverpod_auth_sms_core_server: ^0.2.0'));

    final changelog = File('CHANGELOG.md').readAsStringSync();
    expect(changelog, contains('## 0.1.8'));
    expect(changelog, contains('^0.2.0'));
  });
}
