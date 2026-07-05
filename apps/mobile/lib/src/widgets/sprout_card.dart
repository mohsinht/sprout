import 'package:flutter/material.dart';

import '../theme/sprout_tokens.dart';
import '../theme/sprout_theme.dart';

class SproutCard extends StatelessWidget {
  const SproutCard({
    required this.child,
    this.padding = const EdgeInsets.all(SproutSpacing.lg),
    this.color,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: BorderRadius.circular(SproutRadius.card),
        boxShadow: SproutElevation.card(color: colors.ink),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
