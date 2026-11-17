import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/talent_card.dart';
import 'talent_detail_screen.dart';

class TalentScreen extends StatefulWidget {
  const TalentScreen({super.key});

  @override
  State<TalentScreen> createState() => _TalentScreenState();
}

class _TalentScreenState extends State<TalentScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final talent = app.talentList(query: _query);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Find trusted workers', style: AppTextStyles.pageTitle),
            const SizedBox(height: AppSpacing.md),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name or skill',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: talent.isEmpty
                  ? const EmptyState(
                      icon: Icons.people_outline,
                      message: 'No workers found',
                      subtitle: 'Try another name or skill.',
                    )
                  : ListView.builder(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: talent.length,
                      itemBuilder: (context, i) {
                        final seeker = talent[i];
                        return TalentCard(
                          seeker: seeker,
                          app: app,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    TalentDetailScreen(seekerId: seeker.id),
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
