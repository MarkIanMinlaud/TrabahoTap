import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'home_placeholder_screen.dart';
import 'onboarding_screen.dart';
import 'role_select_screen.dart';
import 'seeker_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    final app = context.read<AppProvider>();
    Widget next;
    if (!app.hasSeenOnboarding) {
      next = const OnboardingScreen();
    } else if (app.currentUser != null) {
      next = app.currentUser!.role == UserRole.seeker
          ? const SeekerShell()
          : const HomePlaceholderScreen();
    } else {
      next = const RoleSelectScreen();
    }
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.work_rounded,
                size: 56,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'TrabahoTap',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
