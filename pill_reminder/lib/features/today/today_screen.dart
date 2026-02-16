import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/date_utils.dart';
import '../../models/reminder.dart';
import '../../models/medicine_dose.dart';
import '../../providers/app_providers.dart';
import '../reminders/add_reminder_screen.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider);
    final todayDoses = ref.watch(todayDosesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Pill Reminder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1976D2),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddReminderScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: reminders.isEmpty
            ? _buildEmptyState(context)
            : _buildReminderList(context, ref, reminders, todayDoses),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No reminders added',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your first reminder to start tracking',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddReminderScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
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
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppDateUtils.getTodayDisplayDate(),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
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
    final timeParts = reminder.time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = timeParts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayTime = '$displayHour:$minute $period';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                    color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.alarm,
                    color: Color(0xFF1976D2),
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${reminder.medicines.length} medicine${reminder.medicines.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
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
                ),
              ],
            ),
            const Divider(height: 24),
            ...reminder.medicines.map((medicine) {
              final dose = todayDoses.firstWhere(
                (d) => d.medicineId == medicine.id && d.scheduledTime == reminder.time,
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
                            ? const Color(0xFF66BB6A).withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isTaken ? Icons.check : Icons.medication,
                        color: isTaken ? const Color(0xFF66BB6A) : Colors.grey,
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${medicine.dose} ${medicine.unit}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (isTaken && dose.takenAt != null)
                            Text(
                              'Taken at ${AppDateUtils.formatTime(dose.takenAt!)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF66BB6A),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!isTaken)
                      ElevatedButton(
                        onPressed: () {
                          ref.read(todayDosesProvider.notifier).takeDose(
                                medicine.id,
                                reminder.id,
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Take'),
                      ),
                    if (isTaken && isInLockout)
                      Text(
                        'Wait ${_getRemainingLockoutTime(dose.takenAt!, ref)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    if (isTaken && !isInLockout)
                      TextButton(
                        onPressed: () {
                          ref.read(todayDosesProvider.notifier).undoDose(
                                medicine.id,
                                reminder.time,
                              );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Undo'),
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
    final lockoutHours = ref.read(lockoutHoursProvider);
    final lockoutEnd = takenAt.add(Duration(hours: lockoutHours));
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
