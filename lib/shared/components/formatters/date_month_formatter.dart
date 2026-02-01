import 'package:flutter/services.dart';

/// Smart date/month formatter (DD/MM format)
///
/// Behavior:
/// - For day: Single digit > 3 auto-formats to 0D/ (e.g., 4 → 04/)
/// - For day: 0-31 max allowed
/// - For month: Single digit > 1 auto-formats to 0M (e.g., 2 → 02)
/// - For month: 01-12 max allowed
class DateMonthFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    String newText = text;
    int newCursorPosition = newValue.selection.end;

    // Remove any non-digit characters except slash
    text = text.replaceAll(RegExp(r'[^0-9/]'), '');

    // If user is deleting, allow it
    if (text.length < oldValue.text.length) {
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    // Remove existing slashes to rebuild properly
    String digitsOnly = text.replaceAll('/', '');

    // Maximum 4 digits (DDMM)
    if (digitsOnly.length > 4) {
      digitsOnly = digitsOnly.substring(0, 4);
    }

    // Build formatted string
    if (digitsOnly.isEmpty) {
      newText = '';
      newCursorPosition = 0;
    } else if (digitsOnly.length == 1) {
      int firstDigit = int.parse(digitsOnly[0]);

      // If first digit > 3, it must be day (04-09)
      if (firstDigit > 3) {
        newText = '0$firstDigit/';
        newCursorPosition = 3; // After the slash
      } else {
        newText = digitsOnly;
        newCursorPosition = 1;
      }
    } else if (digitsOnly.length == 2) {
      int day = int.parse(digitsOnly);

      // Validate day (01-31)
      if (day > 31) {
        // Keep only valid day part
        newText = digitsOnly[0];
        newCursorPosition = 1;
      } else {
        newText = '$digitsOnly/';
        newCursorPosition = 3;
      }
    } else if (digitsOnly.length == 3) {
      String dayPart = digitsOnly.substring(0, 2);
      String monthFirstDigit = digitsOnly[2];

      int day = int.parse(dayPart);
      int monthFirst = int.parse(monthFirstDigit);

      // Validate day
      if (day > 31 || day == 0) {
        newText = '${dayPart[0]}/';
        newCursorPosition = 2;
      } else if (monthFirst > 1) {
        // If month first digit > 1, auto-format to 0M
        newText = '$dayPart/0$monthFirstDigit';
        newCursorPosition = 6;
      } else {
        newText = '$dayPart/$monthFirstDigit';
        newCursorPosition = 4;
      }
    } else if (digitsOnly.length >= 4) {
      String dayPart = digitsOnly.substring(0, 2);
      String monthPart = digitsOnly.substring(2, 4);

      int day = int.parse(dayPart);
      int month = int.parse(monthPart);

      // Validate day and month
      if (day > 31 || day == 0) {
        newText = '${dayPart[0]}/';
        newCursorPosition = 2;
      } else if (month > 12 || month == 0) {
        // Keep valid day, reset month
        newText = '$dayPart/';
        newCursorPosition = 3;
      } else {
        newText = '$dayPart/$monthPart';
        newCursorPosition = 5;
      }
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}
