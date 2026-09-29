String normalizePhoneNumber(String input) {
  final value = input.trim();
  if (value.isEmpty) return '';
  if (value.startsWith('+')) return value;
  if (value.startsWith('00')) {
    return '+${value.substring(2)}';
  }
  final digitsOnly = value.replaceAll(RegExp(r'\\D'), '');
  if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
    return '+86$digitsOnly';
  }
  return value;
}

/// 规范串：trim；去掉空格、横杠、圆括号和点；`00` 换成 `+`；
/// 以 `+` 开头则只留开头一个 `+` 和后面的数字，否则只留数字；
/// 11 位且以 1 开头则加 `+86`。空输入得到空串。
///
/// 只服务新哈希和新写入。已存的旧哈希仍走 [normalizePhoneNumber]，不得用本函数再喂给旧函数。
String canonicalPhoneNumber(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return '';
  var value = trimmed.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
  if (value.isEmpty) return '';
  if (value.startsWith('00')) {
    value = '+${value.substring(2)}';
  }
  if (value.startsWith('+')) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return '+$digits';
  }
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  if (digits.length == 11 && digits.startsWith('1')) {
    return '+86$digits';
  }
  return digits;
}
