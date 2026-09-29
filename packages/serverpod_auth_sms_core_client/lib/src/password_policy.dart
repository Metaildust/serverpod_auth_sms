/// 默认密码最小长度。
const kDefaultPasswordMinLength = 8;

final _asciiSpecialCharPattern = RegExp(
  r'[\x21-\x2F\x3A-\x40\x5B-\x60\x7B-\x7E]',
);

/// 评估认证密码策略。
///
/// 当前规则与服务端包默认密码校验函数保持同一套六项布尔：
/// - 至少 [minLength] 位（默认 [kDefaultPasswordMinLength]）
/// - 仅允许 ASCII 可打印字符
/// - 必须包含大写、小写、数字与半角特殊字符
AuthPasswordPolicyEvaluation evaluateAuthPasswordPolicy(
  String password, {
  int minLength = kDefaultPasswordMinLength,
}) {
  final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
  final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
  final hasDigits = RegExp(r'[0-9]').hasMatch(password);
  final hasSpecialChars = _asciiSpecialCharPattern.hasMatch(password);
  final hasMinLength = password.length >= minLength;
  final isAllAscii =
      password.isNotEmpty &&
      password.runes.every((c) => c >= 0x20 && c <= 0x7E);

  return AuthPasswordPolicyEvaluation(
    hasMinLength: hasMinLength,
    hasUppercase: hasUppercase,
    hasLowercase: hasLowercase,
    hasDigits: hasDigits,
    hasSpecialChars: hasSpecialChars,
    isAllAscii: isAllAscii,
  );
}

/// 认证密码策略是否通过。
bool validateAuthPasswordPolicy(
  String password, {
  int minLength = kDefaultPasswordMinLength,
}) {
  return evaluateAuthPasswordPolicy(password, minLength: minLength).isValid;
}

/// 认证密码策略的逐项校验结果。
class AuthPasswordPolicyEvaluation {
  /// 是否达到调用方指定的最小长度。
  final bool hasMinLength;

  /// 是否包含大写字母。
  final bool hasUppercase;

  /// 是否包含小写字母。
  final bool hasLowercase;

  /// 是否包含数字。
  final bool hasDigits;

  /// 是否包含半角特殊字符。
  final bool hasSpecialChars;

  /// 是否全部为 ASCII 可打印字符。
  final bool isAllAscii;

  const AuthPasswordPolicyEvaluation({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasDigits,
    required this.hasSpecialChars,
    required this.isAllAscii,
  });

  /// 六项均满足时，密码可通过认证策略。
  bool get isValid =>
      hasMinLength &&
      hasUppercase &&
      hasLowercase &&
      hasDigits &&
      hasSpecialChars &&
      isAllAscii;
}
