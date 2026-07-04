import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../domain/today_models.dart';
import '../../theme/sprout_tokens.dart';
import 'today_controller.dart';
import 'today_widgets.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayControllerProvider);

    return today.when(
      data: (data) => _TodayContent(data: data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'Sprout could not load today.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _TodayContent extends StatefulWidget {
  const _TodayContent({required this.data});

  final TodayData data;

  @override
  State<_TodayContent> createState() => _TodayContentState();
}

class _TodayContentState extends State<_TodayContent> {
  var _questCompleted = false;
  var _showReward = false;

  int get _score => _questCompleted ? 81 : widget.data.health.score;

  void _completeQuest() {
    if (_questCompleted) return;
    setState(() {
      _questCompleted = true;
      _showReward = true;
    });

    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _showReward = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    final children = [
      _TodayHeader(data: widget.data),
      const SizedBox(height: SproutSpacing.md),
      PaydayBanner(data: widget.data),
      const SizedBox(height: SproutSpacing.md),
      FinancialHealthHero(
        score: _score,
        completed: _questCompleted,
        health: widget.data.health,
      ),
      const SizedBox(height: SproutSpacing.md),
      SnapshotGrid(snapshot: widget.data.snapshot),
      const SizedBox(height: SproutSpacing.md),
      DailyQuestCard(
        completed: _questCompleted,
        onComplete: _completeQuest,
      ),
      const SizedBox(height: SproutSpacing.lg),
      MoneyRadar(sources: widget.data.autoCapture),
      const SizedBox(height: SproutSpacing.lg),
      const QuickActionGrid(),
    ];

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              sliver: SliverList.list(
                children: reducedMotion
                    ? children
                    : children.asMap().entries.map((entry) {
                        return entry.value.sproutCardEntrance(
                          delay: Duration(milliseconds: entry.key * 45),
                          beginY: 0.035,
                        );
                      }).toList(),
              ),
            ),
          ],
        ),
        if (_showReward && !reducedMotion) ...[
          const Positioned.fill(child: ConfettiBurst()),
          const Positioned(
            top: 338,
            left: 0,
            right: 0,
            child: XpRewardAnimation(text: '+20 XP'),
          ),
        ],
      ],
    );
  }
}

class _TodayHeader extends StatelessWidget {
  const _TodayHeader({required this.data});

  final TodayData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3D3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: SproutColors.ink.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: SproutMascot(size: 30, mood: SproutMascotMood.happy),
          ),
        ),
        const SizedBox(width: SproutSpacing.sm),
        Expanded(
          child: Text(
            'Salaam, ${data.user.firstName}! 👋',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        StreakPill(days: data.user.dayStreak),
      ],
    );
  }
}

class PaydayBanner extends StatelessWidget {
  const PaydayBanner({required this.data, super.key});

  final TodayData data;

  @override
  Widget build(BuildContext context) {
    return SproutButtonPress(
      onTap: () => SproutBottomSheet.show(
        context,
        title: 'Payday plan',
        rows: [
          SheetInfoRow(
            icon: Icons.event_available_rounded,
            label: 'Expected salary date',
            value: DateFormat('MMM d, yyyy').format(data.salary.nextPayday),
          ),
          const SheetInfoRow(
            icon: Icons.speed_rounded,
            label: 'Limit till salary',
            value: 'PKR 18K',
          ),
          const SheetInfoRow(
            icon: Icons.today_rounded,
            label: 'Safe spend today',
            value: 'PKR 6K',
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF6DB), Color(0xFFFFE6A7)],
          ),
          border: Border.all(color: const Color(0xFFF6DA9E)),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFEBD08A),
              blurRadius: 0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child:
                    Icon(Icons.card_giftcard_rounded, color: SproutColors.gold),
              ),
              const SizedBox(width: SproutSpacing.sm),
              Expanded(
                child: Text(
                  'Payday in ${data.salary.daysUntilSalary} days, woohoo!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SproutMascot(size: 50, mood: SproutMascotMood.peek),
            ],
          ),
        ),
      ),
    );
  }
}

class FinancialHealthHero extends StatelessWidget {
  const FinancialHealthHero({
    required this.score,
    required this.completed,
    required this.health,
    super.key,
  });

  final int score;
  final bool completed;
  final FinancialHealthScore health;

