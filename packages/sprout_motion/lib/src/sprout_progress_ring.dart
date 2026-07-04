import 'package:flutter/material.dart';

import 'sprout_curves.dart';
import 'sprout_durations.dart';

class SproutProgressRing extends StatelessWidget {
  const SproutProgressRing({
    required this.value,
    required this.color,
    required this.child,
    this.backgroundColor,
    this.strokeWidth = 9,
    super.key,
  });

  final double value;
  final Color color;
  final Color? backgroundColor;
  final double strokeWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value.clamp(0, 1).toDouble()),
      duration: SproutDurations.progressRing,
      curve: SproutCurves.progress,
      builder: (context, progress, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              color: color,
              backgroundColor: backgroundColor ??
                  Theme.of(context).colorScheme.outlineVariant,
            ),
            Center(child: child),
          ],
        );
      },
    );
  }
}
