import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../constants.dart';
import '../../models/reminder.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // Fallback: keep default tz.local (typically UTC).
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createNotificationChannel();
    _initialized = true;
  }

  static Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      description: AppConstants.notificationChannelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static void _onNotificationTapped(NotificationResponse response) {}

  static Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iOS = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    bool? granted;
    if (android != null) {
      granted = await android.requestNotificationsPermission();
      try {
        // Android 12+ may require user approval for exact alarms.
        await android.requestExactAlarmsPermission();
      } catch (_) {}
    }
    if (iOS != null) {
      granted = await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    return granted ?? false;
  }

  static Future<void> scheduleAllReminders(List<Reminder> reminders) async {
    await cancelAllReminders();

    for (final reminder in reminders) {
      final medicineNames = reminder.medicines
          .map((m) => '${m.dose} ${m.unit} ${m.name}')
          .join(', ');

      if (reminder.schedule == ReminderScheduleType.dailyForever) {
        final notificationId = _stableId('reminder_${reminder.id}');
        await _scheduleRecurringDaily(
          notificationId: notificationId,
          title: 'Time for your medicines',
          body: 'Take: $medicineNames',
          timeString: reminder.time,
        );
        continue;
      }

      final endDate = reminder.effectiveEndDate;
      if (endDate == null) {
        final notificationId = _stableId('reminder_${reminder.id}');
        await _scheduleRecurringDaily(
          notificationId: notificationId,
          title: 'Time for your medicines',
          body: 'Take: $medicineNames',
          timeString: reminder.time,
        );
        continue;
      }

      final start = DateTime(
        reminder.startDate.year,
        reminder.startDate.month,
        reminder.startDate.day,
      );
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      final totalDays = end.difference(start).inDays + 1;
      final daysToSchedule = totalDays.clamp(0, 365);

      for (var dayIndex = 0; dayIndex < daysToSchedule; dayIndex++) {
        final date = start.add(Duration(days: dayIndex));
        final notificationId =
            _stableId('reminder_${reminder.id}_${_dateKey(date)}');
        await _scheduleOneShotForDate(
          notificationId: notificationId,
          title: 'Time for your medicines',
          body: 'Take: $medicineNames',
          date: date,
          timeString: reminder.time,
        );
      }
    }
  }

  static int _stableId(String input) {
    // String.hashCode is not guaranteed stable across app launches.
    // Use a small deterministic hash so notification IDs remain consistent.
    const int fnvPrime = 0x01000193; // 16777619
    int hash = 0x811C9DC5; // 2166136261
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * fnvPrime) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }

  static String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static NotificationDetails _notificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  static Future<void> _scheduleRecurringDaily({
    required int notificationId,
    required String title,
    required String body,
    required String timeString,
  }) async {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final notificationDetails = _notificationDetails();

    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> _scheduleOneShotForDate({
    required int notificationId,
    required String title,
    required String body,
    required DateTime date,
    required String timeString,
  }) async {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

    // If it's already passed, skip.
    if (!scheduledDate.isAfter(now)) {
      return;
    }

    final notificationDetails = _notificationDetails();

    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  static Future<void> sendTestNotification() async {
    await requestPermissions();
    final notificationDetails = _notificationDetails();

    await _notifications.show(
      999,
      'Test Notification',
      'Notifications are working!',
      notificationDetails,
    );
  }

  static Future<void> scheduleQuickTest(
      {Duration delay = const Duration(minutes: 1)}) async {
    await requestPermissions();
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(delay);
    final notificationDetails = _notificationDetails();

    await _notifications.zonedSchedule(
      998,
      'Scheduled Test',
      'If you see this, scheduling works.',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
