import 'package:flutter/material.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../theme/sprout_tokens.dart';
import '../theme/sprout_theme.dart';

/// A raised white panel used across screens for grouped content.
///
/// Replaces the per-screen `_RaisedPanel` copies.
class SproutRaisedPanel extends StatelessWidget {
  const SproutRaisedPanel({
    required this.child,
    this.padding = const EdgeInsets.all(SproutSpacing.lg),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(SproutRadius.card),
        border: Border.all(color: colors.line),
        boxShadow: SproutElevation.raised(),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// A small circular action button used in page headers.
class SproutRoundAction extends StatelessWidget {
  const SproutRoundAction({
    required this.icon,
    required this.onTap,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return SproutButtonPress(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: colors.line),
            boxShadow: SproutElevation.card(),
          ),
          child: Icon(icon, color: colors.ink, size: 22),
        ),
      ),
    );
  }
}

/// A reusable quest card with a colored gradient, icon, label, title and reward.
class SproutQuestCard extends StatelessWidget {
  const SproutQuestCard({
    required this.color,
    required this.icon,
    required this.label,
    required this.title,
    required this.reward,
    required this.onTap,
    this.semanticLabel,
    super.key,
  });

  final Color color;
  final IconData icon;
  final String label;
  final String title;
  final String reward;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SproutButtonPress(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: semanticLabel ?? '$label: $title',
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, Color.lerp(color, Colors.black, 0.16)!],
            ),
            borderRadius: BorderRadius.circular(SproutRadius.card),
            boxShadow: [
              BoxShadow(
                color: Color.lerp(color, Colors.black, 0.18)!,
                blurRadius: 0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(SproutSpacing.lg),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: SproutSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 0.4,
                            ),
                      ),
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SproutRewardPill(text: reward),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A pill-shaped reward badge (e.g. "+20 XP").
class SproutRewardPill extends StatelessWidget {
  const SproutRewardPill({
    required this.text,
    this.onLight = false,
    super.key,
  });

  final String text;
  /// When true, uses a light-on-dark style suitable for dark hero surfaces.
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: onLight ? 0.74 : 0.22),
        borderRadius: BorderRadius.circular(SproutRadius.pill),
        border: Border.all(
          color: Colors.white.withValues(alpha: onLight ? 1 : 0.35),
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: onLight ? SproutColors.leaf : Colors.white,
              fontWeight: onLight ? FontWeight.w900 : FontWeight.w800,
            ),
      ),
    );
  }
}