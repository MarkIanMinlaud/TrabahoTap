import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/application.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'job_detail_screen.dart';

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
    final invites = user == null ? [] : app.invitesForSeeker(user.id);

    final items = <_AlertItem>[
      ...apps.map((a) {
        final job = app.jobs.firstWhere((j) => j.id == a.jobId, orElse: () => app.jobs.first);
        return _AlertItem(
          title: _messageFor(a.status, job.title),
          date: a.appliedAt,
          jobId: job.id,
        );
      }),
      ...invites.map((inv) {
        final job = app.jobs.firstWhere((j) => j.id == inv.jobId, orElse: () => app.jobs.first);
        final employer = app.userById(inv.employerId);
        final name = employer?.businessName?.isNotEmpty == true ? employer!.businessName! : (employer?.name ?? 'An employer');
        return _AlertItem(
          title: '$name invited you to apply for ${job.title}',
          date: inv.createdAt,
          jobId: job.id,
        );
      }),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alerts', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text)),
            const SizedBox(height: 16),
            Expanded(
              child: items.isEmpty
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
                      itemCount: items.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        final job = app.jobs.firstWhere((j) => j.id == item.jobId, orElse: () => app.jobs.first);
                        return ListTile(
                          tileColor: AppColors.cream,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.notifications, color: AppColors.text),
                          ),
                          title: Text(item.title),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                            );
                          },
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

class _AlertItem {
  final String title;
  final DateTime date;
  final String jobId;

  _AlertItem({required this.title, required this.date, required this.jobId});
}
