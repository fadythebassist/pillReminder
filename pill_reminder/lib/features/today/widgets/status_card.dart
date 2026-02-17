import 'package:flutter/material.dart';
import '../../../core/date_utils.dart';

class StatusCard extends StatelessWidget {
  final bool isTaken;
  final DateTime? takenAt;

  const StatusCard({
    super.key,
    required this.isTaken,
    this.takenAt,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cardColor = isTaken ? scheme.tertiary : scheme.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isTaken ? Icons.check_circle : Icons.cancel,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            isTaken ? 'TAKEN' : 'NOT TAKEN',
            style: textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          if (isTaken && takenAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'at ${AppDateUtils.formatTime(takenAt!)}',
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
