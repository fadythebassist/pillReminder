import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/date_utils.dart';
import '../../models/reminder.dart';
import '../../models/medicine_dose.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_background.dart';
import '../reminders/add_reminder_screen.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider);
    final todayDoses = ref.watch(todayDosesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pill Reminder',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddReminderScreen()),
            ),
            tooltip: 'Add reminder',
          ),
        ],
      ),
      body: SafeArea(
        child: AppBackground(
          child: reminders.isEmpty
              ? _buildEmptyState(context)
              : _buildReminderList(context, ref, reminders, todayDoses),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 80,
              color: scheme.primary.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 24),
            Text(
              'No reminders added',
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Add your first reminder to start tracking',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.72),
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddReminderScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Reminder'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderList(
    BuildContext context,
    WidgetRef ref,
    List<Reminder> reminders,
    List<MedicineDose> todayDoses,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today',
                style: textTheme.displaySmall,
              ),
              const SizedBox(height: 4),
              Text(
                AppDateUtils.getTodayDisplayDate(),
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return _buildReminderCard(context, ref, reminder, todayDoses);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReminderCard(
    BuildContext context,
    WidgetRef ref,
    Reminder reminder,
    List<MedicineDose> todayDoses,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final timeParts = reminder.time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = timeParts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayTime = '$displayHour:$minute $period';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.alarm,
                    color: scheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayTime,
                        style: textTheme.titleLarge,
                      ),
                      Text(
                        '${reminder.medicines.length} medicine${reminder.medicines.length > 1 ? 's' : ''}',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.70),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddReminderScreen(reminder: reminder),
                    ),
                  ),
                  tooltip: 'Edit reminder',
                ),
              ],
            ),
            const Divider(height: 24),
            ...reminder.medicines.map((medicine) {
              final dose = todayDoses.firstWhere(
                (d) =>
                    d.medicineId == medicine.id &&
                    d.scheduledTime == reminder.time,
                orElse: () => MedicineDose(
                  id: '',
                  medicineId: medicine.id,
                  date: '',
                  scheduledTime: reminder.time,
                ),
              );
              final isTaken = dose.isTaken;
              final isInLockout = ref.watch(isInLockoutProvider((
                medicineId: medicine.id,
                time: reminder.time,
              )));

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isTaken
                            ? scheme.tertiary.withValues(alpha: 0.12)
                            : scheme.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isTaken ? Icons.check : Icons.medication,
                        color: isTaken
                            ? scheme.tertiary
                            : scheme.onSurface.withValues(alpha: 0.55),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicine.name,
                            style: textTheme.titleMedium,
                          ),
                          Text(
                            '${medicine.dose} ${medicine.unit}',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.70),
                            ),
                          ),
                          if (isTaken && dose.takenAt != null)
                            Text(
                              'Taken at ${AppDateUtils.formatTime(dose.takenAt!)}',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.tertiary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!isTaken)
                      FilledButton(
                        onPressed: () {
                          ref.read(todayDosesProvider.notifier).takeDose(
                                medicine.id,
                                reminder.id,
                              );
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          minimumSize: const Size(0, 40),
                        ),
                        child: const Text('Take'),
                      ),
                    if (isTaken)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (isInLockout)
                            Text(
                              'Wait ${_getRemainingLockoutTime(dose.takenAt!, ref)}',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.70),
                              ),
                            ),
                          TextButton(
                            onPressed: () {
                              ref.read(todayDosesProvider.notifier).undoDose(
                                    medicine.id,
                                    reminder.time,
                                  );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: scheme.error,
                            ),
                            child: const Text('Undo'),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getRemainingLockoutTime(DateTime takenAt, WidgetRef ref) {
    final lockoutMinutes = ref.read(lockoutMinutesProvider);
    final lockoutEnd = takenAt.add(Duration(minutes: lockoutMinutes));
    final now = DateTime.now();
    final remaining = lockoutEnd.difference(now);

    if (remaining.isNegative) return '';

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
