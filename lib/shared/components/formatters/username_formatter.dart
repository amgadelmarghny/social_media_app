import 'package:flutter/services.dart';

/// Formatter to replace spaces with underscores in usernames
/// Prevents spaces and automatically converts them to underscores
class UsernameFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Replace all spaces with underscores
    String newText = newValue.text.replaceAll(' ', '_');

    // Only allow alphanumeric characters and underscores
    newText = newText.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
