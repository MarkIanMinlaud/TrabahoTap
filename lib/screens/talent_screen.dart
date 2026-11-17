import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find trusted workers',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name or skill',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: talent.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline, size: 48, color: AppColors.textSecondary),
                          SizedBox(height: 8),
                          Text('No workers found', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: talent.length,
                      itemBuilder: (context, i) {
                        final seeker = talent[i];
                        return TalentCard(
                          seeker: seeker,
                          app: app,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => TalentDetailScreen(seekerId: seeker.id)),
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
