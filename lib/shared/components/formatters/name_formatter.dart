import 'package:flutter/services.dart';

/// Formatter to prevent trailing and leading spaces in names
/// Allows spaces within the name but trims them at the edges
class NameFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;

    // Prevent leading spaces
    if (newText.startsWith(' ')) {
      newText = newText.trimLeft();
    }

    // Prevent trailing spaces (but allow spaces in the middle)
    if (newText.endsWith(' ') && newText.length > 1) {
      // Only trim if there are multiple consecutive spaces at the end
      if (newText.length > oldValue.text.length &&
          oldValue.text.endsWith(' ')) {
        newText = newText.trimRight();
      }
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
