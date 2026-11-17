import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'applicants_screen.dart';

class MyJobsScreen extends StatelessWidget {
  final VoidCallback? onPostJob;

  const MyJobsScreen({super.key, this.onPostJob});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final user = app.currentUser;
    final jobs = user == null ? [] : app.jobsForEmployer(user.id);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Jobs',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: jobs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.work_outline, size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 8),
                          const Text('No jobs posted yet', style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 16),
                            SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                onPressed: onPostJob,
                                child: const Text('Post a Job'),
                              ),
                            ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: jobs.length,
                      itemBuilder: (context, i) {
                        final job = jobs[i];
                        final count = app.applicantsForJob(job.id).length;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => ApplicantsScreen(jobId: job.id)),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(job.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(job.pay, style: const TextStyle(color: AppColors.textSecondary)),
                                  const SizedBox(height: 8),
                                  Chip(
                                    label: Text('$count applicants'),
                                    backgroundColor: AppColors.primary,
                                    side: BorderSide.none,
                                    labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.text),
                                  ),
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
      ),
    );
  }
}
