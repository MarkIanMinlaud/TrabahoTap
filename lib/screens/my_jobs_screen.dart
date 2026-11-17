import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/application.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/delete_job_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/job_status_chip.dart';
import 'applicants_screen.dart';

class MyJobsScreen extends StatelessWidget {
  final VoidCallback? onPostJob;

  const MyJobsScreen({super.key, this.onPostJob});

  Future<void> _confirmDelete(
    BuildContext context,
    String jobId,
    List<Application> applicants,
  ) async {
    final hasHired = applicants.any((a) => a.status == ApplicationStatus.hired);
    final confirmed = await showDeleteJobDialog(
      context,
      applicantCount: applicants.length,
      hasHired: hasHired,
    );
    if (!confirmed || !context.mounted) return;

    await context.read<AppProvider>().deleteJob(jobId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Job deleted')));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final user = app.currentUser;
    final jobs = user == null ? [] : app.jobsForEmployer(user.id);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Jobs', style: AppTextStyles.pageTitle),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: jobs.isEmpty
                  ? EmptyState(
                      icon: Icons.work_outline,
                      message: 'No jobs posted yet',
                      subtitle: 'Post your first job to start hiring.',
                      action: SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: onPostJob,
                          child: const Text('Post a Job'),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: jobs.length,
                      itemBuilder: (itemContext, i) {
                        final job = jobs[i];
                        final applicants = app.applicantsForJob(job.id);
                        final count = applicants.length;
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radius,
                            ),
                            onTap: () {
                              Navigator.of(itemContext).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ApplicantsScreen(jobId: job.id),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.cardTitle,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    job.pay,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.hint,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Wrap(
                                    spacing: AppSpacing.sm,
                                    runSpacing: AppSpacing.sm,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      JobStatusChip(
                                        job: job,
                                        hiredCount: app.hiredCount(job.id),
                                      ),
                                      Chip(
                                        label: Text('$count applicants'),
                                        backgroundColor: AppColors.primary,
                                        side: BorderSide.none,
                                        labelStyle: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: JobFullToggleButton(job: job),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      SizedBox(
                                        width: AppSpacing.minTouchTarget,
                                        height: AppSpacing.minTouchTarget,
                                        child: IconButton(
                                          tooltip: 'Delete job',
                                          onPressed: () => _confirmDelete(
                                            context,
                                            job.id,
                                            applicants,
                                          ),
                                          style: IconButton.styleFrom(
                                            backgroundColor: AppColors.danger
                                                .withValues(alpha: 0.12),
                                          ),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: AppColors.danger,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
