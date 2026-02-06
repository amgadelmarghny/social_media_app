import 'package:intl/intl.dart';

/// Returns a label for the given [dateTime] to be used in chat message grouping.
/// The label can be "Today", "Yesterday", the day of the week (e.g., "Wednesday"),
/// or a formatted date (e.g., "12/06/2024") if older than a week.
String getMessageDateLabel(DateTime dateTime) {
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(const Duration(days: 1));
  DateTime msgDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (msgDate == today) {
    return "Today";
  } else if (msgDate == yesterday) {
    return "Yesterday";
  } else if (msgDate.isAfter(today.subtract(const Duration(days: 7)))) {
    return DateFormat('EEEE').format(dateTime);
  } else {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
}

/// Returns a friendly time label (e.g., "1m", "2h", "Yesterday", "Friday")
/// based on the difference from the current time.
String getFriendlyTimeLabel(DateTime dateTime) {
  DateTime now = DateTime.now();
  Duration diff = now.difference(dateTime);

  if (diff.inMinutes < 60) {
    if (diff.inMinutes <= 0) return "1m";
    return "${diff.inMinutes}m";
  } else if (diff.inHours < 24) {
    return "${diff.inHours}h";
  } else {
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (targetDate == yesterday) {
      return "Yesterday";
    } else if (targetDate.isAfter(today.subtract(const Duration(days: 7)))) {
      return DateFormat('EEEE').format(dateTime); // Weekday name
    } else {
      return DateFormat.yMMMd().format(dateTime); // e.g., Feb 6, 2024
    }
  }
}
