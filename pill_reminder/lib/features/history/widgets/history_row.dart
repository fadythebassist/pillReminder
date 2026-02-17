import 'package:flutter/material.dart';
import '../../../core/date_utils.dart';

class HistoryRow extends StatelessWidget {
  final DateTime date;
  final String? scheduledTime;
  final bool isTaken;
  final DateTime? takenAt;
  final String? medicineName;
  final VoidCallback? onUndo;

  const HistoryRow({
    super.key,
    required this.date,
    this.scheduledTime,
    required this.isTaken,
    this.takenAt,
    this.medicineName,
    this.onUndo,
  });

  String? _formatScheduledTime(BuildContext context) {
    final value = scheduledTime;
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length != 2) return value;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return value;

    final time = TimeOfDay(hour: hour, minute: minute);
    return MaterialLocalizations.of(context).formatTimeOfDay(
      time,
      alwaysUse24HourFormat: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final displayScheduledTime = _formatScheduledTime(context);

    final titleParts = <String>[
      AppDateUtils.getShortDate(date),
      if (displayScheduledTime != null) displayScheduledTime,
      if (medicineName != null && medicineName!.isNotEmpty) medicineName!,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: scheme.primary.withValues(alpha: 0.12),
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
                  ? scheme.tertiary.withValues(alpha: 0.14)
                  : scheme.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTaken ? Icons.check : Icons.close,
              color: isTaken ? scheme.tertiary : scheme.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleParts.join(' - '),
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  isTaken
                      ? 'Taken ${takenAt != null ? AppDateUtils.formatTime(takenAt!) : ''}'
                      : 'Missed',
                  style: textTheme.bodySmall?.copyWith(
                    color: isTaken ? scheme.tertiary : scheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (isTaken && onUndo != null)
            TextButton(
              onPressed: onUndo,
              style: TextButton.styleFrom(
                foregroundColor: scheme.error,
              ),
              child: const Text('Undo'),
            ),
        ],
      ),
    );
  }
}
