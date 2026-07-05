import 'package:flutter/material.dart';

import '../theme/sprout_strings.dart';
import '../theme/sprout_tokens.dart';
import '../theme/sprout_theme.dart';
import 'sprout_mascot.dart';
import 'sprout_mascot_state.dart';

/// Branded full-screen loading state for Sprout screens.
class SproutLoadingView extends StatelessWidget {
  const SproutLoadingView({this.label = SproutStrings.sprouting, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SproutMascot(state: SproutMascotState.idle, size: 84),
          const SizedBox(height: SproutSpacing.lg),
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: SproutColors.seed,
              backgroundColor: colors.line,
            ),
          ),
          const SizedBox(height: SproutSpacing.md),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// Branded full-screen error state with a retry action.
class SproutErrorView extends StatelessWidget {
  const SproutErrorView({
    required this.message,
    this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SproutSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.eco_rounded,
              size: 64,
              color: SproutColors.muted,
            ),
            const SizedBox(height: SproutSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: SproutSpacing.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(SproutStrings.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Branded empty state for screens with no data yet.
class SproutEmptyView extends StatelessWidget {
  const SproutEmptyView({
    required this.title,
    required this.subtitle,
    this.icon = Icons.eco_rounded,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SproutSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: SproutColors.muted),
            const SizedBox(height: SproutSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: SproutSpacing.sm),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: SproutSpacing.lg),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A shimmer-style skeleton card for placeholder content while loading.
class SproutSkeletonCard extends StatelessWidget {
  const SproutSkeletonCard({
    this.height = 120,
    super.key,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(SproutRadius.card),
        border: Border.all(color: colors.line),
      ),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(SproutSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonLine(width: 120, color: colors.line),
              const SizedBox(height: SproutSpacing.md),
              _SkeletonLine(width: 200, color: colors.line),
              const SizedBox(height: SproutSpacing.sm),
              _SkeletonLine(width: 160, color: colors.line),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(SproutRadius.pill),
      ),
    );
  }
}