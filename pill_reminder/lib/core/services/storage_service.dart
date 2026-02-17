import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/reminder.dart';
import '../../models/medicine_dose.dart';
import '../constants.dart';
import '../date_utils.dart';

class StorageService {
  static late Box<Reminder> _reminderBox;
  static late Box<MedicineDose> _medicineDoseBox;
  static late SharedPreferences _prefs;

  static const String _reminderBoxName = 'reminders';
  static const String _medicineDoseBoxName = 'medicine_doses';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ReminderAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(ReminderMedicineAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(MedicineDoseAdapter());
    }
    _reminderBox = await Hive.openBox<Reminder>(_reminderBoxName);
    _medicineDoseBox = await Hive.openBox<MedicineDose>(_medicineDoseBoxName);
    _prefs = await SharedPreferences.getInstance();
  }

  static List<Reminder> getAllReminders() {
    return _reminderBox.values.toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  static Reminder? getReminder(String id) {
    return _reminderBox.get(id);
  }

  static Future<void> saveReminder(Reminder reminder) async {
    await _reminderBox.put(reminder.id, reminder);
  }

  static Future<void> deleteReminder(String id) async {
    final reminder = _reminderBox.get(id);
    if (reminder != null) {
      for (final medicine in reminder.medicines) {
        final dosesToDelete = _medicineDoseBox.values
            .where((dose) => dose.medicineId == medicine.id)
            .map((dose) => dose.storageKey)
            .toList();
        for (var key in dosesToDelete) {
          await _medicineDoseBox.delete(key);
        }
      }
    }
    await _reminderBox.delete(id);
  }

  static Future<void> saveMedicineDose(MedicineDose dose) async {
    await _medicineDoseBox.put(dose.storageKey, dose);
  }

  static MedicineDose? getMedicineDose(
      String medicineId, String date, String time) {
    final key = 'dose_${medicineId}_${date}_$time';
    return _medicineDoseBox.get(key);
  }

  static List<MedicineDose> getTodayDoses() {
    final today = AppDateUtils.getTodayKey();
    return _medicineDoseBox.values.where((dose) => dose.date == today).toList();
  }

  static List<MedicineDose> getDosesForMedicine(String medicineId) {
    return _medicineDoseBox.values
        .where((dose) => dose.medicineId == medicineId)
        .toList();
  }

  static List<MedicineDose> getLast30Days() {
    final days = AppDateUtils.getLast30Days();
    final List<MedicineDose> result = [];
    for (var date in days) {
      final dateKey = AppDateUtils.getDateKey(date);
      result.addAll(_medicineDoseBox.values
          .where((dose) => dose.date == dateKey)
          .toList());
    }
    return result;
  }

  static bool _isReminderActiveOnDate(Reminder reminder, DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final start = DateTime(
      reminder.startDate.year,
      reminder.startDate.month,
      reminder.startDate.day,
    );
    if (day.isBefore(start)) return false;

    final end = reminder.effectiveEndDate;
    if (end == null) return true;

    final endDay = DateTime(end.year, end.month, end.day);
    return !day.isAfter(endDay);
  }

  static Set<String> _expectedDoseKeysForDate(DateTime date) {
    final dateKey = AppDateUtils.getDateKey(date);
    final keys = <String>{};
    for (final reminder in getAllReminders()) {
      if (!_isReminderActiveOnDate(reminder, date)) continue;
      for (final medicine in reminder.medicines) {
        keys.add('dose_${medicine.id}_${dateKey}_${reminder.time}');
      }
    }
    return keys;
  }

  static int calculateExpectedDays() {
    final days = AppDateUtils.getLast30Days();
    var expectedDays = 0;
    for (final date in days) {
      if (_expectedDoseKeysForDate(date).isNotEmpty) {
        expectedDays += 1;
      }
    }
    return expectedDays;
  }

  static int calculateAdherence() {
    final days = AppDateUtils.getLast30Days();
    var adheredDays = 0;

    for (final date in days) {
      final expectedKeys = _expectedDoseKeysForDate(date);
      if (expectedKeys.isEmpty) continue;

      var allTaken = true;
      for (final key in expectedKeys) {
        final dose = _medicineDoseBox.get(key);
        if (dose == null || !dose.isTaken) {
          allTaken = false;
          break;
        }
      }

      if (allTaken) {
        adheredDays += 1;
      }
    }

    return adheredDays;
  }

  static String generateShareText() {
    final reminders = getAllReminders();
    if (reminders.isEmpty) {
      return 'No medicines added yet';
    }

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('Medication Report');
    buffer.writeln('----------------');

    for (var reminder in reminders) {
      for (var medicine in reminder.medicines) {
        final adherence = calculateMedicineAdherence(medicine.id);
        final expectedDays = calculateExpectedMedicineDays(medicine.id);
        final percentage =
            expectedDays == 0 ? 0 : ((adherence / expectedDays) * 100).round();
        buffer.writeln(
            '${medicine.name} (${medicine.dose} ${medicine.unit}): $adherence/$expectedDays days ($percentage%)');
      }
    }

    return buffer.toString();
  }

  static int calculateMedicineAdherence(String medicineId) {
    final last30Days = AppDateUtils.getLast30Days();

    var adheredDays = 0;
    for (final date in last30Days) {
      final dateKey = AppDateUtils.getDateKey(date);
      final expectedKeys = <String>{};

      for (final reminder in getAllReminders()) {
        if (!_isReminderActiveOnDate(reminder, date)) continue;
        for (final medicine in reminder.medicines) {
          if (medicine.id == medicineId) {
            expectedKeys.add('dose_${medicineId}_${dateKey}_${reminder.time}');
          }
        }
      }

      if (expectedKeys.isEmpty) continue;

      var allTaken = true;
      for (final key in expectedKeys) {
        final dose = _medicineDoseBox.get(key);
        if (dose == null || !dose.isTaken) {
          allTaken = false;
          break;
        }
      }

      if (allTaken) {
        adheredDays += 1;
      }
    }

    return adheredDays;
  }

  static int calculateExpectedMedicineDays(String medicineId) {
    final last30Days = AppDateUtils.getLast30Days();
    var expectedDays = 0;

    for (final date in last30Days) {
      var hasAny = false;
      for (final reminder in getAllReminders()) {
        if (!_isReminderActiveOnDate(reminder, date)) continue;
        if (reminder.medicines.any((m) => m.id == medicineId)) {
          hasAny = true;
          break;
        }
      }
      if (hasAny) {
        expectedDays += 1;
      }
    }

    return expectedDays;
  }

  static int getLockoutMinutes() {
    final minutes = _prefs.getInt(AppConstants.lockoutMinutesKey);
    if (minutes != null) return minutes;

    // Migrate legacy hours value if present.
    final legacyHours = _prefs.getInt(AppConstants.lockoutHoursKey);
    if (legacyHours != null) {
      final migrated = legacyHours * 60;
      // ignore: unawaited_futures
      _prefs.setInt(AppConstants.lockoutMinutesKey, migrated);
      return migrated;
    }

    return AppConstants.defaultLockoutMinutes;
  }

  static Future<void> setLockoutMinutes(int minutes) async {
    await _prefs.setInt(AppConstants.lockoutMinutesKey, minutes);
  }

  static bool getReminderEnabled() {
    return _prefs.getBool(AppConstants.reminderEnabledKey) ?? false;
  }

  static Future<void> setReminderEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.reminderEnabledKey, enabled);
  }

  static String getReminderTime() {
    return _prefs.getString(AppConstants.reminderTimeKey) ??
        AppConstants.defaultReminderTime;
  }

  static Future<void> setReminderTime(String time) async {
    await _prefs.setString(AppConstants.reminderTimeKey, time);
  }
}
