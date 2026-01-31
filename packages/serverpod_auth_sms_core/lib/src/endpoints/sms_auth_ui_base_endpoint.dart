import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../sms_auth_ui_config.dart';

abstract class SmsAuthUiBaseEndpoint extends Endpoint {
  @unauthenticatedClientCall
  Future<SmsSamePasswordBanter> getSamePasswordBanter(
    Session session,
  ) async {
    final config = SmsAuthUiConfigStore.config;
    return SmsSamePasswordBanter(
      enabled: config.enableSamePasswordBanter,
      title: config.samePasswordBanterTitle,
      body: config.samePasswordBanterBody,
    );
  }
}
