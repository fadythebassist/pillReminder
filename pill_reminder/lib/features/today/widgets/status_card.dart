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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isTaken ? const Color(0xFF66BB6A) : const Color(0xFFEF5350),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isTaken ? const Color(0xFF66BB6A) : const Color(0xFFEF5350))
                .withValues(alpha: 0.3),
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
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          if (isTaken && takenAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'at ${AppDateUtils.formatTime(takenAt!)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
