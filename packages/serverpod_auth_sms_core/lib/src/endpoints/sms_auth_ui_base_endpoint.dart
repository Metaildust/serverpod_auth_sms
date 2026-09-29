import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../sms_auth_ui_config.dart';

abstract class SmsAuthUiBaseEndpoint extends Endpoint {
  @unauthenticatedClientCall
  Future<SmsSamePasswordBanner> getSamePasswordBanner(Session session) async {
    final config = SmsAuthUiConfigStore.config;
    return SmsSamePasswordBanner(
      enabled: config.enableSamePasswordBanner,
      title: config.samePasswordBannerTitle,
      body: config.samePasswordBannerBody,
    );
  }
}
