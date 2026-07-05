import 'package:flutter/material.dart';

import '../theme/sprout_theme.dart';
import '../theme/sprout_tokens.dart';

/// A single privacy / trust statement with a reassuring icon. Used on
/// Settings → Privacy. Calm, never alarming. Dark-mode aware.
class TrustBadge extends StatelessWidget {
  const TrustBadge({required this.label, this.icon, super.key});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: colors.mint,
          child: Icon(
            icon ?? Icons.verified_user_rounded,
            color: SproutColors.leaf,
            size: 18,
          ),
        ),
        const SizedBox(width: SproutSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: colors.ink),
            ),
          ),
        ),
      ],
    );
  }
}

/// A simple labelled toggle row for preferences (reduced motion, haptics,
/// sound, etc.). Dark-mode aware through the theme's Switch.
class PreferenceToggle extends StatelessWidget {
  const PreferenceToggle({
    required this.label,
    required this.value,
    this.onChanged,
    this.icon,
    this.comingSoon = false,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData? icon;

  /// When true, render a calm "Soon" pill instead of a live toggle. Use for
  /// preferences that aren't wired yet so the trust center never shows a
  /// control that silently does nothing.
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: colors.muted, size: 20),
          const SizedBox(width: SproutSpacing.md),
        ],
        Expanded(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: colors.ink),
          ),
        ),
        if (comingSoon)
          const _SoonPill()
        else
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: SproutColors.seed,
          ),
      ],
    );
  }
}

class _SoonPill extends StatelessWidget {
  const _SoonPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: SproutColors.gold.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(SproutRadius.pill),
      ),
      child: Text(
        'Soon',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: SproutColors.goldInk,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}