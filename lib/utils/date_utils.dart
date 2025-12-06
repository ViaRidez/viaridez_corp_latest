import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date, {String format = 'MMM dd, yyyy'}) {
    return DateFormat(format).format(date);
  }

  static String formatDateFromString(String dateStr,
      {String format = 'MMM dd, yyyy'}) {
    try {
      final date = DateTime.parse(dateStr);
      return formatDate(date, format: format);
    } catch (e) {
      return 'Invalid date';
    }
  }

  static int calculateDaysLeft(String dateStr) {
    try {
      final expiryDate = DateTime.parse(dateStr);
      final currentDate = DateTime.now();
      final daysLeft = expiryDate.difference(currentDate).inDays;
      return daysLeft < 0 ? 0 : daysLeft;
    } catch (e) {
      return 0;
    }
  }
}
