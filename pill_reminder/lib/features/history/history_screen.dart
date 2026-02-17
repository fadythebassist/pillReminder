import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/date_utils.dart';
import '../../core/services/storage_service.dart';
import '../../models/medicine_dose.dart';
import '../../models/reminder.dart';
import '../../providers/app_providers.dart';
import '../../widgets/ad_banner_placeholder.dart';
import '../../widgets/app_background.dart';
import 'widgets/history_row.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  bool _isReminderActiveOnDate(Reminder reminder, DateTime date) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adherence = ref.watch(adherenceProvider);
    final last30Days = AppDateUtils.getLast30Days();
    final doses = ref.watch(historyDosesProvider);
    final reminders = ref.watch(remindersProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final medicineMap = <String, String>{};
    for (var reminder in reminders) {
      for (var medicine in reminder.medicines) {
        medicineMap[medicine.id] = medicine.name;
      }
    }

    final dosesByDate = <String, List<MedicineDose>>{};
    for (final dose in doses) {
      (dosesByDate[dose.date] ??= []).add(dose);
    }

    final visibleDays = <DateTime>[];
    var expectedDays = 0;
    for (final date in last30Days) {
      final dateKey = AppDateUtils.getDateKey(date);
      final hasDoses = dosesByDate[dateKey]?.isNotEmpty ?? false;
      final hasExpected =
          reminders.any((r) => _isReminderActiveOnDate(r, date));

      if (hasExpected) expectedDays += 1;
      if (hasExpected || hasDoses) {
        visibleDays.add(date);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
        ),
      ),
      body: SafeArea(
        child: AppBackground(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Card(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scheme.primary.withValues(alpha: 0.10),
                          scheme.secondary.withValues(alpha: 0.12),
                          Colors.white,
                        ],
                        stops: const [0, 0.55, 1],
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Adherence (last ${AppConstants.historyDays} days)',
                          style: textTheme.labelLarge?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.72),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$adherence / $expectedDays',
                          style: textTheme.displaySmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expectedDays == 0
                              ? '0%'
                              : '${((adherence / expectedDays) * 100).round()}%',
                          style: textTheme.titleMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: AdBannerPlaceholder(),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Card(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: ListView.builder(
                    itemCount: visibleDays.length,
                    itemBuilder: (context, index) {
                      final date = visibleDays[index];
                      final dateKey = AppDateUtils.getDateKey(date);

                      final dayDoses = (dosesByDate[dateKey] ??
                              const <MedicineDose>[])
                          .toList()
                        ..sort((a, b) {
                          final timeCmp =
                              b.scheduledTime.compareTo(a.scheduledTime);
                          if (timeCmp != 0) return timeCmp;
                          return b.storageKey.compareTo(a.storageKey);
                        });

                      if (dayDoses.isEmpty) {
                        return HistoryRow(
                          date: date,
                          scheduledTime: null,
                          isTaken: false,
                          takenAt: null,
                          medicineName: null,
                        );
                      }

                      return Column(
                        children: dayDoses.map((dose) {
                          return HistoryRow(
                            date: date,
                            scheduledTime: dose.scheduledTime,
                            isTaken: dose.isTaken,
                            takenAt: dose.takenAt,
                            medicineName: medicineMap[dose.medicineId],
                            onUndo: dose.isTaken
                                ? () async {
                                    await StorageService.saveMedicineDose(
                                      dose.clear(),
                                    );

                                    // If we undid something for today, update the in-memory list too.
                                    if (dose.date ==
                                        AppDateUtils.getTodayKey()) {
                                      ref
                                          .read(todayDosesProvider.notifier)
                                          .loadTodayDoses();
                                    }

                                    ref.invalidate(historyDosesProvider);
                                    ref.invalidate(adherenceProvider);
                                    ref.invalidate(shareTextProvider);
                                  }
                                : null,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
