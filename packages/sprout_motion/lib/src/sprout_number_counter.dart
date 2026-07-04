import 'package:flutter/widgets.dart';

import 'sprout_curves.dart';

class SproutNumberCounter extends StatelessWidget {
  const SproutNumberCounter({
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 750),
    super.key,
  });

  final num value;
  final Duration duration;
  final Widget Function(BuildContext context, num value) builder;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value.toDouble()),
      duration: duration,
      curve: SproutCurves.progress,
      builder: (context, animatedValue, _) => builder(context, animatedValue),
    );
  }
}
