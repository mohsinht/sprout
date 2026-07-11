import 'package:flutter/widgets.dart';

import '../../theme/sprout_tokens.dart';

class NavMetrics {
  const NavMetrics._();

  static const barHeight = 82.0;
  static const barBottomMargin = 10.0;
  static const contentGap = 24.0;

  /// Space reserved after the last scrollable item so the floating shell can
  /// never cover it. The shell owns the bottom safe area; page content uses
  /// this same contract instead of guessing at the device inset.
  static double shellExtent(BuildContext context) {
    return barHeight + barBottomMargin + MediaQuery.paddingOf(context).bottom;
  }

  static double bottomContentPadding(BuildContext context) {
    return shellExtent(context) + contentGap;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    return EdgeInsets.fromLTRB(
      SproutSpacing.pageHorizontal,
      SproutSpacing.pageTop,
      SproutSpacing.pageHorizontal,
      bottomContentPadding(context),
    );
  }
}