  @override
  Widget build(BuildContext context) {
    return SproutButtonPress(
      onTap: () => SproutBottomSheet.show(
        context,
        title: 'Health score',
        rows: const [
          SheetInfoRow(
            icon: Icons.check_circle_rounded,
            label: 'Healthy',
            value:
                'Emergency buffer, salary timing, and NAV freshness look good.',
          ),
          SheetInfoRow(
            icon: Icons.warning_rounded,
            label: 'Attention',
            value: 'Spending pace and 3 reviews need a quick check.',
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF41C368), Color(0xFF2E9E4C)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: SproutColors.seed.withValues(alpha: 0.23),
              blurRadius: 26,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Financial Health Score',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: SproutSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedScoreRing(score: score, size: 118),
                  const SizedBox(width: SproutSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          completed ? 'Great move! ✨' : 'Great job! 🌱',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: SproutSpacing.xs),
                        Text(
                          completed
                              ? 'Your score climbed. Keep the streak alive.'
                              : 'You\'re on the right track. One quick move keeps you climbing.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.86)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SproutSpacing.md),
              const Row(
                children: [
                  _ScoreLegendDot(
                      color: Color(0xFFFF8A80), label: 'Needs attention'),
                  SizedBox(width: SproutSpacing.md),
                  _ScoreLegendDot(color: SproutColors.gold, label: 'Okay'),
                  SizedBox(width: SproutSpacing.md),
                  _ScoreLegendDot(color: Color(0xFFA7E8B7), label: 'Healthy'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreLegendDot extends StatelessWidget {
  const _ScoreLegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}

class SnapshotGrid extends StatelessWidget {
  const SnapshotGrid({required this.snapshot, super.key});

  final TodaySnapshot snapshot;

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text('Today\'s snapshot',
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                Text(
                  'View all',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: SproutColors.seed),
                ),
              ],
            ),
            const SizedBox(height: SproutSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: SnapshotTile(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Cash',
                    value: 'PKR 168K',
                    color: const Color(0xFFF6FBF4),
                    onTap: () => _showSnapshotSheet(context, 'Cash',
                        'PKR ${snapshot.availableCash} available.'),
                  ),
                ),
                const SizedBox(width: SproutSpacing.md),
                Expanded(
                  child: SnapshotTile(
                    icon: Icons.savings_rounded,
                    label: 'Savings',
                    value: '35%',
                    color: const Color(0xFFF6FBF4),
                    onTap: () => _showSnapshotSheet(context, 'Savings',
                        'Emergency fund is moving toward target.'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SproutSpacing.sm),
            const Divider(color: SproutColors.line),
            SproutButtonPress(
              onTap: () => SproutBottomSheet.show(
                context,
                title: 'Next step',
                rows: const [
                  SheetInfoRow(
                    icon: Icons.savings_rounded,
                    label: 'Quest',
                    value: 'Save PKR 10K to keep your buffer growing.',
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFFFF3D3),
                    child:
                        Icon(Icons.savings_rounded, color: SproutColors.gold),
                  ),
                  const SizedBox(width: SproutSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NEXT STEP',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: SproutColors.muted),
                        ),
                        Text('Save PKR 10K',
                            style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: SproutColors.muted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showSnapshotSheet(BuildContext context, String title, String value) {
  SproutBottomSheet.show(
    context,
    title: title,
    rows: [
      SheetInfoRow(
        icon: Icons.info_rounded,
        label: 'Today',
        value: value,
      ),
    ],
  );
}

class MoneyRadar extends StatelessWidget {
  const MoneyRadar({required this.sources, super.key});

  final List<AutoCaptureSource> sources;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SproutColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: SproutColors.ink.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(SproutSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Money radar',
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: SproutColors.gold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '3 need review',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: const Color(0xFF9A6200)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SproutSpacing.md),
            const Wrap(
              spacing: SproutSpacing.sm,
              runSpacing: SproutSpacing.sm,
              children: [
                SourceStatusPill(label: 'Gmail', connected: true),
                SourceStatusPill(label: 'Meezan', connected: true),
                SourceStatusPill(label: 'Wise', connected: true),
                SourceStatusPill(label: 'Al Meezan', connected: true),
              ],
            ),
            const SizedBox(height: SproutSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => SproutBottomSheet.show(
                  context,
                  title: 'Money radar',
                  rows: [
                    for (final source in sources)
                      SheetInfoRow(
                        icon: source.status == 'needs_review'
                            ? Icons.warning_rounded
                            : Icons.verified_rounded,
                        label: source.label,
                        value: source.detail,
                      ),
                  ],
                ),
                child: const Text('View details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  static const actions = [
    ('Chai', Icons.local_cafe_rounded, Color(0xFFFFF4E4)),
    ('Fuel', Icons.local_gas_station_rounded, Color(0xFFEAF2FF)),
    ('Groceries', Icons.shopping_basket_rounded, Color(0xFFE9F8EF)),
    ('IBFT', Icons.swap_horiz_rounded, Color(0xFFF1EAFE)),
    ('Bill', Icons.receipt_rounded, Color(0xFFFFF4E4)),
    ('Savings', Icons.savings_rounded, Color(0xFFE9F8EF)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick actions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: SproutSpacing.md),
        Wrap(
          spacing: SproutSpacing.sm,
          runSpacing: SproutSpacing.sm,
          children: [
            for (final action in actions)
              QuickActionButton(
                label: action.$1,
                icon: action.$2,
                color: action.$3,
                onTap: () {},
              ),
          ],
        ),
      ],
    );
  }
}
