import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
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
      home: Consumer<AppProvider>(
        builder: (context, app, _) {
          if (!app.isLoaded) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const SplashScreen();
        },
      ),
    );
  }
}
