class AppConstants {
  static const String appName = 'Pill Reminder';
  static const String appVersion = '1.0.0';

  static const String doseRecordBoxName = 'dose_records';
  
  static const String lockoutHoursKey = 'lockout_hours';
  static const String reminderEnabledKey = 'reminder_enabled';
  static const String reminderTimeKey = 'reminder_time';

  static const int defaultLockoutHours = 4;
  static const String defaultReminderTime = '20:00';

  static const int historyDays = 30;

  static const int notificationId = 0;
  static const String notificationChannelId = 'pill_reminder_channel';
  static const String notificationChannelName = 'Daily Reminder';
  static const String notificationChannelDesc = 'Reminds you to take your pill daily';

  static const List<int> lockoutOptions = [1, 2, 4, 8];
}
