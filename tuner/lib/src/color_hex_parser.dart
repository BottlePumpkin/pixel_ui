import 'package:flutter/painting.dart';

final RegExp _hexRegex = RegExp(r'^#?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$');

/// Parses a hex string like `#AABBCC` or `FF112233` into a [Color].
///
/// - 6 hex chars → opaque RGB with alpha forced to 0xFF.
/// - 8 hex chars → ARGB.
/// - Leading `#` optional; case-insensitive.
/// - Returns null for any other length or non-hex characters.
Color? parseHex(String input) {
  if (!_hexRegex.hasMatch(input)) return null;
  final cleaned = input.startsWith('#') ? input.substring(1) : input;
  final value = int.parse(cleaned, radix: 16);
  if (cleaned.length == 6) {
    return Color(0xFF000000 | value);
  }
  return Color(value);
}
