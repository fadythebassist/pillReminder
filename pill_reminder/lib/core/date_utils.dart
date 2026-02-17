import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _dateKeyFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayDateFormat = DateFormat('EEEE, MMMM d');
  static final DateFormat _shortDateFormat = DateFormat('EEE MMM d');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  static String getDateKey(DateTime date) {
    return _dateKeyFormat.format(date);
  }

  static DateTime parseKey(String key) {
    return _dateKeyFormat.parse(key);
  }

  static String getTodayKey() {
    return getDateKey(DateTime.now());
  }

  static String getDisplayDate(DateTime date) {
    return _displayDateFormat.format(date);
  }

  static String getTodayDisplayDate() {
    return getDisplayDate(DateTime.now());
  }

  static String getShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  static bool isToday(String dateKey) {
    return dateKey == getTodayKey();
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static List<DateTime> getLast30Days() {
    final now = DateTime.now();
    return List.generate(30, (index) {
      return startOfDay(now.subtract(Duration(days: index)));
    });
  }

  static bool isInLockout(DateTime? takenAt, int lockoutMinutes) {
    if (takenAt == null) return false;
    final now = DateTime.now();
    final lockoutEnd = takenAt.add(Duration(minutes: lockoutMinutes));
    return now.isBefore(lockoutEnd) || now.isAtSameMomentAs(lockoutEnd);
  }
}
