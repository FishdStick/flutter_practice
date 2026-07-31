
class DateFormattingUtils {
  // I can format the date in a way where Ill display it with text but store it
  // in the db as mm-dd-yyyy
  String formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$month-$day-$year';
  }
}