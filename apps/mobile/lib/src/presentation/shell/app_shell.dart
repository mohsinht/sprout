import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../theme/sprout_tokens.dart';
import '../../theme/sprout_theme.dart';
import '../today/today_screen.dart' show QuickActionGrid;

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  // Navigation per spec: only three tabs visible in the shell.
  static const _tabs = [
    _SproutTab('Today', Icons.wb_sunny_rounded, '/today'),
    _SproutTab('Money', Icons.account_balance_wallet_rounded, '/money'),
    _SproutTab('Settings', Icons.settings_rounded, '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _tabs.indexWhere((tab) => tab.path == location);
    final colors = SproutColorScheme.of(context);

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(SproutRadius.hero),
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
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: _NavItem(
                    tab: _tabs[i],
                    selected: i == (currentIndex < 0 ? 0 : currentIndex),
                    onTap: () => context.go(_tabs[i].path),
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
      onTap: onTap,
      scale: 0.9,
      child: AnimatedContainer(
        duration: reducedMotion ? Duration.zero : SproutDurations.buttonPress,
        curve: SproutCurves.button,
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: selected ? colors.mint : Colors.transparent,
          borderRadius: BorderRadius.circular(SproutRadius.tile),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected && tab.label == 'Today')
              Icon(Icons.eco_rounded, size: 10, color: selectedColor),
            Icon(
              tab.icon,
              color: selected ? selectedColor : idleColor,
              size: selected ? 27 : 25,
              fill: selected ? 1.0 : 0.4,
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                tab.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected ? selectedColor : idleColor,
                      fontSize: 12,
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
