import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
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
    final items = <_AlertItem>[];

    if (user != null && user.role == UserRole.employer) {
      for (final review in app.reviewsFor(user.id)) {
        final reviewer = app.userById(review.fromUserId);
        items.add(_AlertItem(
          title: '${reviewer?.name ?? 'Someone'} rated you ${review.stars} stars for ${app.jobTitle(review.jobId)}',
          date: review.createdAt,
          jobId: review.jobId,
        ));
      }
    } else if (user != null) {
      final apps = app.applicationsForSeeker(user.id);
      final invites = app.invitesForSeeker(user.id);
      for (final a in apps) {
        final job = app.jobById(a.jobId);
        if (job == null) continue;
        items.add(_AlertItem(
          title: _messageFor(a.status, job.title),
          date: a.appliedAt,
          jobId: job.id,
        ));
      }
      for (final inv in invites) {
        final job = app.jobById(inv.jobId);
        if (job == null) continue;
        final employer = app.userById(inv.employerId);
        final name = employer?.businessName?.isNotEmpty == true ? employer!.businessName! : (employer?.name ?? 'An employer');
        items.add(_AlertItem(
          title: '$name invited you to apply for ${job.title}',
          date: inv.createdAt,
          jobId: job.id,
        ));
      }
      for (final review in app.reviewsFor(user.id)) {
        final reviewer = app.userById(review.fromUserId);
        items.add(_AlertItem(
          title: '${reviewer?.name ?? 'Someone'} rated you ${review.stars} stars for ${app.jobTitle(review.jobId)}',
          date: review.createdAt,
          jobId: review.jobId,
        ));
      }
    }

    items.sort((a, b) => b.date.compareTo(a.date));

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
                        final matches = app.jobs.where((j) => j.id == item.jobId).toList();
                        return ListTile(
                          tileColor: AppColors.cream,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.notifications, color: AppColors.text),
                          ),
                          title: Text(item.title),
                          onTap: matches.isEmpty
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => JobDetailScreen(job: matches.first)),
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
