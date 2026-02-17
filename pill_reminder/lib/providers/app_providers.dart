import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/date_utils.dart';
import '../core/services/storage_service.dart';
import '../core/services/notification_service.dart';
import '../models/reminder.dart';
import '../models/medicine_dose.dart';

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, List<Reminder>>((ref) {
  return RemindersNotifier();
});

class RemindersNotifier extends StateNotifier<List<Reminder>> {
  RemindersNotifier() : super([]) {
    loadReminders();
  }

  void loadReminders() {
    state = StorageService.getAllReminders();
    // Don't prompt for runtime permissions on app start.
    // Scheduling may no-op if permissions are denied; we request on user actions.
    NotificationService.scheduleAllReminders(state);
  }

  Future<void> addReminder(Reminder reminder) async {
    await StorageService.saveReminder(reminder);
    state = [...state, reminder];
    await NotificationService.scheduleAllReminders(state);
  }

  Future<void> addReminders(List<Reminder> reminders) async {
    if (reminders.isEmpty) return;
    for (final reminder in reminders) {
      await StorageService.saveReminder(reminder);
    }
    state = [...state, ...reminders];
    await NotificationService.scheduleAllReminders(state);
  }

  Future<void> applyReminderChanges({
    List<Reminder> upserts = const [],
    List<String> deletes = const [],
  }) async {
    if (upserts.isEmpty && deletes.isEmpty) return;

    for (final id in deletes) {
      await StorageService.deleteReminder(id);
    }
    for (final reminder in upserts) {
      await StorageService.saveReminder(reminder);
    }

    var next = state.where((r) => !deletes.contains(r.id)).toList();
    for (final reminder in upserts) {
      final idx = next.indexWhere((r) => r.id == reminder.id);
      if (idx >= 0) {
        next[idx] = reminder;
      } else {
        next.add(reminder);
      }
    }
    next.sort((a, b) => a.time.compareTo(b.time));
    state = next;
    await NotificationService.scheduleAllReminders(state);
  }

  Future<void> updateReminder(Reminder reminder) async {
    await StorageService.saveReminder(reminder);
    state = state.map((r) => r.id == reminder.id ? reminder : r).toList();
    await NotificationService.scheduleAllReminders(state);
  }

  Future<void> deleteReminder(String id) async {
    await StorageService.deleteReminder(id);
    state = state.where((r) => r.id != id).toList();
    await NotificationService.scheduleAllReminders(state);
  }
}

final todayDosesProvider =
    StateNotifierProvider<TodayDosesNotifier, List<MedicineDose>>((ref) {
  return TodayDosesNotifier();
});

class TodayDosesNotifier extends StateNotifier<List<MedicineDose>> {
  TodayDosesNotifier() : super([]) {
    loadTodayDoses();
  }

  void loadTodayDoses() {
    state = StorageService.getTodayDoses();
  }

  Future<void> takeDose(String medicineId, String reminderId) async {
    final today = AppDateUtils.getTodayKey();
    final reminder = StorageService.getReminder(reminderId);
    if (reminder == null) return;

    final time = reminder.time;

    final existingDose =
        StorageService.getMedicineDose(medicineId, today, time);

    if (existingDose != null && existingDose.isTaken) {
      return;
    }

    final dose = MedicineDose(
      id: '${medicineId}_${today}_$time',
      medicineId: medicineId,
      date: today,
      scheduledTime: time,
      takenAt: DateTime.now(),
    );

    await StorageService.saveMedicineDose(dose);
    state = [...state, dose];
  }

  Future<void> undoDose(String medicineId, String time) async {
    final today = AppDateUtils.getTodayKey();
    final dose = StorageService.getMedicineDose(medicineId, today, time);

    if (dose != null) {
      await StorageService.saveMedicineDose(dose.clear());
      state = state
          .map((d) => d.medicineId == medicineId && d.scheduledTime == time
              ? d.clear()
              : d)
          .toList();
    }
  }
}

final lockoutMinutesProvider =
    StateNotifierProvider<LockoutMinutesNotifier, int>((ref) {
  return LockoutMinutesNotifier();
});

class LockoutMinutesNotifier extends StateNotifier<int> {
  LockoutMinutesNotifier() : super(StorageService.getLockoutMinutes());

  Future<void> setMinutes(int minutes) async {
    await StorageService.setLockoutMinutes(minutes);
    state = minutes;
  }
}

final isInLockoutProvider =
    Provider.family<bool, ({String medicineId, String time})>((ref, params) {
  final doses = ref.watch(todayDosesProvider);
  final lockoutMinutes = ref.watch(lockoutMinutesProvider);

  final dose = doses.firstWhere(
    (d) => d.medicineId == params.medicineId && d.scheduledTime == params.time,
    orElse: () => MedicineDose(
      id: '',
      medicineId: '',
      date: '',
      scheduledTime: '',
    ),
  );

  if (dose.takenAt == null) return false;

  return AppDateUtils.isInLockout(dose.takenAt, lockoutMinutes);
});

final historyDosesProvider = Provider<List<MedicineDose>>((ref) {
  // Recompute when today's doses change so History updates live while using
  // an IndexedStack/tab view.
  ref.watch(todayDosesProvider);
  return StorageService.getLast30Days();
});

final adherenceProvider = Provider<int>((ref) {
  // Keep adherence in sync with take/undo actions.
  ref.watch(todayDosesProvider);
  return StorageService.calculateAdherence();
});

final shareTextProvider = Provider<String>((ref) {
  return StorageService.generateShareText();
});
