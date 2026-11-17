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
    await app.applyToJob(seekerId, job.id);
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.check, color: AppColors.text, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Application Sent!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Your application has been submitted.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.text)),
                  const SizedBox(height: 8),
                  Text(job.pay, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text)),
                  const SizedBox(height: 12),
                  Chip(
                    label: Text(job.category),
                    backgroundColor: AppColors.cream,
                    side: BorderSide.none,
                  ),
                  const SizedBox(height: 16),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(job.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
                  const SizedBox(height: 24),
                  const Text('Employer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.business, color: AppColors.text),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(employer?.businessName ?? employer?.name ?? 'Employer',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(employer?.location ?? 'Davao City',
                                    style: const TextStyle(color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                StarRating(rating: avg, count: count, countSuffix: ' reviews'),
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
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: applied
                  ? ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300),
                      child: const Text('Applied'),
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
