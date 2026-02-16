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
    return _reminderBox.values.toList()..sort((a, b) => a.time.compareTo(b.time));
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

  static MedicineDose? getMedicineDose(String medicineId, String date, String time) {
    final key = 'dose_${medicineId}_${date}_$time';
    return _medicineDoseBox.get(key);
  }

  static List<MedicineDose> getTodayDoses() {
    final today = AppDateUtils.getTodayKey();
    return _medicineDoseBox.values
        .where((dose) => dose.date == today)
        .toList();
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
      result.addAll(
        _medicineDoseBox.values.where((dose) => dose.date == dateKey).toList()
      );
    }
    return result;
  }

  static int calculateAdherence() {
    final doses = getLast30Days();
    return doses.where((d) => d.isTaken).length;
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
        final percentage = ((adherence / AppConstants.historyDays) * 100).round();
        buffer.writeln('${medicine.name} (${medicine.dose} ${medicine.unit}): $adherence/${AppConstants.historyDays} days ($percentage%)');
      }
    }
    
    return buffer.toString();
  }

  static int calculateMedicineAdherence(String medicineId) {
    final doses = getDosesForMedicine(medicineId);
    final last30Days = AppDateUtils.getLast30Days();
    final dateKeys = last30Days.map((d) => AppDateUtils.getDateKey(d)).toSet();
    
    final relevantDoses = doses.where((d) => dateKeys.contains(d.date)).toList();
    return relevantDoses.where((d) => d.isTaken).length;
  }

  static int getLockoutHours() {
    return _prefs.getInt(AppConstants.lockoutHoursKey) ?? AppConstants.defaultLockoutHours;
  }

  static Future<void> setLockoutHours(int hours) async {
    await _prefs.setInt(AppConstants.lockoutHoursKey, hours);
  }

  static bool getReminderEnabled() {
    return _prefs.getBool(AppConstants.reminderEnabledKey) ?? false;
  }

  static Future<void> setReminderEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.reminderEnabledKey, enabled);
  }

  static String getReminderTime() {
    return _prefs.getString(AppConstants.reminderTimeKey) ?? AppConstants.defaultReminderTime;
  }

  static Future<void> setReminderTime(String time) async {
    await _prefs.setString(AppConstants.reminderTimeKey, time);
  }
}
