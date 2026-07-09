import 'package:flutter/widgets.dart';

import '../../theme/sprout_tokens.dart';

class NavMetrics {
  const NavMetrics._();

  static const barHeight = 82.0;
  static const barBottomMargin = 10.0;
  static const contentGap = 34.0;

  static double bottomContentPadding(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom +
        barHeight +
        barBottomMargin +
        contentGap;
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
