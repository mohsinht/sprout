import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/add/add_screen.dart';
import '../presentation/learn/learn_screen.dart';
import '../presentation/mascot_lab/mascot_lab_screen.dart';
import '../presentation/money/money_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/shell/app_shell.dart';
import '../presentation/today/today_screen.dart';
import '../theme/sprout_theme.dart';
import 'theme_mode_controller.dart';

final _router = GoRouter(
  initialLocation: '/today',
  routes: [
    GoRoute(
      path: '/mascot-lab',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: MascotLabScreen()),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/today',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: TodayScreen()),
        ),
        GoRoute(
          path: '/add',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AddScreen()),
        ),
        GoRoute(
          path: '/money',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: MoneyScreen()),
        ),
        GoRoute(
          path: '/learn',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: LearnScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsScreen()),
        ),
      ],
    ),
  ],
);

class SproutApp extends ConsumerWidget {
  const SproutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
