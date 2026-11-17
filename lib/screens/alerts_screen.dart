import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/application.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  String _messageFor(ApplicationStatus status, String jobTitle) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Your application for $jobTitle is pending';
      case ApplicationStatus.hired:
        return 'You were hired for $jobTitle!';
      case ApplicationStatus.rejected:
        return 'Your application for $jobTitle was not selected';
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final user = app.currentUser;
    final apps = user == null ? <Application>[] : app.applicationsForSeeker(user.id);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alerts', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text)),
            const SizedBox(height: 16),
            Expanded(
              child: apps.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_none, size: 48, color: AppColors.textSecondary),
                          SizedBox(height: 8),
                          Text('No alerts yet', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: apps.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final a = apps[i];
                        final job = app.jobs.firstWhere((j) => j.id == a.jobId, orElse: () => app.jobs.first);
                        return ListTile(
                          tileColor: AppColors.cream,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.notifications, color: AppColors.text),
                          ),
                          title: Text(_messageFor(a.status, job.title)),
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
