import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../data/goal_store.dart';
import '../../data/balance_privacy_store.dart';
import '../../domain/today_models.dart';
import '../../theme/sprout_strings.dart';
import '../../theme/sprout_tokens.dart';
import '../../theme/sprout_theme.dart';
import '../../widgets/sprout_mascot.dart';
import '../../widgets/sprout_mascot_state.dart';
import '../../widgets/sprout_states.dart';
import '../add/quick_add_sheet.dart';
import '../goals/goal_editor_sheet.dart';
import '../shell/sprout_tab_scroll_view.dart';
import 'today_controller.dart';
import 'today_widgets.dart';

String _formatSigned(int value) {
  if (value == 0) return 'flat';
  final prefix = value < 0 ? 'down' : 'up';
  return '$prefix ${SproutFormat.compactCurrency(value.abs())}';
}

String _formatCompactStatic(int value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(2)}M';
  if (value >= 1000) return '${(value / 1000).round()}k';
  return value.toString();
}

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayControllerProvider);

    return today.when(
      data: (data) => _TodayContent(data: data),
      loading: () => const SproutLoadingView(),
      error: (error, stackTrace) => SproutErrorView(
        message: SproutStrings.couldNotLoadToday,
        onRetry: () => ref.invalidate(todayControllerProvider),
      ),
    );
  }
}

class _TodayContent extends ConsumerStatefulWidget {
  const _TodayContent({required this.data});

  final TodayData data;

  @override
  ConsumerState<_TodayContent> createState() => _TodayContentState();
}

class _TodayContentState extends ConsumerState<_TodayContent> {
  var _showCompletionReward = false;

