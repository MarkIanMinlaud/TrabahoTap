import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../models/job.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/star_rating.dart';

class TalentDetailScreen extends StatelessWidget {
  final String seekerId;

  const TalentDetailScreen({super.key, required this.seekerId});

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Future<void> _invite(BuildContext context, AppUser seeker) async {
    final app = context.read<AppProvider>();
    final employer = app.currentUser;
    if (employer == null) return;
    final myJobs = app.jobsForEmployer(employer.id);
    final openJobs = myJobs.where((job) => !job.isFull).toList();

    if (openJobs.isEmpty) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radius),
          ),
        ),
        builder: (ctx) => const SafeArea(
          top: false,
          child: EmptyState(
            icon: Icons.work_outline,
            message: 'No open jobs',
            subtitle: 'Post a job first so you can invite workers.',
            compact: true,
          ),
        ),
      );
      return;
    }

    final selected = await showModalBottomSheet<Job>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radius),
        ),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select a job', style: AppTextStyles.sectionTitle),
              const SizedBox(height: AppSpacing.md),
              ...openJobs.map(
                (job) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    job.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(job.pay),
                  onTap: () => Navigator.of(ctx).pop(job),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selected != null && context.mounted) {
      await app.sendInvite(
        jobId: selected.id,
        employerId: employer.id,
        seekerId: seeker.id,
      );
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierColor: AppColors.overlay,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.check, color: AppColors.text, size: 32),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Invite Sent!', style: AppTextStyles.dialogTitle),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'The worker has been invited to apply.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.hint,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final seeker = app.userById(seekerId);
    if (seeker == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('User not found')),
      );
    }
    final avg = app.averageRating(seeker.id);
    final count = app.reviewCount(seeker.id);
    final reviews = app.reviewsFor(seeker.id);
    final isEmployer = app.currentUser?.role == UserRole.employer;

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            _initials(seeker.name),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          seeker.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.pageTitle,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        StarRating(
                          rating: avg,
                          count: count,
                          size: 18,
                          countSuffix: ' reviews',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Text('Bio', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    seeker.bio.isEmpty ? 'No bio yet' : seeker.bio,
                    style: AppTextStyles.hint,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text('Skills', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: AppSpacing.sm),
                  if (seeker.skills.isEmpty)
                    const Text('No skills listed', style: AppTextStyles.hint)
                  else
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: seeker.skills
                          .map(
                            (s) => Chip(
                              label: Text(s),
                              backgroundColor: AppColors.cream,
                              side: BorderSide.none,
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text('Resume', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.description, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          seeker.resumeFileName ?? 'No resume uploaded',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.hint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text('Reviews', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: AppSpacing.sm),
                  if (reviews.isEmpty)
                    const EmptyState(
                      icon: Icons.star_border,
                      message: 'No reviews yet',
                      subtitle: 'Reviews appear after a worker is hired.',
                      compact: true,
                    )
                  else
                    ...reviews.map((r) {
                      final from = app.userById(r.fromUserId);
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      from?.name ?? 'User',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  StarRating(
                                    rating: r.stars.toDouble(),
                                    showValue: false,
                                    showCount: false,
                                  ),
                                ],
                              ),
                              if (r.comment.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(r.comment, style: AppTextStyles.hint),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          if (isEmployer)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: ElevatedButton(
                  onPressed: () => _invite(context, seeker),
                  child: const Text('Invite to Apply'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
