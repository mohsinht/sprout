import 'package:flutter/material.dart';

import '../../theme/sprout_tokens.dart';
import '../../theme/sprout_theme.dart';
import '../../widgets/sprout_panel.dart';
import '../../widgets/trust_badge.dart';

/// A section header label used above each grouped [SproutRaisedPanel].
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: SproutSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.muted,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

/// A grouped section: a calm header label followed by a raised panel.
///
/// All Settings sections use this widget so they share the same label style,
/// label→card gap, card radius, border, elevation, and internal padding.
/// The optional [tint] and [tintBorder] allow the privacy block to use the
/// same structure with a calm green tint — the only intentional variation.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.header,
    required this.child,
    this.padding = const EdgeInsets.all(SproutSpacing.lg),
    this.tint,
    this.tintBorder,
    super.key,
  });

  final String header;
  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Optional background tint (e.g. privacy block's calm green).
  final Color? tint;

  /// Optional border color to pair with [tint].
  final Color? tintBorder;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(label: header),
        DecoratedBox(
          decoration: BoxDecoration(
            color: tint ?? colors.surface,
            borderRadius: BorderRadius.circular(SproutRadius.card),
            border: Border.all(color: tintBorder ?? colors.line),
            boxShadow: SproutElevation.raised(),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ],
    );
  }
}

/// A single currency option chip in a segmented selection.
class CurrencyChip extends StatelessWidget {
  const CurrencyChip({
    required this.code,
    required this.label,
    required this.selected,
    required this.onTap,
    this.enabled = true,
    super.key,
  });

  final String code;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// When false, the chip renders muted and non-tappable with a "Soon" tag —
  /// for currencies that exist in the UI but aren't wired into formatting yet.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final bg = selected ? colors.mint : colors.surface;
    final fg =
        selected ? SproutColors.leaf : (enabled ? colors.ink : colors.muted);
    final borderColor =
        selected ? SproutColors.seed.withValues(alpha: 0.45) : colors.line;
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(SproutRadius.pill),
        border: Border.all(color: borderColor, width: selected ? 1.6 : 1),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            code,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected ? SproutColors.leaf : colors.muted,
                ),
          ),
          if (!enabled) ...[
            const SizedBox(height: 2),
            const SoonPill(),
          ],
        ],
      ),
    );
    if (!enabled) {
      return Expanded(
        child: Semantics(
          label: 'Currency $label, coming soon',
          child: content,
        ),
      );
    }
    return Expanded(
      child: _ChipTap(
        onTap: onTap,
        semanticLabel: 'Currency $label',
        child: content,
      ),
    );
  }
}

class _ChipTap extends StatelessWidget {
  const _ChipTap({
    required this.onTap,
    required this.semanticLabel,
    required this.child,
  });

  final VoidCallback onTap;
  final String semanticLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Semantics(
        button: true,
        selected: false,
        label: semanticLabel,
        child: child,
      ),
    );
  }
}
