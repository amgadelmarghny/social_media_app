import 'package:intl/intl.dart';

/// Returns a label for the given [dateTime] to be used in chat message grouping.
/// The label can be "Today", "Yesterday", the day of the week (e.g., "Wednesday"),
/// or a formatted date (e.g., "12/06/2024") if older than a week.
/// 
/// - If the message is from today, returns "Today".
/// - If the message is from yesterday, returns "Yesterday".
/// - If the message is within the last 7 days (excluding today and yesterday), returns the weekday name.
/// - Otherwise, returns the date in "dd/MM/yyyy" format.
String getMessageDateLabel(DateTime dateTime) {
  // Get the current date and time
  DateTime now = DateTime.now();

  // Create a DateTime object for today at midnight (00:00)
  DateTime today = DateTime(now.year, now.month, now.day);

  // Create a DateTime object for yesterday at midnight
  DateTime yesterday = today.subtract(Duration(days: 1));

  // Create a DateTime object for the message's date at midnight
  DateTime msgDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

  // Check if the message is from today
  if (msgDate == today) {
    return "Today";
  } 
  // Check if the message is from yesterday
  else if (msgDate == yesterday) {
    return "Yesterday";
  } 
  // Check if the message is within the last 7 days (excluding today and yesterday)
  else if (msgDate.isAfter(today.subtract(Duration(days: 7)))) {
    // Return the weekday name, e.g., "Wednesday"
    return DateFormat('EEEE').format(dateTime);
  } 
  // If the message is older than a week, return the date in "dd/MM/yyyy" format
  else {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
}