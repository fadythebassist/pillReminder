class AppConstants {
  static const String appName = 'Pill Reminder';
  static const String appVersion = '1.0.0';

  static const String doseRecordBoxName = 'dose_records';

  // Legacy key used by early versions (stored as hours).
  static const String lockoutHoursKey = 'lockout_hours';
  // Current key (stored as minutes).
  static const String lockoutMinutesKey = 'lockout_minutes';
  static const String reminderEnabledKey = 'reminder_enabled';
  static const String reminderTimeKey = 'reminder_time';

  static const int defaultLockoutMinutes = 4 * 60;
  static const String defaultReminderTime = '20:00';

  static const int historyDays = 30;

  static const int notificationId = 0;
  static const String notificationChannelId = 'pill_reminder_channel';
  static const String notificationChannelName = 'Daily Reminder';
  static const String notificationChannelDesc =
      'Reminds you to take your pill daily';

  // Presets (in minutes).
  static const List<int> lockoutPresetMinutes = [60, 120, 240, 480];
}
