import 'package:flutter/material.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../theme/sprout_tokens.dart';
import '../../widgets/sprout_page.dart';
import '../today/today_widgets.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  static const _categories = [
    _BudgetCategory('Groceries', Icons.shopping_basket_rounded, '32K', 0.80,
        SproutColors.seed),
    _BudgetCategory(
        'Bills', Icons.receipt_long_rounded, '56K', 0.93, SproutColors.gold),
    _BudgetCategory('Transport', Icons.directions_car_rounded, '12K', 0.60,
        SproutColors.sky),
    _BudgetCategory(
        'Dining', Icons.local_cafe_rounded, '18K', 0.72, SproutColors.lilac),
    _BudgetCategory(
        'Shopping', Icons.shopping_bag_rounded, '9K', 0.45, SproutColors.seed),
    _BudgetCategory(
        'Others', Icons.more_horiz_rounded, '5.8K', 0.39, SproutColors.muted),
  ];

  @override
  Widget build(BuildContext context) {
    return SproutPage(
      title: 'Budget',
      subtitle: 'A simple pace check, not a spreadsheet.',
      trailing: _RoundAction(
        icon: Icons.calendar_month_rounded,
        onTap: () => SproutBottomSheet.show(
          context,
          title: 'Budget month',
          rows: const [
            SheetInfoRow(
              icon: Icons.calendar_month_rounded,
              label: 'Current month',
              value: 'July 2026',
            ),
            SheetInfoRow(
              icon: Icons.speed_rounded,
              label: 'Weekly pace',
              value: '42% spent this week',
            ),
          ],
        ),
      ),
      children: const [
        _BudgetHero(),
        SizedBox(height: SproutSpacing.md),
        _WeeklyPaceCard(),
        SizedBox(height: SproutSpacing.md),
        _CategoryBoard(categories: _categories),
        SizedBox(height: SproutSpacing.md),
        _BudgetQuest(),
      ],
    );
  }
}

class _BudgetHero extends StatelessWidget {
  const _BudgetHero();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF41C368), Color(0xFF2E9E4C)]),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: SproutColors.seed.withValues(alpha: 0.24),
              blurRadius: 26,
              offset: const Offset(0, 16)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Remaining Budget',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('PKR 83.5K',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: Colors.white, fontSize: 38)),
                  Text('Good pace for July',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.84))),
                ],
              ),
            ),
            const SproutMascot(size: 78, mood: SproutMascotMood.thumbsUp),
          ],
        ),
      ),
    );
  }
}

class _WeeklyPaceCard extends StatelessWidget {
  const _WeeklyPaceCard();

  @override
  Widget build(BuildContext context) {
    return _RaisedPanel(
      child: Row(
        children: [
          const SizedBox(
            width: 82,
            height: 82,
            child: SproutProgressRing(
              value: 0.42,
              color: SproutColors.seed,
              backgroundColor: Color(0xFFFFE9BC),
              child: Icon(Icons.speed_rounded, color: SproutColors.leaf),
            ),
          ),
          const SizedBox(width: SproutSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This week',
                    style: Theme.of(context).textTheme.titleLarge),
                Text('42% used',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: SproutColors.seed)),
                Text('You are pacing well.',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBoard extends StatelessWidget {
  const _CategoryBoard({required this.categories});

  final List<_BudgetCategory> categories;

  @override
  Widget build(BuildContext context) {
    return _RaisedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Category health',
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              const SourceStatusPill(label: '6 live', connected: true),
            ],
          ),
          const SizedBox(height: SproutSpacing.md),
          Wrap(
            spacing: SproutSpacing.sm,
            runSpacing: SproutSpacing.sm,
            children: [
              for (final category in categories)
                _CategoryPill(
                  category: category,
                  onTap: () => SproutBottomSheet.show(
                    context,
                    title: category.name,
                    rows: [
                      SheetInfoRow(
                          icon: category.icon,
                          label: 'Spent',
                          value: 'PKR ${category.spent}'),
                      SheetInfoRow(
                          icon: Icons.track_changes_rounded,
                          label: 'Status',
                          value: category.progress > .9
                              ? 'Careful'
                              : category.progress > .7
                                  ? 'Watch'
                                  : 'Healthy'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.category, required this.onTap});

  final _BudgetCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 154,
      child: SproutButtonPress(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: category.color.withValues(alpha: 0.16)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(category.icon, color: category.color),
                const SizedBox(height: 8),
                Text(category.spent,
                    style: Theme.of(context).textTheme.titleLarge),
                Text(category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                SproutProgressBar(
                    value: category.progress, color: category.color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BudgetQuest extends StatelessWidget {
  const _BudgetQuest();

  @override
  Widget build(BuildContext context) {
    return _MiniQuestCard(
      color: SproutColors.seed,
      icon: Icons.shopping_basket_rounded,
      label: 'BUDGET QUEST',
      title: 'Keep groceries under 40K',
      reward: '+15 XP',
      onTap: () => SproutBottomSheet.show(
        context,
        title: 'Budget quest',
        rows: const [
          SheetInfoRow(
              icon: Icons.shopping_basket_rounded,
              label: 'Move',
              value: 'Keep groceries under PKR 40K.'),
          SheetInfoRow(
              icon: Icons.verified_user_rounded,
              label: 'Why',
              value: 'This keeps your weekly pace healthy.'),
        ],
      ),
    );
  }
}

class _BudgetCategory {
  const _BudgetCategory(
      this.name, this.icon, this.spent, this.progress, this.color);

  final String name;
  final IconData icon;
  final String spent;
  final double progress;
  final Color color;
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
              offset: const Offset(0, 14))
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _MiniQuestCard extends StatelessWidget {
  const _MiniQuestCard(
      {required this.color,
      required this.icon,
      required this.label,
      required this.title,
      required this.reward,
      required this.onTap});

  final Color color;
  final IconData icon;
  final String label;
  final String title;
  final String reward;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SproutButtonPress(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [color, Color.lerp(color, Colors.black, .16)!]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Color.lerp(color, Colors.black, .18)!,
                blurRadius: 0,
                offset: const Offset(0, 5))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white.withValues(alpha: .2),
                  child: Icon(icon, color: Colors.white)),
              const SizedBox(width: SproutSpacing.md),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                  color: Colors.white.withValues(alpha: .9),
                                  letterSpacing: .4)),
                      Text(title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white)),
                    ]),
              ),
              _RewardPill(text: reward),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardPill extends StatelessWidget {
  const _RewardPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .22),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: .35))),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: Colors.white)),
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
      child: CircleAvatar(
          radius: 22,
          backgroundColor: SproutColors.surface,
          child: Icon(icon, color: SproutColors.leaf)),
    );
  }
}
