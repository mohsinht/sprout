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
import '../data/api/sprout_api_client.dart';
import '../data/reminder_service.dart';
import '../data/backend_availability.dart';
import '../data/reduce_motion_store.dart';
import '../theme/sprout_theme.dart';
import 'theme_mode_controller.dart';
import 'app_lock_gate.dart';
import 'sprout_environment.dart';

GoRouter buildSproutRouter(AuthSession? session) => GoRouter(
      initialLocation: '/today',
      redirect: (context, state) {
        final path = state.uri.path;
        if (session == null) return path == '/auth' ? null : '/auth';
        if (!session.onboardingComplete) {
          return path == '/onboarding' ? null : '/onboarding';
        }
        if (path == '/auth' || path == '/onboarding') return '/today';
        return null;
      },
      routes: [
        GoRoute(
          path: '/auth',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AuthScreen()),
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
            // The lesson path is a development fixture, not a production
            // promise. Production learning stays inside Sprout Explains.
            if (useSproutMocks)
              GoRoute(
                path: '/learn',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: LearnScreen()),
              ),
          ],
        ),
      ],
    );

final sproutMessengerKey = GlobalKey<ScaffoldMessengerState>();

class SproutApp extends ConsumerWidget {
  const SproutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Restore the persisted session at app startup. If Today started loading
    // before restoration completed, retry it once the access token is ready.
    final session = ref.watch(authSessionProvider);
    ref.listen(authSessionProvider, (previous, next) {
      if (next != null && previous?.accessToken != next.accessToken) {
        ref.invalidate(todayControllerProvider);
      }
    });
    final themeMode = ref.watch(themeModeProvider);
    final reduceMotion = ref.watch(reduceMotionProvider);
    final effectiveSession = useSproutMocks && session == null
        ? const AuthSession(
            accessToken: 'dev',
            refreshToken: 'dev',
            userId: 'dev',
            onboardingComplete: true,
          )
        : session;
    final router = buildSproutRouter(effectiveSession);
    ReminderService.instance.initialize(onOpen: router.go);
    return MaterialApp.router(
      title: 'Sprout',
      scaffoldMessengerKey: sproutMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: buildSproutTheme(brightness: Brightness.light),
      darkTheme: buildSproutTheme(brightness: Brightness.dark),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final content = BackendAvailabilityNotice(
          child: AppLockGate(child: child ?? const SizedBox.shrink()),
        );
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            disableAnimations: reduceMotion || media.disableAnimations,
            textScaler: useSproutSweepHarness
                ? TextScaler.linear(sproutSweepTextScale)
                : media.textScaler,
          ),
          child: content,
        );
      },
    );
  }
}

class BackendAvailabilityNotice extends ConsumerWidget {
  const BackendAvailabilityNotice({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(backendAvailabilityProvider);
    ref.listen<BackendAvailability>(backendAvailabilityProvider,
        (previous, next) {
      final messenger = sproutMessengerKey.currentState;
      if (messenger == null || previous == next) return;
      if (next == BackendAvailability.warming) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            key: ValueKey('backend-warming-toast'),
            content: Text(
              'Sprout is waking up. Saved entries are still available.',
            ),
            duration: Duration(seconds: 8),
            behavior: SnackBarBehavior.floating,
          ));
      } else if (next == BackendAvailability.unavailable) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            key: ValueKey('backend-unavailable-toast'),
            content: Text(
              'Sprout cannot sync yet. Changes stay on this device for now.',
            ),
            duration: Duration(seconds: 8),
            behavior: SnackBarBehavior.floating,
          ));
      } else if (next == BackendAvailability.ready &&
          previous != null &&
          previous != BackendAvailability.checking) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            key: ValueKey('backend-ready-toast'),
            content: Text('Sprout is ready. New changes can sync now.'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ));
      }
    });
    return child;
  }
}
