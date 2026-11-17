import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/star_input.dart';

class RatingResult {
  final int stars;
  final String comment;

  const RatingResult({required this.stars, required this.comment});
}

/// Opens the rating sheet and returns the chosen rating, or null if cancelled.
/// The caller is responsible for saving the review and showing the dialog.
Future<RatingResult?> showRatingSheet(
  BuildContext context, {
  required AppUser toUser,
  required String jobId,
}) async {
  final app = context.read<AppProvider>();
  final reviewer = app.currentUser;
  if (reviewer == null) return null;
  if (app.hasReviewed(reviewer.id, toUser.id, jobId)) return null;

  return showModalBottomSheet<RatingResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radius),
      ),
    ),
    builder: (_) => RatingSheet(name: toUser.name),
  );
}

class RatingSheet extends StatefulWidget {
  final String name;

  const RatingSheet({super.key, required this.name});

  @override
  State<RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<RatingSheet> {
  final TextEditingController _commentController = TextEditingController();
  int _stars = 0;
  bool _submitted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_submitted) return;
    if (_stars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a star rating')),
      );
      return;
    }
    _submitted = true;
    Navigator.of(context).pop(
      RatingResult(
        stars: _stars,
        comment: _commentController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Rate ${widget.name}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: StarInput(
                value: _stars,
                onChanged: (value) => setState(() => _stars = value),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _commentController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Share your experience',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showReviewThanksDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) => Dialog(
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
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    ),
  );
}
