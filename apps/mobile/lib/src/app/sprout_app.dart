import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/learn/learn_screen.dart';
import '../presentation/insights/insights_screen.dart';
import '../presentation/mascot_lab/mascot_lab_screen.dart';
import '../presentation/money/money_screen.dart';
import '../presentation/onboarding/onboarding_screen.dart';
import '../presentation/auth/auth_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/shell/app_shell.dart';
import '../presentation/today/today_screen.dart';
import '../presentation/today/today_controller.dart';
import '../data/auth_store.dart';
import '../theme/sprout_theme.dart';
import 'theme_mode_controller.dart';

final _router = GoRouter(
  initialLocation: '/today',
  routes: [
    GoRoute(
      path: '/auth',
      pageBuilder: (context, state) => const NoTransitionPage(child: AuthScreen()),
    ),
    // Dev-only mascot lab — not part of the product shell.
    GoRoute(
      path: '/mascot-lab',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: MascotLabScreen()),
    ),
    // Onboarding — one-question-per-screen conversation, ends on Today.
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: OnboardingScreen()),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        // Four primary tabs per spec: Today, Money, Insights, Settings.
        GoRoute(
          path: '/today',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: TodayScreen()),
        ),
        GoRoute(
          path: '/money',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: MoneyScreen()),
        ),
        GoRoute(
          path: '/insights',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: InsightsScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsScreen()),
        ),
        // Learn is reachable by deep-link but is NOT a shell tab.
        // Learning content folds into Sprout Explains per spec.
        GoRoute(
          path: '/learn',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: LearnScreen()),
        ),
      ],
    ),
  ],
);

class SproutApp extends ConsumerWidget {
  const SproutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Restore the persisted session at app startup. If Today started loading
    // before restoration completed, retry it once the access token is ready.
    ref.watch(authSessionProvider);
    ref.listen(authSessionProvider, (previous, next) {
      if (next != null && previous?.accessToken != next.accessToken) {
        ref.invalidate(todayControllerProvider);
      }
    });
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Sprout',
      debugShowCheckedModeBanner: false,
      theme: buildSproutTheme(brightness: Brightness.light),
      darkTheme: buildSproutTheme(brightness: Brightness.dark),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
