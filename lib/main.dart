import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider()..loadData(),
      child: const TrabahoTapApp(),
    ),
  );
}

class TrabahoTapApp extends StatelessWidget {
  const TrabahoTapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrabahoTap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const PlaceholderHomeScreen(),
    );
  }
}

class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, app, _) {
        if (!app.isLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('TrabahoTap'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.work_outline,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome to TrabahoTap',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Seeded: ${app.users.length} users, ${app.jobs.length} jobs',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
