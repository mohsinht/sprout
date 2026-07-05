import 'package:flutter/material.dart';

import 'sprout_curves.dart';
import 'sprout_durations.dart';

class SproutButtonPress extends StatefulWidget {
  const SproutButtonPress({
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.semanticLabel,
    this.button = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  /// Accessibility label announced by screen readers. When null the child's
  /// own semantics are used. When provided the widget is marked as a button.
  final String? semanticLabel;

  /// Whether to mark this node as a button in the semantics tree. Defaults to
  /// true when [onTap] is non-null. Set to false for decorative tappable areas.
  final bool button;

  @override
  State<SproutButtonPress> createState() => _SproutButtonPressState();
}

class _SproutButtonPressState extends State<SproutButtonPress> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onTap != null;
    final content = GestureDetector(
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

    if (!isInteractive && widget.semanticLabel == null) {
      return content;
    }

    return Semantics(
      button: widget.button && isInteractive,
      enabled: isInteractive,
      label: widget.semanticLabel,
      child: content,
    );
  }
}
