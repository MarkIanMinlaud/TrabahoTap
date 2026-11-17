import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/job.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/job_card.dart';
import 'job_detail_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    'Construction',
    'Delivery',
    'Tutoring',
    'Household',
    'Farming',
    'Food Service',
    'Retail',
    'Repair',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(Job job, AppProvider app) {
    final employer = app.employerFor(job);
    final q = _query.toLowerCase();
    final text =
        '${job.title} ${job.category} ${employer?.businessName ?? ''} ${employer?.name ?? ''}'
            .toLowerCase();
    final matchesQuery = q.isEmpty || text.contains(q);
    final matchesCategory =
        _selectedCategory == 'All' ||
        job.category == _selectedCategory ||
        (_selectedCategory == 'Delivery' && job.category == 'Logistics') ||
        (_selectedCategory == 'Household' && job.category == 'Cleaning');
    return matchesQuery && matchesCategory;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final user = app.currentUser;
    final jobs = app.jobs.where((j) => _matches(j, app)).toList()
      ..sort((a, b) {
        // Keep full jobs at the bottom of the list.
        if (a.isFull != b.isFull) return a.isFull ? 1 : -1;
        return b.createdAt.compareTo(a.createdAt);
      });

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${user?.name ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.hint,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text('Find your next job', style: AppTextStyles.pageTitle),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search job, category, or employer',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: AppSpacing.minTouchTarget,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, index) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, i) {
                  final c = _categories[i];
                  final selected = c == _selectedCategory;
                  return ChoiceChip(
                    label: Text(c),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = c),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.inputFill,
                    labelStyle: TextStyle(
                      color: AppColors.text,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: jobs.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off,
                      message: 'No jobs found',
                      subtitle: 'Try a different search or category.',
                    )
                  : ListView.builder(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: jobs.length,
                      itemBuilder: (context, i) {
                        final job = jobs[i];
                        return JobCard(
                          job: job,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => JobDetailScreen(job: job),
                              ),
                            );
                          },
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
