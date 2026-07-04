import 'package:flutter/material.dart';

import '../theme/sprout_tokens.dart';

class SproutCard extends StatelessWidget {
  const SproutCard({
    required this.child,
    this.padding = const EdgeInsets.all(SproutSpacing.lg),
    this.color = SproutColors.surface,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: SproutColors.ink.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
