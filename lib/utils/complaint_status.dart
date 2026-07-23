import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ComplaintStatus {
  static const List<String> options = [
    'Pending',
    'Under Review',
    'In Progress',
    'Resolved',
    'Rejected',
  ];

  static String normalize(String? rawStatus) {
    final status = (rawStatus ?? '').trim();
    if (status.isEmpty || status == 'Submitted') return 'Pending';
    return status;
  }

  static Color foreground(String? rawStatus) {
    switch (normalize(rawStatus)) {
      case 'Resolved':
        return AppTheme.statusResolved;
      case 'In Progress':
        return AppTheme.statusInProgress;
      case 'Rejected':
        return AppTheme.statusRejected;
      case 'Under Review':
        return AppTheme.accent;
      case 'Pending':
      default:
        return AppTheme.statusPending;
    }
  }

  static Color background(String? rawStatus) {
    return foreground(rawStatus).withAlpha(30);
  }

  static IconData icon(String? rawStatus) {
    switch (normalize(rawStatus)) {
      case 'Resolved':
        return Icons.check_circle_rounded;
      case 'In Progress':
        return Icons.pending_rounded;
      case 'Under Review':
        return Icons.manage_search_rounded;
      case 'Rejected':
        return Icons.cancel_rounded;
      case 'Pending':
      default:
        return Icons.hourglass_empty_rounded;
    }
  }
}
