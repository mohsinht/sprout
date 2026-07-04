import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/budget/budget_screen.dart';
import '../presentation/grow/grow_screen.dart';
import '../presentation/learn/learn_screen.dart';
import '../presentation/profile/profile_screen.dart';
import '../presentation/shell/app_shell.dart';
import '../presentation/today/today_screen.dart';
import '../theme/sprout_theme.dart';

final _router = GoRouter(
  initialLocation: '/today',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/today',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: TodayScreen()),
        ),
        GoRoute(
          path: '/budget',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: BudgetScreen()),
        ),
        GoRoute(
          path: '/grow',
          pageBuilder: (context, state) => const NoTransitionPage(child: GrowScreen()),
        ),
        GoRoute(
          path: '/learn',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: LearnScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileScreen()),
        ),
      ],
    ),
  ],
);

class SproutApp extends StatelessWidget {
  const SproutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sprout',
      debugShowCheckedModeBanner: false,
      theme: buildSproutTheme(),
      routerConfig: _router,
    );
  }
}
