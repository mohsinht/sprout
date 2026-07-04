import 'package:flutter/material.dart';

import 'sprout_curves.dart';
import 'sprout_durations.dart';

class SproutButtonPress extends StatefulWidget {
  const SproutButtonPress({
    required this.child,
    this.onTap,
    this.scale = 0.96,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<SproutButtonPress> createState() => _SproutButtonPressState();
}

class _SproutButtonPressState extends State<SproutButtonPress> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: SproutDurations.buttonPress,
        curve: SproutCurves.button,
        child: widget.child,
      ),
    );
  }
}
