import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../theme/sprout_tokens.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static const _tabs = [
    _SproutTab('Today', Icons.wb_sunny_rounded, '/today'),
    _SproutTab('Budget', Icons.account_balance_wallet_rounded, '/budget'),
    _SproutTab('Grow', Icons.spa_rounded, '/grow'),
    _SproutTab('Learn', Icons.school_rounded, '/learn'),
    _SproutTab('Profile', Icons.person_rounded, '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _tabs.indexWhere((tab) => tab.path == location);

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: SproutColors.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: SproutColors.ink.withValues(alpha: 0.1),
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
    final item = SproutButtonPress(
      onTap: onTap,
      scale: 0.9,
      child: AnimatedContainer(
        duration: reducedMotion ? Duration.zero : SproutDurations.buttonPress,
        curve: SproutCurves.button,
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: selected ? SproutColors.mint : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected && tab.label == 'Today')
              const Icon(Icons.eco_rounded, size: 10, color: SproutColors.seed),
            Icon(
              tab.icon,
              color: selected ? SproutColors.leaf : const Color(0xFF3F4A43),
              size: selected ? 25 : 23,
              fill: selected ? 1 : 0,
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                tab.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected
                          ? SproutColors.leaf
                          : const Color(0xFF3F4A43),
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
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
