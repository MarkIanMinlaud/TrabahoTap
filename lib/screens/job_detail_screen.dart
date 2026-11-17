import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/job.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/star_rating.dart';

class JobDetailScreen extends StatelessWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  Future<void> _apply(BuildContext context) async {
    final app = context.read<AppProvider>();
    final seekerId = app.currentUser!.id;
    final applied = await app.applyToJob(seekerId, job.id);
    if (!context.mounted) return;
    if (!applied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This employer is no longer accepting applicants'),
        ),
      );
      return;
    }
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
              const Text('Application Sent!', style: AppTextStyles.dialogTitle),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Your application has been submitted.',
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

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final currentJob = app.jobById(job.id) ?? job;
    final employer = app.employerFor(job);
    final seekerId = app.currentUser?.id ?? '';
    final applied = app.hasApplied(seekerId, job.id);
    final avg = employer != null ? app.averageRating(employer.id) : 0.0;
    final count = employer != null ? app.reviewCount(employer.id) : 0;

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
                  Text(job.title, style: AppTextStyles.authTitle),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    job.pay,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Chip(
                    label: Text(job.category),
                    backgroundColor: AppColors.cream,
                    side: BorderSide.none,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text('Description', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: AppSpacing.sm),
                  Text(job.description, style: AppTextStyles.hint),
                  const SizedBox(height: AppSpacing.xl),
                  const Text('Employer', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: AppSpacing.sm),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.business, color: AppColors.text),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  employer?.businessName ??
                                      employer?.name ??
                                      'Employer',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  employer?.location ?? 'Davao City',
                                  style: AppTextStyles.hint,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                StarRating(
                                  rating: avg,
                                  count: count,
                                  countSuffix: ' reviews',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: applied
                  ? ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: AppColors.disabled,
                        disabledForegroundColor: AppColors.textSecondary,
                      ),
                      child: const Text('Applied'),
                    )
                  : currentJob.isFull
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'This employer is no longer accepting applicants',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.hint,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            disabledBackgroundColor: AppColors.disabled,
                            disabledForegroundColor: AppColors.textSecondary,
                          ),
                          child: const Text('Position Filled'),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () => _apply(context),
                      child: const Text('Apply Now'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
