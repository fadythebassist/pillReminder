import 'package:flutter/material.dart';
import '../../../core/date_utils.dart';

class HistoryRow extends StatelessWidget {
  final DateTime date;
  final bool isTaken;
  final DateTime? takenAt;
  final String? medicineName;

  const HistoryRow({
    super.key,
    required this.date,
    required this.isTaken,
    this.takenAt,
    this.medicineName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTaken
                  ? const Color(0xFF66BB6A).withValues(alpha: 0.1)
                  : const Color(0xFFEF5350).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTaken ? Icons.check : Icons.close,
              color: isTaken ? const Color(0xFF66BB6A) : const Color(0xFFEF5350),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicineName != null 
                      ? '${AppDateUtils.getShortDate(date)} - $medicineName'
                      : AppDateUtils.getShortDate(date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isTaken
                      ? 'Taken ${takenAt != null ? AppDateUtils.formatTime(takenAt!) : ''}'
                      : 'Missed',
                  style: TextStyle(
                    fontSize: 14,
                    color: isTaken ? const Color(0xFF66BB6A) : const Color(0xFFEF5350),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
