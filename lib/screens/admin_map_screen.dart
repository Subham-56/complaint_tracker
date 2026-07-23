import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/complaint_map_content.dart';

class AdminMapScreen extends StatelessWidget {
  const AdminMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'City-Wide Map',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'All reported complaints across the city',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ComplaintMapContent(
              loadComplaints: ApiService.getAllComplaintsMap,
              emptyTitle: 'No reports across the city',
              emptyMessage:
                  'Complaint locations will appear here for admin review.',
              emptyIcon: Icons.public_outlined,
              errorMessage: 'The city map could not be loaded right now.',
            ),
          ),
        ],
      ),
    );
  }
}
