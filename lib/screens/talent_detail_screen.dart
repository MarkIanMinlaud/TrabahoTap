import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../models/job.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

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

    if (myJobs.isEmpty) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) => const Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Post a job first',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
      return;
    }

    final selected = await showModalBottomSheet<Job>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select a job', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...myJobs.map((job) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(job.title),
                    subtitle: Text(job.pay),
                    onTap: () => Navigator.of(ctx).pop(job),
                  )),
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
                const Text('Invite Sent!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'The worker has been invited to apply.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
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
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('User not found')));
    }
    final avg = app.averageRatingFor(seeker.id);
    final count = app.reviewCountFor(seeker.id);
    final reviews = app.reviewsForUser(seeker.id);
    final isEmployer = app.currentUser?.role == UserRole.employer;

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
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            _initials(seeker.name),
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.text),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(seeker.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: AppColors.primary, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              count == 0 ? 'No ratings yet' : '${avg.toStringAsFixed(1)} ($count reviews)',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Bio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    seeker.bio.isEmpty ? 'No bio yet' : seeker.bio,
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  const Text('Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (seeker.skills.isEmpty)
                    const Text('No skills listed', style: TextStyle(color: AppColors.textSecondary))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: seeker.skills
                          .map((s) => Chip(
                                label: Text(s),
                                backgroundColor: AppColors.cream,
                                side: BorderSide.none,
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                  const Text('Resume', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.description, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          seeker.resumeFileName ?? 'No resume uploaded',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (reviews.isEmpty)
                    const Text('No reviews yet', style: TextStyle(color: AppColors.textSecondary))
                  else
                    ...reviews.map((r) {
                      final from = app.userById(r.fromUserId);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(from?.name ?? 'User', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const Spacer(),
                                  ...List.generate(
                                    5,
                                    (i) => Icon(
                                      i < r.stars ? Icons.star : Icons.star_border,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                              if (r.comment.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(r.comment, style: const TextStyle(color: AppColors.textSecondary)),
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
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
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
