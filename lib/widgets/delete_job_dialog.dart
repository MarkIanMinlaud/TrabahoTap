import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

// Shows the delete confirmation. Returns true only when Delete is tapped.
Future<bool> showDeleteJobDialog(
  BuildContext context, {
  required int applicantCount,
  required bool hasHired,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) {
      final applications = applicantCount == 1 ? 'application' : 'applications';
      final message = StringBuffer(
        'This will also remove $applicantCount $applications. ',
      );
      if (hasHired) {
        message.write('This job has a hired worker. ');
      }
      message.write('This cannot be undone.');

      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
        title: Column(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.danger,
              child: Icon(Icons.delete_outline, color: Colors.white, size: 32),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Delete this job?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          message.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.neutral),
              minimumSize: const Size(0, 48),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
            ),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
