import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../models/application.dart';
import '../models/job.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/delete_job_dialog.dart';
import '../widgets/job_status_chip.dart';
import '../widgets/star_rating.dart';
import 'rating_dialog.dart';
import 'talent_detail_screen.dart';

class ApplicantsScreen extends StatelessWidget {
  final String jobId;

  const ApplicantsScreen({super.key, required this.jobId});

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

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

  Future<void> _updateStatus(BuildContext context, String appId, ApplicationStatus status) async {
    await context.read<AppProvider>().updateApplicationStatus(appId, status);
    if (!context.mounted) return;
    final msg = status == ApplicationStatus.hired ? 'Applicant hired' : 'Applicant rejected';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Job job,
    List<Application> applicants,
  ) async {
    final hasHired = applicants.any((a) => a.status == ApplicationStatus.hired);
    final confirmed = await showDeleteJobDialog(
      context,
      applicantCount: applicants.length,
      hasHired: hasHired,
    );
    if (!confirmed || !context.mounted) return;

    final app = context.read<AppProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    await app.deleteJob(job.id);
    if (!context.mounted) return;
    navigator.pop();
    messenger.showSnackBar(const SnackBar(content: Text('Job deleted')));
  }

  Future<void> _rateApplicant(BuildContext context, AppUser seeker) async {
    final app = context.read<AppProvider>();
    final reviewer = app.currentUser;
    if (reviewer == null) return;

    final result = await showRatingSheet(context, toUser: seeker, jobId: jobId);
    if (result == null || !context.mounted) return;

    await app.addReview(
      fromUserId: reviewer.id,
      toUserId: seeker.id,
      jobId: jobId,
      stars: result.stars,
      comment: result.comment,
    );

    if (!context.mounted) return;
    await showReviewThanksDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final job = app.jobById(jobId);
    final applicants = app.applicantsForJob(jobId);
    final reviewerId = app.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(job?.title ?? 'Deleted job'),
        actions: [
          if (job != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                tooltip: 'Delete job',
                onPressed: () => _confirmDelete(context, job, applicants),
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (job != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JobStatusChip(
                    job: job,
                    hiredCount: app.hiredCount(job.id),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  JobFullToggleButton(job: job),
                ],
              ),
            ),
          Expanded(
            child: applicants.isEmpty
                ? const Center(child: Text('No applicants yet', style: TextStyle(color: AppColors.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: applicants.length,
                    itemBuilder: (itemContext, i) {
                final a = applicants[i];
                final seeker = app.userById(a.seekerId);
                if (seeker == null) return const SizedBox.shrink();
                final avg = app.averageRating(seeker.id);
                final count = app.reviewCount(seeker.id);
                final rated = app.hasReviewed(reviewerId, seeker.id, jobId);
                final skills = seeker.skills.take(3).toList();
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(itemContext).push(
                        MaterialPageRoute(builder: (_) => TalentDetailScreen(seekerId: seeker.id)),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  _initials(seeker.name),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(seeker.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    StarRating(rating: avg, count: count),
                                  ],
                                ),
                              ),
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
                          if (skills.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: skills
                                  .map((s) => Chip(
                                        label: Text(s, style: const TextStyle(fontSize: 12)),
                                        backgroundColor: AppColors.cream,
                                        side: BorderSide.none,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                      ))
                                  .toList(),
                            ),
                          ],
                          if (a.status == ApplicationStatus.pending) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _updateStatus(context, a.id, ApplicationStatus.hired),
                                    child: const Text('Hire'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _updateStatus(context, a.id, ApplicationStatus.rejected),
                                    child: const Text('Reject'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (a.status == ApplicationStatus.hired) ...[
                            const SizedBox(height: AppSpacing.md),
                            if (rated)
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
                                  onPressed: () => _rateApplicant(context, seeker),
                                  child: const Text('Rate Worker'),
                                ),
                              ),
                          ],
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
    );
  }
}
