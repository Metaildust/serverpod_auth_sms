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
