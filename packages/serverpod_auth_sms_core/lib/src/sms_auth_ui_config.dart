class SmsAuthUiConfig {
  final bool enableSamePasswordBanter;
  final String? samePasswordBanterTitle;
  final String? samePasswordBanterBody;

  const SmsAuthUiConfig({
    this.enableSamePasswordBanter = false,
    this.samePasswordBanterTitle,
    this.samePasswordBanterBody,
  });
}

class SmsAuthUiConfigStore {
  static SmsAuthUiConfig _config = const SmsAuthUiConfig();

  static SmsAuthUiConfig get config => _config;

  static void configure(SmsAuthUiConfig config) {
    _config = config;
  }
}
