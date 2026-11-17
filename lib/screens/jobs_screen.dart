import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/job.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
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
    final text = '${job.title} ${job.category} ${employer?.businessName ?? ''} ${employer?.name ?? ''}'.toLowerCase();
    final matchesQuery = q.isEmpty || text.contains(q);
    final matchesCategory = _selectedCategory == 'All' || job.category == _selectedCategory ||
        (_selectedCategory == 'Delivery' && job.category == 'Logistics') ||
        (_selectedCategory == 'Household' && job.category == 'Cleaning');
    return matchesQuery && matchesCategory;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final user = app.currentUser;
    final jobs = app.jobs.where((j) => _matches(j, app)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hi, ${user?.name ?? ''}', style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            const Text('Find your next job', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text)),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search job, category, or employer',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, index) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final c = _categories[i];
                  final selected = c == _selectedCategory;
                  return ChoiceChip(
                    label: Text(c),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = c),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.inputFill,
                    labelStyle: TextStyle(color: AppColors.text, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: jobs.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
                          SizedBox(height: 8),
                          Text('No jobs found', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: jobs.length,
                      itemBuilder: (context, i) {
                        final job = jobs[i];
                        return JobCard(
                          job: job,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
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
