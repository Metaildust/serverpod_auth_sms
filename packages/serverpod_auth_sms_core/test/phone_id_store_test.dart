import 'package:serverpod_auth_sms_core_server/src/phone/phone_id_store.dart';
import 'package:test/test.dart';

void main() {
  group('PhoneAlreadyBoundException', () {
    test('默认消息', () {
      const exception = PhoneAlreadyBoundException();
      expect(exception.message, equals('Phone already bound'));
      expect(exception.toString(), contains('PhoneAlreadyBoundException'));
      expect(exception.toString(), contains('Phone already bound'));
    });

    test('自定义消息', () {
      const exception = PhoneAlreadyBoundException('Custom message');
      expect(exception.message, equals('Custom message'));
      expect(exception.toString(), contains('Custom message'));
    });
  });

  group('PhoneRebindNotAllowedException', () {
    test('默认消息', () {
      const exception = PhoneRebindNotAllowedException();
      expect(exception.message, equals('Phone rebind disabled'));
      expect(exception.toString(), contains('PhoneRebindNotAllowedException'));
      expect(exception.toString(), contains('Phone rebind disabled'));
    });

    test('自定义消息', () {
      const exception = PhoneRebindNotAllowedException('Rebind not allowed');
      expect(exception.message, equals('Rebind not allowed'));
      expect(exception.toString(), contains('Rebind not allowed'));
    });
  });
}