  void _recordCompletion(RecommendedAction action, bool reducedMotion) {
    if (!reducedMotion) {
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
      setState(() => _showCompletionReward = true);
      Future<void>.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _showCompletionReward = false);
      });
    }

    ref.read(todayQuestCompletedProvider.notifier).complete(action);
  }

  void _startTodayAction(RecommendedAction action, bool reducedMotion) {
    switch (action.completionKind) {
      case 'logCash':
        QuickAddSheet.open(context);
        return;
      case 'setGoal':
        GoalEditorSheet.open(context);
        return;
      case 'contributeToGoal':
        final goal = ref
            .read(goalStoreProvider)
            .where((item) => item.id == action.targetId)
            .firstOrNull;
        if (goal == null) {
          GoalEditorSheet.open(context);
          return;
        }
        GoalEditorSheet.open(
          context,
          goal: goal,
          onContributed: () => _recordCompletion(action, reducedMotion),
        );
        return;
      case 'confirmTransaction':
      case 'moveMoney':
      case 'review':
      case 'rebalance':
      default:
        context.go('/money');
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    final data = widget.data;
    final wealth = data.wealthSnapshot;
    final isZeroData = wealth.totalPkr == 0 &&
        wealth.holdings.every((holding) => holding.valuePkr == 0);
    final completed = ref.watch(todayQuestCompletedProvider);
    final balancesVisible = ref.watch(balancesVisibleProvider);
    ref
        .read(todayQuestCompletedProvider.notifier)
        .load(data.health.recommendedAction);

    if (!balancesVisible) {
      return SproutTabScrollView(
        topPadding: SproutSpacing.lg,
        children: [
          _TodayHeader(data: data),
          const SizedBox(height: SproutSpacing.lg),
          _Greeting(data: data),
          const SizedBox(height: SproutSpacing.xl),
          const SproutMascot(state: SproutMascotState.idle, size: 112),
          const SizedBox(height: SproutSpacing.lg),
          Text(
            'Your balances are hidden',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: SproutSpacing.sm),
          Text(
            'Sprout will keep exact balances, movements, goals, and transaction amounts private until you choose to show them.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: SproutColorScheme.of(context).muted),
          ),
          const SizedBox(height: SproutSpacing.xl),
          FilledButton.icon(
            onPressed: () =>
                ref.read(balancesVisibleProvider.notifier).setVisible(true),
            icon: const Icon(Icons.visibility_rounded),
            label: const Text('Show balances'),
          ),
          const SizedBox(height: SproutSpacing.lg),
          Text(
            data.provenanceSummary,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }

    // ── Above-fold: the calm 20-second glance ──
    // Mascot (compact, supporting), total wealth (hero number), movement chips,
    // Sprout's one-line read, one step. If you close the app here, you got
    // everything essential.
    //
    // ── Grey divider band ──
    // A single visual separator: above it is the glance, below it is depth.
    //
    // ── Below-fold: full detail in text ──
    // Holdings breakdown, why it moved, goals, learn later, provenance footer.
    final children = [
      KeyedSubtree(
        key: const ValueKey('today-part-01-greeting-streak'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TodayHeader(data: data),
            const SizedBox(height: SproutSpacing.xs),
            _Greeting(data: data),
          ],
        ),
      ),

      // ── Briefing cluster (tight grouping) ──
      // Mascot, wealth hero, and Sprout's read belong together
      // as one tight visual cluster — small gaps within, then a standard
      // section gap before the next block.
      const SizedBox(height: SproutSpacing.md),
      const _MascotHero(key: ValueKey('today-part-02-mascot')),

      const SizedBox(height: SproutSpacing.md),
      _WealthHero(
        key: const ValueKey('today-part-03-wealth'),
        wealth: wealth,
      ),

      const SizedBox(height: SproutSpacing.md),
      _SproutRead(
        key: const ValueKey('today-part-05-read'),
        text: data.health.summary,
        detail: data.wealthSnapshot.interpretation.join(' '),
        actionLabel: 'See what I should do',
        onAction: () {
          HapticFeedback.lightImpact();
          final goal = ref
              .read(goalStoreProvider)
              .where((g) => g.status == 'active')
              .firstOrNull;
          if (goal != null) {
            GoalEditorSheet.open(context, goal: goal);
          }
        },
      ),

      // ── Standard section gap → One step ──
      const SizedBox(height: SproutSpacing.xl),
      _OneStep(
        key: const ValueKey('today-part-06-action'),
        action: data.health.recommendedAction,
        completed: completed,
        titleOverride: isZeroData ? 'Add your first cash entry' : null,
        impactOverride: isZeroData ? 'Start with money you can see' : null,
        onComplete: isZeroData
            ? () => QuickAddSheet.open(context)
            : () => _startTodayAction(
                  data.health.recommendedAction,
                  reducedMotion,
                ),
      ),

      // Caption
      if (!isZeroData) ...[
        const SizedBox(height: SproutSpacing.sm),
        Center(
          child: Text(
            '20 seconds · one tap closer',
            style: SproutType.body(
              color: SproutColorScheme.of(context).muted,
              size: SproutTypeScale.s14,
              weight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],

      // ── Standard section gap → What's happening ──
      const SizedBox(height: SproutSpacing.xl),
      _WhatsHappening(
        key: const ValueKey('today-part-07-whats-happening'),
        events: data.wealthEvents,
        goals: data.goals,
        learnThreads: data.learnThreads,
      ),

      const SizedBox(height: SproutSpacing.xl),
      _HoldingsBreakdown(
        key: const ValueKey('today-part-08-holdings'),
        holdings: wealth.holdings,
        events: data.wealthEvents,
      ),

      // ── Quiet door to depth ──
      const SizedBox(height: SproutSpacing.xl),
      const _DividerBand(key: ValueKey('today-part-09-depth-door')),

      const SizedBox(height: SproutSpacing.xl),
      _WhyItMoved(
        key: const ValueKey('today-part-10-why'),
        interpretation: isZeroData
            ? const [
                'Nothing to explain yet — add a cash entry and Sprout starts learning'
              ]
            : wealth.interpretation,
      ),

      const SizedBox(height: SproutSpacing.xl),
      _GoalsSection(
        key: const ValueKey('today-part-11-goals'),
        goals: data.goals,
      ),

      KeyedSubtree(
        key: const ValueKey('today-part-12-learn-later'),
        child: data.learnThreads.isEmpty
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(top: SproutSpacing.xl),
                child: _LearnLater(threads: data.learnThreads),
              ),
      ),

      const SizedBox(height: SproutSpacing.xl),
      _ProvenanceFooter(
        key: const ValueKey('today-part-13-provenance'),
        text: data.provenanceSummary,
      ),

      const SizedBox(height: SproutSpacing.lg),
    ];

    return Stack(
      children: [
        SproutTabScrollView(
          topPadding: 12,
          children: reducedMotion
              ? children
              : children.asMap().entries.map((entry) {
                  return entry.value.sproutCardEntrance(
                    delay: Duration(milliseconds: entry.key * 45),
                    beginY: 0.035,
                  );
                }).toList(),
        ),
        if (_showCompletionReward && !reducedMotion) ...[
          const Positioned.fill(child: ConfettiBurst()),
          Positioned(
            left: 0,
            right: 0,
            bottom: 172,
            child: XpRewardAnimation(
                text: '+${data.health.recommendedAction.xp} XP'),
          ),
        ],
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Above-fold widgets
// ──────────────────────────────────────────────────────────────

class _TodayHeader extends StatelessWidget {
  const _TodayHeader({required this.data});

  final TodayData data;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          SproutStrings.todayTitle,
          style: SproutType.playfulLabel(
            color: colors.ink,
            size: SproutTypeScale.s18,
            weight: FontWeight.w500,
            height: 1.2,
          ),
        ),
        // Streak pill — compact, warm, ambient.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
          decoration: BoxDecoration(
            color: _todayTint(context, SproutColors.tintGold),
            borderRadius: BorderRadius.circular(SproutRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_fire_department_rounded,
                  color: _todayAccent(context, SproutColors.gold), size: 14),
              const SizedBox(width: 5),
              Text(
                '${data.user.dayStreak}',
                style: SproutType.metricValue(
                  color: _todayAccent(context, SproutColors.goldInk),
                  size: SproutTypeScale.s14,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.data});

  final TodayData data;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Text(
      SproutStrings.greeting(data.user.firstName),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: SproutType.body(
        color: colors.muted,
        size: SproutTypeScale.s14,
        weight: FontWeight.w500,
        height: 1.3,
      ),
    );
  }
}

class _MascotHero extends StatelessWidget {
  const _MascotHero({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);

    return Center(
      child: SizedBox(
        width: 92,
        height: 92,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft tinted circle behind the character — not a rectangular card.
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.brightness == Brightness.dark
                    ? SproutColors.darkMint.withValues(alpha: 0.5)
                    : SproutColors.mint.withValues(alpha: 0.7),
              ),
            ),
            // Landing is a calm beat. Celebration and reward motion are reserved
            // for handoff and completed-action states.
            const SproutMascot(
              size: 80,
              state: SproutMascotState.peek,
              animate: false,
              playOnMount: false,
              enableBlink: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _WealthHero extends StatelessWidget {
  const _WealthHero({required this.wealth, super.key});

  final WealthSnapshot wealth;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final isDown = wealth.changeVsYesterday < 0;
    final mtdUp = wealth.changeMtd >= 0;

    return Center(
      child: Column(
        children: [
          // Label
          Text(
            'TOTAL WEALTH',
            style: SproutType.body(
              color: colors.muted,
              size: SproutTypeScale.s14,
              weight: FontWeight.w500,
              height: 1.2,
            ).copyWith(letterSpacing: 0.6),
          ),
          const SizedBox(height: 3),
          // The hero number — counts up from 0 on load. Tappable →
          // wealth breakdown drawer with real data + actions.
          SproutButtonPress(
            onTap: () {
              HapticFeedback.lightImpact();
              SproutActionSheet.show(
                context,
                title: 'Your total wealth',
                rows: [
                  for (final h in wealth.holdings)
                    SheetInfoRow(
                      icon: Icons.account_balance_wallet_rounded,
                      label: h.label,
                      value:
                          '${_formatCompactStatic(h.valuePkr)} · ${h.changeVsYesterday >= 0 ? "+" : "−"}${_formatCompactStatic(h.changeVsYesterday.abs())} today',
                    ),
                  const SheetInfoRow(
                    icon: Icons.verified_rounded,
                    label: 'Status',
                    value:
                        'Estimated from your latest statement and today\'s prices',
                  ),
                ],
                actions: [
                  SheetAction(
                    label: 'Update with a new statement',
                    icon: Icons.upload_file_rounded,
                    onTap: () {
                      Navigator.of(context).pop();
                      QuickAddSheet.openImport(context);
                    },
                  ),
                  SheetAction(
                    label: 'View full breakdown',
                    icon: Icons.account_balance_rounded,
                    onTap: () => context.go('/money'),
                    isPrimary: true,
                  ),
                ],
              );
            },
            scale: 0.99,
            semanticLabel:
                'Total wealth: ${SproutFormat.compactCurrency(wealth.totalPkr)}. Tap for breakdown.',
            child: SproutNumberCounter(
              value: wealth.totalPkr,
              duration: const Duration(milliseconds: 800),
              builder: (context, animatedValue) => Text(
                SproutFormat.compactCurrency(animatedValue.round()),
                style: SproutType.scoreValue(
                  color: colors.ink,
                  size: 42,
                  weight: FontWeight.w500,
                  height: 1.05,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Movement chips: today + month-to-date
          _MovementChipsRow(
            key: const ValueKey('today-part-04-movement'),
            wealth: wealth,
            changeVsYesterday: wealth.changeVsYesterday,
            changeMtd: wealth.changeMtd,
            isDown: isDown,
            mtdUp: mtdUp,
          ),
        ],
      ),
    );
  }
}

class _MovementChipsRow extends StatelessWidget {
  const _MovementChipsRow({
    required this.wealth,
    required this.changeVsYesterday,
    required this.changeMtd,
    required this.isDown,
    required this.mtdUp,
    super.key,
  });

  final WealthSnapshot wealth;
  final int changeVsYesterday;
  final int changeMtd;
  final bool isDown;
  final bool mtdUp;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _MovementChip(
            value: changeVsYesterday,
            label: 'today',
            isDown: isDown,
            reason: wealth.interpretation.join(' '),
            sheetTitle: 'Why today moved',
            sheetLabel: wealth.mainReason,
          ),
          const SizedBox(width: 8),
          _MovementChip(
            value: changeMtd,
            label: 'this month',
            isDown: !mtdUp,
            reason:
                'Month-to-date movement is ${_formatSigned(changeMtd)}. ${wealth.mainReason} is the main driver today, and the full daily context is: ${wealth.interpretation.join(' ')}',
            sheetTitle: 'Why this month moved',
            sheetLabel: 'Month to date',
          ),
        ],
      ),
    );
  }
}

class _MovementChip extends StatelessWidget {
  const _MovementChip({
    required this.value,
    required this.label,
    required this.isDown,
    required this.reason,
    required this.sheetTitle,
    required this.sheetLabel,
  });

  final int value;
  final String label;
  final bool isDown;
  final String reason;
  final String sheetTitle;
  final String sheetLabel;

  @override
  Widget build(BuildContext context) {
    final isFlat = value == 0;
    final colors = SproutColorScheme.of(context);
    final color = isFlat
        ? colors.muted
        : _todayAccent(
            context,
            isDown ? SproutColors.goldInk : SproutColors.seed,
          );
    final bgColor = isFlat
        ? _todaySubtleSurface(context)
        : _todayTint(
            context,
            isDown ? SproutColors.tintGold : SproutColors.tintMint,
          );
    final arrow = isDown ? '▼' : '▲';
    final formatted = SproutFormat.compactCurrency(value.abs());

    return SproutButtonPress(
      onTap: () {
        HapticFeedback.lightImpact();
        SproutBottomSheet.show(
          context,
          title: sheetTitle,
          rows: [
            SheetInfoRow(
              icon: Icons.insights_rounded,
              label: sheetLabel,
              value: reason,
            ),
          ],
        );
      },
      scale: 0.97,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(SproutRadius.pill),
        ),
        child: Text(
          isFlat ? 'No movement yet' : '$arrow $formatted $label',
          style: SproutType.metricValue(
            color: color,
            size: SproutTypeScale.s14,
            weight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SproutRead extends StatelessWidget {
  const _SproutRead({
    required this.text,
    required this.detail,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final String text;
  final String detail;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return SproutButtonPress(
      onTap: () {
        HapticFeedback.lightImpact();
        SproutActionSheet.show(
          context,
          title: 'What Sprout is seeing',
          rows: [
            SheetInfoRow(
                icon: Icons.insights_rounded,
                label: 'Why today moved',
                value: detail),
            SheetInfoRow(
                icon: Icons.flag_rounded,
                label: 'Closest next step',
                value: actionLabel),
          ],
          actions: [
            SheetAction(
                label: actionLabel,
                icon: Icons.play_arrow_rounded,
                onTap: onAction,
                isPrimary: true),
          ],
        );
      },
      scale: 0.98,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: _todayTint(context, SproutColors.tintMint),
          borderRadius: BorderRadius.circular(16),
          border: _todayHairline(context),
        ),
        child: Text(
          text,
          style: SproutType.body(
            color: _todayAccent(context, SproutColors.leaf),
            size: SproutTypeScale.s14,
            weight: FontWeight.w500,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

class _OneStep extends StatelessWidget {
  const _OneStep({
    required this.action,
    required this.completed,
    required this.onComplete,
    this.titleOverride,
    this.impactOverride,
    super.key,
  });

  final RecommendedAction action;
  final bool completed;
  final VoidCallback onComplete;
  final String? titleOverride;
  final String? impactOverride;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final isDark = colors.brightness == Brightness.dark;
    final fill = isDark ? SproutColors.darkSeed : SproutColors.seed;
    final edgeColor = isDark ? SproutColors.darkMint : SproutColors.leaf;
    final actionLabel =
        completed ? 'Done today' : titleOverride ?? action.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            'YOUR ONE STEP',
            style: SproutType.body(
              color: _todayAccent(context, SproutColors.leaf),
              size: SproutTypeScale.s14,
              weight: FontWeight.w500,
              height: 1.2,
            ).copyWith(letterSpacing: 0.5),
          ),
        ),
        // Chunky pressable button
        _ChunkyPressButton(
          onTap: completed ? null : onComplete,
          semanticLabel: actionLabel,
          fill: fill,
          edgeColor: edgeColor,
          edgeHeight: 4,
          borderRadius: 16,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
            child: Column(
              children: [
                Text(
                  actionLabel,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  style: SproutType.body(
                    color: Colors.white,
                    size: SproutTypeScale.s18,
                    weight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  completed
                      ? 'Nice. Your car fund moved closer.'
                      : impactOverride ?? action.impact,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: SproutType.body(
                    color: Colors.white.withValues(alpha: 0.88),
                    size: SproutTypeScale.s14,
                    weight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// What's happening — the heart of the page
// ──────────────────────────────────────────────────────────────

/// A small set of tiles: fund moves, FX gains, goal proximity, learn later.
/// Good and bad shown honestly, read instantly by color and icon.
/// Green = good, amber = watchful, never red alarm. No more than a handful.
class _WhatsHappening extends ConsumerWidget {
  const _WhatsHappening({
    required this.events,
    required this.goals,
    required this.learnThreads,
    super.key,
  });

  final List<WealthEvent> events;
  final List<Goal> goals;
  final List<LearnThread> learnThreads;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = SproutColorScheme.of(context);
    final tiles = <_HappeningTileData>[];

    // One tile per wealth event — the day's movers.
    for (final event in events) {
      tiles.add(_eventToTile(context, event));
    }

    // Goal proximity tile — the closest active goal.
    final activeGoals = goals.where((g) => g.status == 'active').toList();
    if (activeGoals.isNotEmpty) {
      final closest = activeGoals.first;
      tiles.add(_HappeningTileData(
        icon: Icons.flag_rounded,
        title: closest.name,
        value: 'PKR ${_formatCompact(closest.remainingToTarget)}',
        detail: 'left to go',
        color: SproutColors.tintLilac,
        iconColor: SproutColors.lilac,
        severity: 'all_good',
        onTap: () {
          HapticFeedback.lightImpact();
          SproutActionSheet.show(
            context,
            title: closest.name,
            rows: [
              SheetInfoRow(
                  icon: Icons.flag_rounded,
                  label: 'Progress',
                  value:
                      '${SproutFormat.compactCurrency(closest.currentAmount)} saved · ${SproutFormat.compactCurrency(closest.remainingToTarget)} left'),
              SheetInfoRow(
                  icon: Icons.speed_rounded,
                  label: 'Pace',
                  value: closest.paceNote),
            ],
            actions: [
              SheetAction(
                  label: 'Add to this goal',
                  icon: Icons.add_circle_outline_rounded,
                  onTap: () => GoalEditorSheet.open(context, goal: closest),
                  isPrimary: true),
              SheetAction(
                  label: 'Edit goal',
                  icon: Icons.edit_rounded,
                  onTap: () => GoalEditorSheet.open(context, goal: closest)),
              SheetAction(
                  label: 'Complete',
                  icon: Icons.check_circle_outline_rounded,
                  onTap: () =>
                      ref.read(goalStoreProvider.notifier).complete(closest.id),
                  isDestructive: false),
              SheetAction(
                  label: 'Delete',
                  icon: Icons.delete_outline_rounded,
                  onTap: () =>
                      ref.read(goalStoreProvider.notifier).delete(closest.id),
                  isDestructive: true),
            ],
          );
        },
      ));
    }

    // Learn-later tile — if there's a thread to pick up.
    if (learnThreads.isNotEmpty) {
      final thread = learnThreads.first;
      tiles.add(_HappeningTileData(
        icon: Icons.lightbulb_rounded,
        title: 'Learn why',
        value: 'Fund NAVs',
        detail: '2-min read',
        color: SproutColors.tintWarm,
        iconColor: SproutColors.gold,
        severity: 'all_good',
        onTap: () {
          HapticFeedback.lightImpact();
          SproutActionSheet.show(
            context,
            title: thread.title,
            rows: [
              SheetInfoRow(
                  icon: Icons.lightbulb_rounded,
                  label: 'Summary',
                  value: thread.summary),
              SheetInfoRow(
                  icon: Icons.menu_book_rounded,
                  label: 'Explanation',
                  value: thread.body),
            ],
            actions: [
              SheetAction(
                  label: 'Close',
                  icon: Icons.check_circle_outline_rounded,
                  onTap: () => Navigator.of(context).pop(),
                  isPrimary: true),
            ],
          );
        },
      ));
    }

    if (tiles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's happening",
          style: SproutType.playfulLabel(
            color: colors.ink,
            size: SproutTypeScale.s18,
            weight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: SproutSpacing.lg),
        GridView.builder(
          itemCount: tiles.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: SproutSpacing.lg,
            mainAxisSpacing: SproutSpacing.lg,
            childAspectRatio: 1.25,
          ),
          itemBuilder: (context, index) {
            return _HappeningTile(tile: tiles[index]);
          },
        ),
      ],
    );
  }

  _HappeningTileData _eventToTile(BuildContext context, WealthEvent event) {
    final isDown = event.direction == 'down';
    final isFlat = event.direction == 'flat';
    final severity = event.severity;

    // Green for up/all_good, amber for down/heads_up, never red.
    final color = isFlat
        ? SproutColors.tintSky
        : (isDown ? SproutColors.tintGold : SproutColors.tintMint);
    final iconColor = isFlat
        ? SproutColors.muted
        : (isDown ? SproutColors.goldInk : SproutColors.seed);

    final icon = switch (event.kind) {
      WealthEventKind.navMove =>
        isDown ? Icons.trending_down_rounded : Icons.trending_up_rounded,
      WealthEventKind.fxMove => Icons.currency_exchange_rounded,
      WealthEventKind.contribution => Icons.savings_rounded,
      WealthEventKind.withdrawal => Icons.account_balance_wallet_rounded,
      WealthEventKind.bill => Icons.receipt_rounded,
      WealthEventKind.goalMilestone => Icons.flag_rounded,
      WealthEventKind.newsContext => Icons.public_rounded,
    };

    final magnitudeLabel = isFlat
        ? '—'
        : '${isDown ? "−" : "+"}${_formatCompact(event.magnitudePkr.abs())}';

    // Short tile copy: 1-3 word title, ≤5 word description. The full
    // plainWhy lives behind the tap-through, not on the tile.
    final (title, description) = switch (event.kind) {
      WealthEventKind.navMove => (
          isDown ? 'Al Meezan' : 'Funds up',
          isDown ? 'NAV cooled' : 'NAV rose',
        ),
      WealthEventKind.fxMove => (
          isDown ? 'FX down' : 'EUR helped',
          'FX moved your way',
        ),
      WealthEventKind.contribution => (
          'Added',
          'Contribution landed',
        ),
      WealthEventKind.withdrawal => (
          'Withdrawn',
          'Funds moved out',
        ),
      WealthEventKind.bill => (
          'Bill paid',
          'Payment cleared',
        ),
      WealthEventKind.goalMilestone => (
          'Goal milestone',
          'Getting closer',
        ),
      WealthEventKind.newsContext => (
          'Market context',
          'Affects your holdings',
        ),
    };

    return _HappeningTileData(
      icon: icon,
      title: title,
      value: magnitudeLabel,
      detail: description,
      color: color,
      iconColor: iconColor,
      severity: severity,
      onTap: () {
        HapticFeedback.lightImpact();
        SproutActionSheet.show(
          context,
          title: title,
          rows: [
            SheetInfoRow(
                icon: icon, label: 'What happened', value: event.plainWhy),
            SheetInfoRow(
                icon: Icons.verified_rounded,
                label: 'Why this matters',
                value: event.kind == WealthEventKind.fxMove
                    ? 'FX moved the value of your EUR balance.'
                    : 'This is the driver behind today\'s net change.'),
          ],
          actions: [
            SheetAction(
                label: 'See full holding',
                icon: Icons.account_balance_rounded,
                onTap: () => context.go('/money'),
                isPrimary: true),
          ],
        );
      },
    );
  }

  String _formatCompact(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).round()}k';
    }
    return value.toString();
  }
}

class _HappeningTileData {
  const _HappeningTileData({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
    required this.color,
    required this.iconColor,
    required this.severity,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final String detail;
  final Color color;
  final Color iconColor;
  final String severity;
  final VoidCallback onTap;
}

class _HappeningTile extends StatelessWidget {
  const _HappeningTile({required this.tile});

  final _HappeningTileData tile;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final isDark = colors.brightness == Brightness.dark;
    final fill = _todayTint(context, tile.color);
    final iconColor = _todayAccent(context, tile.iconColor);
    final edgeColor = isDark
        ? _todayEdgeColor(context, tile.color)
        : iconColor.withValues(alpha: 0.22);
    final isLongValue = tile.value.length > 8;

    return _ChunkyPressButton(
      onTap: tile.onTap,
      semanticLabel: '${tile.title}. ${tile.detail}',
      fill: fill,
      edgeColor: edgeColor,
      edgeHeight: 3,
      borderRadius: SproutRadius.tile,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Low-opacity icon watermark — subtle depth without dead space.
          // Clipped to the tile bounds so it doesn't trigger layout overflow.
          // Dark-mode opacity is kept very low so text stays fully legible.
          Positioned(
            right: -13,
            bottom: -17,
            child: Icon(
              tile.icon,
              size: 68,
              color: iconColor.withValues(alpha: isDark ? 0.07 : 0.05),
            ),
          ),
          // Content — top-aligned, tight block with even padding.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SproutSpacing.lg,
              vertical: SproutSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: icon (left) + number/delta (right).
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: tile.iconColor.withValues(
                          alpha: isDark ? 0.24 : 0.14,
                        ),
                        borderRadius: BorderRadius.circular(SproutRadius.tile),
                      ),
                      child: Icon(
                        tile.icon,
                        color: iconColor,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: SproutSpacing.sm),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          tile.value,
                          maxLines: 1,
                          style: SproutType.metricValue(
                            color: colors.ink,
                            size: isLongValue
                                ? SproutTypeScale.s14
                                : SproutTypeScale.s18,
                            weight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SproutSpacing.sm),
                // Title — short, bold, one line.
                Text(
                  tile.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SproutType.body(
                    color: colors.ink,
                    size: SproutTypeScale.s14,
                    weight: FontWeight.w800,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 3),
                // One-line description — short, secondary color.
                Text(
                  tile.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SproutType.body(
                    color: colors.muted,
                    size: SproutTypeScale.s14,
                    weight: FontWeight.w500,
                    height: 1.18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Divider band
// ──────────────────────────────────────────────────────────────

class _DividerBand extends StatelessWidget {
  const _DividerBand({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Container(
      height: 8,
      color: colors.brightness == Brightness.dark
          ? colors.surface
          : SproutColors.background,
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Below-fold widgets
// ──────────────────────────────────────────────────────────────

class _HoldingsBreakdown extends StatelessWidget {
  const _HoldingsBreakdown({
    required this.holdings,
    required this.events,
    super.key,
  });

  final List<Holding> holdings;
  final List<WealthEvent> events;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your holdings',
          style: SproutType.playfulLabel(
            color: colors.ink,
            size: SproutTypeScale.s14,
            weight: FontWeight.w500,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        for (final holding in holdings) ...[
          _HoldingRow(
            holding: holding,
            event: _eventForHolding(holding),
          ),
          if (holding.id != holdings.last.id)
            Divider(
              height: 1,
              thickness: 0.5,
              color: colors.line.withValues(alpha: 0.5),
            ),
        ],
        const SizedBox(height: 12),
        // Trend chart — tap-only depth element.
        SproutButtonPress(
          onTap: () {
            HapticFeedback.lightImpact();
            SproutActionSheet.show(
              context,
              title: '6-day wealth trend',
              rows: [
                for (final point in holdings.isEmpty
                    ? const <int>[]
                    : [
                        for (final value in [
                          13667000,
                          13669000,
                          13670000,
                          13672000,
                          13674000,
                          13677000
                        ])
                          value
                      ])
                  SheetInfoRow(
                    icon: Icons.show_chart_rounded,
                    label: 'Point',
                    value: SproutFormat.compactCurrency(point),
                  ),
              ],
              actions: [
                SheetAction(
                    label: 'See full chart',
                    icon: Icons.show_chart_rounded,
                    onTap: () => context.go('/insights'),
                    isPrimary: true),
              ],
            );
          },
          scale: 0.97,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: _todaySubtleSurface(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _todayBorderColor(context),
                width: 0.5,
              ),
            ),
            child: Center(
              child: Text(
                'View 6-day trend chart →',
                style: SproutType.body(
                  color: _todayAccent(context, SproutColors.sky),
                  size: SproutTypeScale.s14,
                  weight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  WealthEvent? _eventForHolding(Holding holding) {
    for (final event in events) {
      if (event.holdingId == holding.id) return event;
    }
    return null;
  }
}

class _HoldingRow extends StatelessWidget {
  const _HoldingRow({
    required this.holding,
    required this.event,
  });

  final Holding holding;
  final WealthEvent? event;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final change = holding.changeVsYesterday;
    final isDown = change < 0;
    final isFlat = change == 0;
    final changeColor = isFlat
        ? colors.muted
        : _todayAccent(
            context,
            isDown ? SproutColors.goldInk : SproutColors.seed,
          );

    return SproutButtonPress(
      onTap: () {
        HapticFeedback.lightImpact();
        SproutActionSheet.show(
          context,
          title: holding.label,
          rows: [
            SheetInfoRow(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Value',
                value: _formatCompact(holding.valuePkr)),
            SheetInfoRow(
                icon: Icons.verified_rounded,
                label: 'Source',
                value: '${holding.priceSource} · ${holding.priceAsOf}'),
            if (holding.fxRate != null)
              SheetInfoRow(
                  icon: Icons.currency_exchange_rounded,
                  label: holding.fxRate!.pair,
                  value:
                      '${holding.fxRate!.value} · ${holding.fxRate!.source} · ${holding.fxRate!.asOf}'),
            SheetInfoRow(
                icon: Icons.insights_rounded,
                label: 'Movement reason',
                value: event?.plainWhy ?? 'Flat today. No movement driver.'),
          ],
          actions: [
            SheetAction(
                label: 'See full holding',
                icon: Icons.account_balance_rounded,
                onTap: () => context.go('/money'),
                isPrimary: true),
          ],
        );
      },
      scale: 0.985,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            // Icon
            _HoldingIcon(holding: holding),
            const SizedBox(width: 12),
            // Label + detail
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    holding.label,
                    style: SproutType.body(
                      color: colors.ink,
                      size: SproutTypeScale.s14,
                      weight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                  if (holding.detail != null)
                    Text(
                      holding.detail!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SproutType.body(
                        color: colors.muted,
                        size: SproutTypeScale.s14,
                        weight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            ),
            // Value + change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCompact(holding.valuePkr),
                  style: SproutType.moneyValue(
                    color: colors.ink,
                    size: SproutTypeScale.s14,
                    weight: FontWeight.w500,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isFlat
                      ? '—'
                      : '${isDown ? "−" : "+"}${_formatCompact(change.abs())}',
                  style: SproutType.metricValue(
                    color: changeColor,
                    size: SproutTypeScale.s14,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCompact(int value) {
    if (value >= 1000000) {
      final m = (value / 1000000).toStringAsFixed(2);
      return '${m}M';
    } else if (value >= 1000) {
      final k = (value / 1000).round();
      return '${k}k';
    }
    return value.toString();
  }
}

class _HoldingIcon extends StatelessWidget {
  const _HoldingIcon({required this.holding});

  final Holding holding;

  @override
  Widget build(BuildContext context) {
    final icon = switch (holding.kind) {
      HoldingKind.mutualFund => Icons.trending_up_rounded,
      HoldingKind.cash => Icons.payments_rounded,
      HoldingKind.equity => Icons.bar_chart_rounded,
      HoldingKind.other => Icons.savings_rounded,
    };
    final color = switch (holding.kind) {
      HoldingKind.mutualFund => SproutColors.seed,
      HoldingKind.cash => holding.currency == 'EUR'
          ? SproutColors.lilac
          : (holding.currency == 'USD' ? SproutColors.sky : SproutColors.gold),
      HoldingKind.equity => SproutColors.sky,
      HoldingKind.other => SproutColors.muted,
    };

    return SizedBox(
      width: 22,
      child: Icon(icon, color: _todayAccent(context, color), size: 18),
    );
  }
}

class _WhyItMoved extends StatelessWidget {
  const _WhyItMoved({required this.interpretation, super.key});

  final List<String> interpretation;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why it moved today',
          style: SproutType.playfulLabel(
            color: colors.ink,
            size: SproutTypeScale.s14,
            weight: FontWeight.w500,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        SproutButtonPress(
          onTap: () {
            HapticFeedback.lightImpact();
            SproutActionSheet.show(
              context,
              title: 'Why it moved today',
              rows: [
                for (final item in interpretation)
                  SheetInfoRow(
                      icon: Icons.insights_rounded,
                      label: 'Driver',
                      value: item),
              ],
              actions: [
                SheetAction(
                    label: 'See 6-day trend',
                    icon: Icons.show_chart_rounded,
                    onTap: () => context.go('/insights'),
                    isPrimary: true),
              ],
            );
          },
          scale: 0.98,
          child: Text(
            interpretation.join(' '),
            style: SproutType.body(
              color: _todayIsDark(context)
                  ? colors.ink.withValues(alpha: 0.78)
                  : colors.muted,
              size: SproutTypeScale.s18,
              weight: FontWeight.w500,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalsSection extends StatelessWidget {
  const _GoalsSection({required this.goals, super.key});

  final List<Goal> goals;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your goals',
          style: SproutType.playfulLabel(
            color: colors.ink,
            size: SproutTypeScale.s14,
            weight: FontWeight.w500,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        for (final goal in goals) ...[
          _GoalRow(goal: goal),
          if (goal.id != goals.last.id) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final isComplete = goal.status == 'complete';
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return SproutButtonPress(
      onTap: () {
        HapticFeedback.lightImpact();
        GoalEditorSheet.open(context, goal: goal);
      },
      scale: 0.98,
      semanticLabel: '${goal.name}. ${goal.paceNote}. Tap to edit.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SproutType.body(
                    color: colors.ink,
                    size: SproutTypeScale.s14,
                    weight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: SproutSpacing.sm),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isComplete
                        ? 'complete ✓'
                        : '${_formatCompact(goal.currentAmount)} / ${_formatCompact(goal.targetAmount)}',
                    style: SproutType.metricValue(
                      color: isComplete
                          ? _todayAccent(context, SproutColors.seed)
                          : colors.muted,
                      size: SproutTypeScale.s14,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar — animates fill from 0 to target on load.
          ClipRRect(
            borderRadius: BorderRadius.circular(SproutRadius.pill),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: _todayTrackColor(context),
                borderRadius: BorderRadius.circular(SproutRadius.pill),
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: progress),
                duration: MediaQuery.of(context).disableAnimations
                    ? Duration.zero
                    : const Duration(milliseconds: 900),
                curve: SproutCurves.progress,
                builder: (context, animatedProgress, _) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: animatedProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _todayAccent(context, SproutColors.seed),
                      borderRadius: BorderRadius.circular(SproutRadius.pill),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            goal.paceNote,
            style: SproutType.body(
              color: isComplete
                  ? colors.muted
                  : _todayAccent(context, SproutColors.seed),
              size: SproutTypeScale.s14,
              weight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCompact(int value) {
    if (value >= 1000000) {
      final m = (value / 1000000).toStringAsFixed(1);
      return '${m}M';
    } else if (value >= 1000) {
      final k = (value / 1000).round();
      return '${k}k';
    }
    return value.toString();
  }
}

class _LearnLater extends StatelessWidget {
  const _LearnLater({required this.threads});

  final List<LearnThread> threads;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learn later',
          style: SproutType.playfulLabel(
            color: colors.ink,
            size: SproutTypeScale.s14,
            weight: FontWeight.w500,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        for (final thread in threads)
          SproutButtonPress(
            onTap: () {
              HapticFeedback.lightImpact();
              SproutActionSheet.show(
                context,
                title: thread.title,
                rows: [
                  SheetInfoRow(
                      icon: Icons.lightbulb_rounded,
                      label: 'Summary',
                      value: thread.summary),
                  SheetInfoRow(
                      icon: Icons.menu_book_rounded,
                      label: 'Explanation',
                      value: thread.body),
                ],
                actions: [
                  SheetAction(
                      label: 'Close',
                      icon: Icons.check_circle_outline_rounded,
                      onTap: () => Navigator.of(context).pop(),
                      isPrimary: true),
                ],
              );
            },
            scale: 0.97,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _todayTint(context, SproutColors.tintLilac),
                borderRadius: BorderRadius.circular(12),
                border: _todayHairline(context),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_rounded,
                      color: _todayAccent(context, SproutColors.lilac),
                      size: 20),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          thread.title,
                          style: SproutType.body(
                            color: _todayAccent(context, SproutColors.lilac),
                            size: SproutTypeScale.s14,
                            weight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        Text(
                          thread.summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SproutType.body(
                            color: _todayAccent(context, SproutColors.lilac)
                                .withValues(alpha: 0.85),
                            size: SproutTypeScale.s14,
                            weight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: _todayAccent(context, SproutColors.lilac),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ProvenanceFooter extends StatelessWidget {
  const _ProvenanceFooter({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _todaySubtleSurface(context),
        borderRadius: BorderRadius.circular(12),
        border: _todayHairline(context),
      ),
      child: Text(
        text,
        style: SproutType.body(
          color: _todayIsDark(context)
              ? colors.ink.withValues(alpha: 0.72)
              : colors.muted,
          size: SproutTypeScale.s14,
          weight: FontWeight.w500,
          height: 1.6,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Reusable: chunky pressable button (Duolingo-style solid depth)
// ──────────────────────────────────────────────────────────────

class _ChunkyPressButton extends StatefulWidget {
  const _ChunkyPressButton({
    required this.child,
    required this.fill,
    required this.edgeColor,
    required this.edgeHeight,
    required this.borderRadius,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final Color fill;
  final Color edgeColor;
  final double edgeHeight;
  final double borderRadius;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  State<_ChunkyPressButton> createState() => _ChunkyPressButtonState();
}

class _ChunkyPressButtonState extends State<_ChunkyPressButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    final isInteractive = widget.onTap != null;
    final pressedEdge = _pressed ? 1.0 : widget.edgeHeight;
    final translateY = _pressed ? widget.edgeHeight - 1.0 : 0.0;

    final content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration:
            reducedMotion ? Duration.zero : const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, translateY, 0),
        decoration: BoxDecoration(
          color: widget.edgeColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: AnimatedPadding(
          duration:
              reducedMotion ? Duration.zero : const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: pressedEdge),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.fill,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: widget.child,
          ),
        ),
      ),
    );

    if (!isInteractive && widget.semanticLabel == null) {
      return content;
    }

    return Semantics(
      button: isInteractive,
      enabled: isInteractive,
      label: widget.semanticLabel,
      child: content,
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Quick Action Grid — used by the app shell's center "+" button
// ──────────────────────────────────────────────────────────────

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  static const actions = [
    ('Chai', Icons.local_cafe_rounded, SproutColors.tintWarm),
    ('Fuel', Icons.local_gas_station_rounded, SproutColors.tintSky),
    ('Groceries', Icons.shopping_basket_rounded, SproutColors.tintMint),
    ('IBFT', Icons.swap_horiz_rounded, SproutColors.tintLilac),
    ('Bill', Icons.receipt_rounded, SproutColors.tintWarm),
    ('Savings', Icons.savings_rounded, SproutColors.tintMint),
  ];

  /// Opens the Quick Add sheet from the center "+" button.
  static void openQuickAdd(BuildContext context) {
    QuickAddSheet.open(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(SproutStrings.quickActions,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: SproutSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 112,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _QuickActionButton(
              label: action.$1,
              icon: action.$2,
              color: action.$3,
              onTap: () => QuickAddSheet.open(context),
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SproutButtonPress(
      onTap: onTap,
      scale: 0.93,
      semanticLabel: label,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: SproutColors.leaf, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}

bool _todayIsDark(BuildContext context) {
  return SproutColorScheme.of(context).brightness == Brightness.dark;
}

Color _todayTint(BuildContext context, Color lightTint) {
  if (!_todayIsDark(context)) return lightTint;
  // Dark-mode tints are committed, not washed-out. Each tint gets a
  // dark variant at enough alpha to read as a colored surface (not flat
  // black), while keeping text (darkInk, near-white) fully legible.
  if (lightTint == SproutColors.tintMint) {
    return SproutColors.darkMint.withValues(alpha: 0.82);
  }
  if (lightTint == SproutColors.tintGold ||
      lightTint == SproutColors.tintWarm) {
    return SproutColors.darkGold.withValues(alpha: 0.14);
  }
  if (lightTint == SproutColors.tintSky) {
    return SproutColors.darkSky.withValues(alpha: 0.14);
  }
  if (lightTint == SproutColors.tintLilac) {
    return SproutColors.darkLilac.withValues(alpha: 0.16);
  }
  return SproutColorScheme.of(context).surface;
}

Color _todayAccent(BuildContext context, Color lightAccent) {
  if (!_todayIsDark(context)) return lightAccent;
  if (lightAccent == SproutColors.seed || lightAccent == SproutColors.leaf) {
    return SproutColors.darkSeed;
  }
  if (lightAccent == SproutColors.gold || lightAccent == SproutColors.goldInk) {
    return SproutColors.darkGold;
  }
  if (lightAccent == SproutColors.sky) return SproutColors.darkSky;
  if (lightAccent == SproutColors.lilac) return SproutColors.darkLilac;
  if (lightAccent == SproutColors.muted) {
    return SproutColorScheme.of(context).muted;
  }
  return lightAccent;
}

Color _todayEdgeColor(BuildContext context, Color lightTint) {
  if (lightTint == SproutColors.tintMint) {
    return SproutColors.darkSeed.withValues(alpha: 0.42);
  }
  if (lightTint == SproutColors.tintGold ||
      lightTint == SproutColors.tintWarm) {
    return SproutColors.darkGold.withValues(alpha: 0.38);
  }
  if (lightTint == SproutColors.tintSky) {
    return SproutColors.darkSky.withValues(alpha: 0.35);
  }
  if (lightTint == SproutColors.tintLilac) {
    return SproutColors.darkLilac.withValues(alpha: 0.36);
  }
  return SproutColorScheme.of(context).line;
}

Color _todaySubtleSurface(BuildContext context) {
  final colors = SproutColorScheme.of(context);
  return _todayIsDark(context)
      ? colors.surface
      : colors.line.withValues(alpha: 0.2);
}

Color _todayBorderColor(BuildContext context) {
  final colors = SproutColorScheme.of(context);
  return _todayIsDark(context)
      ? colors.line.withValues(alpha: 0.95)
      : colors.line.withValues(alpha: 0.45);
}

Color _todayTrackColor(BuildContext context) {
  final colors = SproutColorScheme.of(context);
  return _todayIsDark(context)
      ? colors.line.withValues(alpha: 0.85)
      : colors.line.withValues(alpha: 0.4);
}

BoxBorder? _todayHairline(BuildContext context) {
  return _todayIsDark(context)
      ? Border.all(color: _todayBorderColor(context), width: 0.7)
      : null;
}
