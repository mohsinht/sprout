import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../theme/sprout_tokens.dart';
import '../../widgets/sprout_page.dart';
import '../today/today_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _goals = [
    _Goal('Emergency', Icons.savings_rounded, 0.50, SproutColors.seed,
        'PKR 450K'),
    _Goal('Vacation', Icons.beach_access_rounded, 0.48, SproutColors.sky,
        'PKR 120K'),
    _Goal('Car', Icons.directions_car_rounded, 0.48, SproutColors.lilac,
        'PKR 2.4M'),
    _Goal('Home', Icons.home_rounded, 0.28, SproutColors.gold, 'PKR 8.5M'),
  ];

  static const _badges = [
    _Badge('Saver', Icons.savings_rounded, SproutColors.sky),
    _Badge('Streak', Icons.local_fire_department_rounded, SproutColors.gold),
    _Badge('Learner', Icons.school_rounded, SproutColors.lilac),
    _Badge('Guard', Icons.shield_rounded, SproutColors.seed),
  ];

  @override
  Widget build(BuildContext context) {
    return SproutPage(
      title: 'Profile',
      subtitle: 'Your money habits, leveled up.',
      trailing: _RoundAction(
        icon: Icons.settings_rounded,
        onTap: () {
          HapticFeedback.selectionClick();
          SproutBottomSheet.show(
            context,
            title: 'Settings',
            rows: const [
              SheetInfoRow(
                icon: Icons.lock_rounded,
                label: 'Privacy',
                value: 'Data stays masked by default.',
              ),
              SheetInfoRow(
                icon: Icons.link_off_rounded,
                label: 'Sources',
                value: 'Disconnect Gmail, Wise, or alerts.',
              ),
              SheetInfoRow(
                icon: Icons.delete_outline_rounded,
                label: 'Delete data',
                value: 'Export first, then remove account data.',
              ),
            ],
          );
        },
      ),
      children: const [
        _ProfileHero(),
        SizedBox(height: SproutSpacing.md),
        _LevelStats(),
        SizedBox(height: SproutSpacing.md),
        _GoalsBoard(),
        SizedBox(height: SproutSpacing.md),
        _HabitsCard(),
        SizedBox(height: SproutSpacing.md),
        _BadgeShelf(),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14B59B), Color(0xFF0B8D79)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B8D79).withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
          const BoxShadow(
            color: Color(0xFF087060),
            blurRadius: 0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 46,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: SproutSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mohsin',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                  ),
                  Text(
                    'Money Explorer',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Level 7',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: SproutProgressBar(
                          value: 0.62,
                          color: SproutColors.gold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SproutMascot(
              size: 60,
              mood: SproutMascotMood.celebrating,
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelStats extends StatelessWidget {
  const _LevelStats();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _StatBubble(
            icon: Icons.local_fire_department_rounded,
            value: '12',
            label: 'Streak',
            color: SproutColors.gold,
          ),
        ),
        SizedBox(width: SproutSpacing.sm),
        Expanded(
          child: _StatBubble(
            icon: Icons.bolt_rounded,
            value: '1.8K',
            label: 'XP',
            color: SproutColors.sky,
          ),
        ),
        SizedBox(width: SproutSpacing.sm),
        Expanded(
          child: _StatBubble(
            icon: Icons.emoji_events_rounded,
            value: '8',
            label: 'Badges',
            color: SproutColors.lilac,
          ),
        ),
      ],
    );
  }
}

class _StatBubble extends StatelessWidget {
  const _StatBubble({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SproutButtonPress(
      onTap: HapticFeedback.selectionClick,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: SproutColors.line),
          boxShadow: [
            BoxShadow(
              color: SproutColors.ink.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: color, size: 25),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: SproutColors.muted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalsBoard extends StatelessWidget {
  const _GoalsBoard();

  @override
  Widget build(BuildContext context) {
    return _RaisedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Goals', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              const SourceStatusPill(label: '4 active', connected: true),
            ],
          ),
          const SizedBox(height: SproutSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = (constraints.maxWidth - SproutSpacing.sm) / 2;
              return Wrap(
                spacing: SproutSpacing.sm,
                runSpacing: SproutSpacing.sm,
                children: [
                  for (final goal in ProfileScreen._goals)
                    _GoalTile(goal: goal, width: tileWidth),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({required this.goal, required this.width});

  final _Goal goal;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: SproutButtonPress(
        onTap: HapticFeedback.selectionClick,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: goal.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: goal.color.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(goal.icon, color: goal.color),
                    const Spacer(),
                    Text(
                      '${(goal.progress * 100).round()}%',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: goal.color,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(goal.name, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  goal.amount,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SproutColors.muted,
                      ),
                ),
                const SizedBox(height: 10),
                SproutProgressBar(value: goal.progress, color: goal.color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HabitsCard extends StatelessWidget {
  const _HabitsCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7DA), Color(0xFFFFE8A7)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SproutColors.gold.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: SproutColors.gold.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.64),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: SproutColors.seed,
                size: 30,
              ),
            ),
            const SizedBox(width: SproutSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Habits blooming',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '6 of 7 on track',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SproutColors.muted,
                        ),
                  ),
                ],
              ),
            ),
            const _RewardPill(label: '+15 XP'),
          ],
        ),
      ),
    );
  }
}

class _BadgeShelf extends StatelessWidget {
  const _BadgeShelf();

  @override
  Widget build(BuildContext context) {
    return _RaisedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Badges', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: SproutSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final badge in ProfileScreen._badges)
                _BadgeTile(badge: badge),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardPill extends StatelessWidget {
  const _RewardPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: SproutColors.leaf,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final _Badge badge;

  @override
  Widget build(BuildContext context) {
    return SproutButtonPress(
      onTap: HapticFeedback.selectionClick,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [badge.color.withValues(alpha: 0.9), badge.color],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: badge.color.withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(badge.icon, color: Colors.white),
            ),
            const SizedBox(height: SproutSpacing.xs),
            Text(
              badge.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: SproutColors.muted,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SproutButtonPress(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: SproutColors.line),
          boxShadow: [
            BoxShadow(
              color: SproutColors.ink.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: SproutColors.ink, size: 22),
      ),
    );
  }
}

class _RaisedPanel extends StatelessWidget {
  const _RaisedPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SproutColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SproutColors.line),
        boxShadow: [
          BoxShadow(
            color: SproutColors.ink.withValues(alpha: 0.08),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _Goal {
  const _Goal(this.name, this.icon, this.progress, this.color, this.amount);

  final String name;
  final IconData icon;
  final double progress;
  final Color color;
  final String amount;
}

class _Badge {
  const _Badge(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}
