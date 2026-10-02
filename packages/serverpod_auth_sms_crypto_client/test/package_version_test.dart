import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('加密客户端升到 0.1.7，核心客户端下界是 ^0.3.0', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(
      RegExp(r'^version:\s*0\.1\.7\s*$', multiLine: true).hasMatch(pubspec),
      isTrue,
    );
    expect(pubspec, contains('serverpod_auth_sms_core_client: ^0.3.0'));

    final changelog = File('CHANGELOG.md').readAsStringSync();
    expect(changelog, contains('## 0.1.7'));
    expect(changelog, contains('^0.3.0'));
  });
}
