import 'package:flutter_test/flutter_test.dart';
import 'package:pill_reminder/core/date_utils.dart';
import 'package:pill_reminder/core/constants.dart';

void main() {
  group('Date Utils Tests', () {
    test('getDateKey returns correct format', () {
      final date = DateTime(2026, 3, 10);
      expect(AppDateUtils.getDateKey(date), '2026-03-10');
    });

    test('getDateKey handles single digit month and day', () {
      final date = DateTime(2026, 1, 5);
      expect(AppDateUtils.getDateKey(date), '2026-01-05');
    });

    test('getTodayKey returns today date key', () {
      final today = DateTime.now();
      final expected =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      expect(AppDateUtils.getTodayKey(), expected);
    });

    test('parseKey returns correct DateTime', () {
      final parsed = AppDateUtils.parseKey('2026-03-10');
      expect(parsed.year, 2026);
      expect(parsed.month, 3);
      expect(parsed.day, 10);
    });

    test('isToday returns true for today', () {
      final todayKey = AppDateUtils.getTodayKey();
      expect(AppDateUtils.isToday(todayKey), true);
    });

    test('isToday returns false for other dates', () {
      expect(AppDateUtils.isToday('2026-01-01'), false);
    });

    test('formatTime returns correct HH:mm format', () {
      final time = DateTime(2026, 1, 1, 8, 41);
      expect(AppDateUtils.formatTime(time), '08:41');
    });

    test('formatTime handles single digit hour and minute', () {
      final time = DateTime(2026, 1, 1, 9, 5);
      expect(AppDateUtils.formatTime(time), '09:05');
    });

    test('getLast30Days returns 30 days', () {
      final days = AppDateUtils.getLast30Days();
      expect(days.length, 30);
    });

    test('getLast30Days starts with today', () {
      final days = AppDateUtils.getLast30Days();
      final today = AppDateUtils.startOfDay(DateTime.now());
      expect(days.first, today);
    });

    test('isSameDay returns true for same day', () {
      final a = DateTime(2026, 3, 10, 8, 0);
      final b = DateTime(2026, 3, 10, 20, 30);
      expect(AppDateUtils.isSameDay(a, b), true);
    });

    test('isSameDay returns false for different days', () {
      final a = DateTime(2026, 3, 10);
      final b = DateTime(2026, 3, 11);
      expect(AppDateUtils.isSameDay(a, b), false);
    });

    test('startOfDay returns midnight', () {
      final date = DateTime(2026, 3, 10, 15, 30, 45);
      final start = AppDateUtils.startOfDay(date);
      expect(start.hour, 0);
      expect(start.minute, 0);
      expect(start.second, 0);
    });
  });

  group('Lockout Logic Tests', () {
    test('isInLockout returns false when takenAt is null', () {
      expect(AppDateUtils.isInLockout(null, 240), false);
    });

    test('isInLockout returns false after lockout period', () {
      final takenAt = DateTime.now().subtract(const Duration(hours: 5));
      expect(AppDateUtils.isInLockout(takenAt, 240), false);
    });

    test('isInLockout returns true during lockout period', () {
      final takenAt = DateTime.now().subtract(const Duration(hours: 2));
      expect(AppDateUtils.isInLockout(takenAt, 240), true);
    });

    test('isInLockout returns true at exactly lockout end', () {
      final takenAt = DateTime.now().subtract(const Duration(hours: 4));
      expect(AppDateUtils.isInLockout(takenAt, 240), true);
    });

    test('isInLockout returns false just after lockout end', () {
      final takenAt =
          DateTime.now().subtract(const Duration(hours: 4, minutes: 1));
      expect(AppDateUtils.isInLockout(takenAt, 240), false);
    });

    test('isInLockout works with 1 hour lockout', () {
      final takenAt = DateTime.now().subtract(const Duration(minutes: 30));
      expect(AppDateUtils.isInLockout(takenAt, 60), true);
    });

    test('isInLockout works with 8 hour lockout', () {
      final takenAt = DateTime.now().subtract(const Duration(hours: 6));
      expect(AppDateUtils.isInLockout(takenAt, 480), true);
    });
  });

  group('Adherence Calculation Tests', () {
    test('AppConstants has correct history days', () {
      expect(AppConstants.historyDays, 30);
    });

    test('Default lockout hours is 4', () {
      expect(AppConstants.defaultLockoutMinutes, 240);
    });

    test('Lockout options include expected values', () {
      expect(AppConstants.lockoutPresetMinutes, contains(60));
      expect(AppConstants.lockoutPresetMinutes, contains(120));
      expect(AppConstants.lockoutPresetMinutes, contains(240));
      expect(AppConstants.lockoutPresetMinutes, contains(480));
    });
  });
}
