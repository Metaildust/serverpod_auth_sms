import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('组合包升到 0.1.8，三份依赖对齐新号', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(
      RegExp(r'^version:\s*0\.1\.8\s*$', multiLine: true).hasMatch(pubspec),
      isTrue,
    );
    expect(pubspec, contains('serverpod_auth_sms_core_server: ^0.2.0'));
    expect(pubspec, contains('serverpod_auth_sms_hash_server: ^0.1.8'));
    expect(pubspec, contains('serverpod_auth_sms_crypto_server: ^0.1.8'));

    final changelog = File('CHANGELOG.md').readAsStringSync();
    expect(changelog, contains('## 0.1.8'));
  });
}
