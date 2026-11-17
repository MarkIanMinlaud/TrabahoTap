import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/job.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class JobStatusChip extends StatelessWidget {
  final Job job;
  final int hiredCount;

  const JobStatusChip({super.key, required this.job, required this.hiredCount});

  @override
  Widget build(BuildContext context) {
    final full = job.isFull;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: full ? AppColors.inputFill : AppColors.successSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        full ? 'Full' : 'Open · $hiredCount of ${job.vacancies} filled',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: full ? AppColors.textSecondary : AppColors.success,
        ),
      ),
    );
  }
}

class JobFullToggleButton extends StatelessWidget {
  final Job job;

  const JobFullToggleButton({super.key, required this.job});

  Future<void> _toggle(BuildContext context) async {
    final app = context.read<AppProvider>();
    final wasFull = job.isFull;
    final updated = await app.setJobFull(job.id, !wasFull);
    if (!context.mounted) return;
    if (!updated) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(wasFull ? 'Job reopened' : 'Job marked as full')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.minTouchTarget,
      child: OutlinedButton(
        onPressed: () => _toggle(context),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: Text(job.isFull ? 'Reopen' : 'Mark as Full'),
      ),
    );
  }
}
