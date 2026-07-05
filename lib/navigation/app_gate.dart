import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/shared/loading_widget.dart';
import 'main_navigation_shell.dart';

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppStateProvider>();
    if (!app.ready) return const LoadingWidget();
    if (!app.canEnterApp) return const OnboardingScreen();
    return const MainNavigationShell();
  }
}
