import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/job.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const JobCard({super.key, required this.job, required this.onTap});

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

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final employer = app.employerFor(job);
    final avg = employer != null ? app.averageRatingFor(employer.id) : 0.0;
    final count = employer != null ? app.reviewCountFor(employer.id) : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
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
                    Text(job.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
                    const SizedBox(height: 4),
                    Text(employer?.businessName ?? employer?.name ?? 'Employer', style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(job.pay, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.primary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          count == 0 ? 'No ratings yet' : '${avg.toStringAsFixed(1)} ($count)',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
