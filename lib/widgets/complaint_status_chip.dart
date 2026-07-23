import 'package:flutter/material.dart';
import '../utils/complaint_status.dart';

class ComplaintStatusChip extends StatelessWidget {
  const ComplaintStatusChip({super.key, required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final normalized = ComplaintStatus.normalize(status);
    final color = ComplaintStatus.foreground(normalized);
    final bg = ComplaintStatus.background(normalized);
    final icon = ComplaintStatus.icon(normalized);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            normalized,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
