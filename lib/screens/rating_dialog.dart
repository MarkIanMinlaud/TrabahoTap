import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/star_input.dart';

Future<void> showRatingDialog(
  BuildContext context, {
  required AppUser toUser,
  required String jobId,
}) async {
  final app = context.read<AppProvider>();
  final reviewer = app.currentUser;
  if (reviewer == null) return;
  if (app.hasReviewed(reviewer.id, toUser.id, jobId)) return;

  var stars = 0;
  var submitted = false;
  var comment = '';
  final commentController = TextEditingController();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radius),
      ),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl + MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Rate ${toUser.name}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: StarInput(
                  value: stars,
                  onChanged: (value) => setSheetState(() => stars = value),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: commentController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Share your experience',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () {
                  if (stars == 0) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Please choose a star rating'),
                      ),
                    );
                    return;
                  }
                  submitted = true;
                  comment = commentController.text.trim();
                  Navigator.of(ctx).pop();
                },
                child: const Text('Submit Review'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  commentController.dispose();
  if (!submitted) return;

  await app.addReview(
    fromUserId: reviewer.id,
    toUserId: toUser.id,
    jobId: jobId,
    stars: stars,
    comment: comment,
  );

  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
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
              child: Icon(Icons.star, color: AppColors.text, size: 32),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Thank you for your review!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
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
