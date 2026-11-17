import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/application.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'rating_dialog.dart';

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return AppColors.primary;
      case ApplicationStatus.hired:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
    }
  }

  String _statusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.hired:
        return 'Hired';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Construction':
        return Icons.construction;
      case 'Delivery':
      case 'Logistics':
        return Icons.local_shipping;
      case 'Tutoring':
        return Icons.school;
      case 'Household':
      case 'Cleaning':
        return Icons.cleaning_services;
      case 'Farming':
        return Icons.agriculture;
      case 'Food Service':
        return Icons.restaurant;
      case 'Retail':
        return Icons.storefront;
      case 'Repair':
        return Icons.build;
      default:
        return Icons.work;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _confirmCancel(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel application?'),
        content: const Text('This will remove your application.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Yes')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AppProvider>().cancelApplication(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final user = app.currentUser;
    final apps = user == null ? <Application>[] : app.applicationsForSeeker(user.id);
    final seekerId = user?.id ?? '';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Applications', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text)),
            const SizedBox(height: 16),
            Expanded(
              child: apps.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.assignment_outlined, size: 48, color: AppColors.textSecondary),
                          SizedBox(height: 8),
                          Text('No applications yet', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: apps.length,
                      itemBuilder: (context, i) {
                        final a = apps[i];
                        final job = app.jobs.firstWhere((j) => j.id == a.jobId, orElse: () => app.jobs.first);
                        final employer = app.employerFor(job);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: AppColors.primary,
                                      child: Icon(_iconForCategory(job.category), color: AppColors.text),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            job.title,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            employer?.businessName ?? employer?.name ?? 'Employer',
                                            style: const TextStyle(color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _statusColor(a.status),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        _statusLabel(a.status),
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Applied ${_formatDate(a.appliedAt)}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ),
                                    if (a.status == ApplicationStatus.pending) ...[
                                      const SizedBox(width: 12),
                                      OutlinedButton(
                                        onPressed: () => _confirmCancel(context, a.id),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(color: Colors.red),
                                          minimumSize: const Size(0, 40),
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          shape: const StadiumBorder(),
                                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  ],
                                ),
                                if (a.status == ApplicationStatus.hired && employer != null) ...[
                                  const SizedBox(height: AppSpacing.md),
                                  if (app.hasReviewed(seekerId, employer.id, a.jobId))
                                    Container(
                                      height: 48,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppColors.inputFill,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: const Text(
                                        'Rated ✓',
                                        style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                      ),
                                    )
                                  else
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () => showRatingDialog(context, toUser: employer, jobId: a.jobId),
                                        child: const Text('Rate Employer'),
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ),
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
