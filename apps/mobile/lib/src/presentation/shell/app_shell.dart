import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../theme/sprout_tokens.dart';
import '../../theme/sprout_theme.dart';
import '../today/today_screen.dart' show QuickActionGrid;
import 'nav_metrics.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  // Regression-protected shell: Today · Money · + · Insights · Settings.
  // The center "+" is an action sheet trigger, not a destination tab.
  static const _tabs = [
    _SproutTab('Today', Icons.wb_sunny_rounded, '/today'),
    _SproutTab('Money', Icons.account_balance_wallet_rounded, '/money'),
    _SproutTab('Insights', Icons.explore_rounded, '/insights'),
    _SproutTab('Settings', Icons.settings_rounded, '/settings'),
  ];

  /// Resolves whether tab [index] is the active one. Falls back to Today
  /// (index 0) when the location doesn't match any tab (e.g. /learn).
  bool _isSelected(int currentIndex, int index) =>
      (currentIndex < 0 ? 0 : currentIndex) == index;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _tabs.indexWhere((tab) => tab.path == location);
    final colors = SproutColorScheme.of(context);

    return Scaffold(
      // Bottom content padding is explicit in every page scroll view. Keeping
      // the body's bottom SafeArea off avoids counting the same inset twice.
      body: SafeArea(top: true, bottom: false, child: child),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              key: const ValueKey('floating-primary-nav'),
              height: NavMetrics.barHeight,
              margin: const EdgeInsets.fromLTRB(
                  14, 0, 14, NavMetrics.barBottomMargin),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(SproutRadius.hero),
                border: Border.all(color: colors.line.withValues(alpha: 0.45)),
                boxShadow: [
                  BoxShadow(
                    color: colors.ink.withValues(alpha: 0.1),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      tab: _tabs[0],
                      selected: _isSelected(currentIndex, 0),
                      onTap: () => context.go(_tabs[0].path),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      tab: _tabs[1],
                      selected: _isSelected(currentIndex, 1),
                      onTap: () => context.go(_tabs[1].path),
                    ),
                  ),
                  const SizedBox(width: 76),
                  Expanded(
                    child: _NavItem(
                      tab: _tabs[2],
                      selected: _isSelected(currentIndex, 2),
                      onTap: () => context.go(_tabs[2].path),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      tab: _tabs[3],
                      selected: _isSelected(currentIndex, 3),
                      onTap: () => context.go(_tabs[3].path),
                    ),
                  ),
                ],
              ),
            ),

            // Center Quick Add button (not a tab) — a confident saturated
            // green circle, the Duolingo-style bold center action.
            Positioned(
              bottom: 18,
              child: SproutButtonPress(
                onTap: () => QuickActionGrid.openQuickAdd(context),
                scale: 0.9,
                semanticLabel: 'Quick Add',
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: SproutColors.seed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: SproutColors.seed.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final _SproutTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    final colors = SproutColorScheme.of(context);
    final selectedColor = SproutColors.seed;
    final idleColor = colors.muted;
    final item = SproutButtonPress(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      scale: 0.9,
      semanticLabel: tab.label,
      child: AnimatedContainer(
        duration: reducedMotion ? Duration.zero : SproutDurations.buttonPress,
        curve: SproutCurves.button,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
        decoration: BoxDecoration(
          color: selected ? colors.mint : Colors.transparent,
          borderRadius: BorderRadius.circular(SproutRadius.tile),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab.icon,
              color: selected ? selectedColor : idleColor,
              size: selected ? 24 : 23,
              fill: selected ? 1.0 : 0.4,
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                tab.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected ? selectedColor : idleColor,
                      fontSize: tab.label.length > 7 ? 11 : 12,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );

    if (reducedMotion || !selected) return item;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: child,
      ),
      child: item,
    );
  }
}

class _SproutTab {
  const _SproutTab(this.label, this.icon, this.path);

  final String label;
  final IconData icon;
  final String path;
}
