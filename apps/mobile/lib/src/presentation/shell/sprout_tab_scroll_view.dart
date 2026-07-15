import 'package:flutter/material.dart';

import '../../theme/sprout_tokens.dart';
import 'nav_metrics.dart';

/// The only scroll scaffold used by the four primary tabs.
///
/// It owns the floating-nav clearance contract so individual screens cannot
/// accidentally reserve too little space or count the safe area twice.
class SproutTabScrollView extends StatelessWidget {
  const SproutTabScrollView({
    required this.children,
    this.topPadding = SproutSpacing.pageTop,
    this.controller,
    super.key,
  });

  final List<Widget> children;
  final double topPadding;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const ValueKey('primary-tab-scroll-view'),
      controller: controller,
      slivers: [
        SliverPadding(
          padding: NavMetrics.pagePadding(context).copyWith(top: topPadding),
          sliver: SliverList.list(children: [
            ...children,
            const SizedBox(key: ValueKey('primary-tab-content-end')),
          ]),
        ),
      ],
    );
  }
}
