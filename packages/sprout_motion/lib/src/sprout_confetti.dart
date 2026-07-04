import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class SproutConfetti extends StatelessWidget {
  const SproutConfetti({
    required this.asset,
    this.repeat = false,
    super.key,
  });

  final String asset;
  final bool repeat;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Lottie.asset(
        asset,
        repeat: repeat,
        fit: BoxFit.cover,
      ),
    );
  }
}
