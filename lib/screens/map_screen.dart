import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/complaint_map_content.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Complaints Map',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'View your reported issues on the map',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ComplaintMapContent(
              loadComplaints: ApiService.getComplaints,
              emptyTitle: 'No complaints on the map yet',
              emptyMessage:
                  'Once you file a complaint, its location will appear here.',
              errorMessage: 'Your complaint map could not be loaded right now.',
            ),
          ),
        ],
      ),
    );
  }
}
