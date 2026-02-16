import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/date_utils.dart';
import '../../providers/app_providers.dart';
import '../../widgets/ad_banner_placeholder.dart';
import 'widgets/history_row.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adherence = ref.watch(adherenceProvider);
    final last30Days = AppDateUtils.getLast30Days();
    final doses = ref.watch(historyDosesProvider);
    final reminders = ref.watch(remindersProvider);
    
    final medicineMap = <String, String>{};
    for (var reminder in reminders) {
      for (var medicine in reminder.medicines) {
        medicineMap[medicine.id] = medicine.name;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1976D2),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Adherence Rate',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$adherence / ${AppConstants.historyDays}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${((adherence / AppConstants.historyDays) * 100).round()}%',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const AdBannerPlaceholder(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: last30Days.length,
                itemBuilder: (context, index) {
                  final date = last30Days[index];
                  final dateKey = AppDateUtils.getDateKey(date);
                  
                  final dayDoses = doses.where((d) => d.date == dateKey).toList();
                  
                  if (dayDoses.isEmpty) {
                    return HistoryRow(
                      date: date,
                      isTaken: false,
                      takenAt: null,
                      medicineName: null,
                    );
                  }
                  
                  return Column(
                    children: dayDoses.map((dose) {
                      return HistoryRow(
                        date: date,
                        isTaken: dose.isTaken,
                        takenAt: dose.takenAt,
                        medicineName: medicineMap[dose.medicineId],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
