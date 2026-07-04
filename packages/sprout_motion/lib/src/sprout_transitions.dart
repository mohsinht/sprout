import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'sprout_curves.dart';
import 'sprout_durations.dart';

extension SproutTransitionEffects on Widget {
  Widget sproutCardEntrance({
    Duration delay = Duration.zero,
    double beginY = 0.035,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: SproutDurations.cardEntrance)
        .slideY(
          begin: beginY,
          end: 0,
          duration: SproutDurations.cardEntrance,
          curve: SproutCurves.standard,
        );
  }

  Widget sproutMascotIdle() {
    return animate(onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(begin: 0, end: -5, duration: SproutDurations.mascotReaction);
  }

  Widget sproutRewardPop() {
    return animate().scaleXY(
      begin: 0.96,
      end: 1,
      duration: SproutDurations.xpReward,
      curve: SproutCurves.playful,
    );
  }
}
