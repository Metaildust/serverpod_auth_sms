class SmsAuthUiConfig {
  final bool enableSamePasswordBanner;
  final String? samePasswordBannerTitle;
  final String? samePasswordBannerBody;

  const SmsAuthUiConfig({
    this.enableSamePasswordBanner = false,
    this.samePasswordBannerTitle,
    this.samePasswordBannerBody,
  });
}

class SmsAuthUiConfigStore {
  static SmsAuthUiConfig _config = const SmsAuthUiConfig();

  static SmsAuthUiConfig get config => _config;

  static void configure(SmsAuthUiConfig config) {
    _config = config;
  }
}
