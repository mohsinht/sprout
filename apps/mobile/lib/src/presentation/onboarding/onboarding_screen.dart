import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/sprout_tokens.dart';
import '../../theme/sprout_theme.dart';
import '../../widgets/sprout_mascot.dart';
import '../../widgets/sprout_mascot_state.dart';

/// Onboarding — a calm, one-question-per-screen conversation with Sprout.
///
/// Per spec (user_stories S1-S6, information_gathering_trust.md):
/// - No external connection is required to complete onboarding or reach Today.
/// - Skipping all onboarding asks never blocks completion.
/// - The app never dead-ends on skip.
/// - Onboarding never presents more than one question per screen.
/// - Onboarding never asks for salary date, income type, multiple goals, or
///   source connections before first value.
/// - Onboarding completes offline.
///
/// This is a placeholder implementation with a single welcome step that
/// hands off to Today. Real steps (nickname, goal pick, income context)
/// will be added one-per-screen as separate steps.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SproutSpacing.pageHorizontal,
            vertical: SproutSpacing.pageTop,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: SproutMascot(
                  state: SproutMascotState.happy,
                  size: 120,
                ),
              ),
              const SizedBox(height: SproutSpacing.xl),
              Text(
                "Hi, I'm Sprout.",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: SproutSpacing.sm),
              Text(
                'Your 30-second daily money check-in.\n'
                'No bank connection needed — we can start with just you.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.muted,
                      height: 1.5,
                    ),
              ),
              const Spacer(),
              // One primary action: start. Skip is the warm secondary path.
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go('/today'),
                  style: FilledButton.styleFrom(
                    backgroundColor: SproutColors.seed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(SproutRadius.pill),
                    ),
                  ),
                  child: const Text("Let's start"),
                ),
              ),
              const SizedBox(height: SproutSpacing.sm),
              // Warm skip — S2: skipping never blocks completion.
              Center(
                child: TextButton(
                  onPressed: () => context.go('/today'),
                  child: Text(
                    'Skip for now',
                    style: TextStyle(color: colors.muted),
                  ),
                ),
              ),
              const SizedBox(height: SproutSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}