import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../domain/today_models.dart';
import '../../theme/sprout_strings.dart';
import '../../theme/sprout_tokens.dart';
import '../../theme/sprout_theme.dart';
import '../../widgets/sprout_mascot.dart';
import '../../widgets/sprout_mascot_state.dart';
import '../../widgets/sprout_states.dart';
import '../add/add_screen.dart';
import 'today_controller.dart';
import 'today_widgets.dart';

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
  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    final data = widget.data;
    final wealth = data.wealthSnapshot;

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
      // Header: streak pill, compact.
      _TodayHeader(data: data),
      const SizedBox(height: SproutSpacing.xs),
      // Greeting
      _Greeting(data: data),

      // Mascot — compact, above the number, supporting not dominating.
      const SizedBox(height: SproutSpacing.md),
      _MascotHero(healthScore: data.health.score),

      // HERO: total wealth + movement
      const SizedBox(height: SproutSpacing.md),
      _WealthHero(wealth: wealth),

      // Sprout's read — one-line interpretation in Sprout's voice.
      const SizedBox(height: SproutSpacing.lg),
      _SproutRead(text: data.health.summary),

      // ONE STEP — the goal-relative AI next-step with chunky depth.
      const SizedBox(height: SproutSpacing.xl),
      _OneStep(action: data.health.recommendedAction),

      // Caption
      const SizedBox(height: SproutSpacing.sm),
      Center(
        child: Text(
          '20 seconds · one tap closer',
          style: SproutType.body(
            color: SproutColorScheme.of(context).muted,
            size: 12,
            weight: FontWeight.w500,
            height: 1.2,
          ),
        ),
      ),

      // ── Grey divider band ──
      const SizedBox(height: SproutSpacing.xxl),
      _DividerBand(),

      // ── Below-fold: full detail in text ──

      // Holdings breakdown
      const SizedBox(height: SproutSpacing.xl),
      _HoldingsBreakdown(holdings: wealth.holdings),

      // Why it moved today
      const SizedBox(height: SproutSpacing.xxl),
      _WhyItMoved(interpretation: wealth.interpretation),

      // Goals in full
      const SizedBox(height: SproutSpacing.xxl),
      _GoalsSection(goals: data.goals),

      // Learn later
      if (data.learnThreads.isNotEmpty) ...[
        const SizedBox(height: SproutSpacing.xxl),
        _LearnLater(threads: data.learnThreads),
      ],

      // Provenance / trust footer
      const SizedBox(height: SproutSpacing.xxl),
      _ProvenanceFooter(text: data.provenanceSummary),

      const SizedBox(height: 112),
    ];

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 132),
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
            size: 17,
            weight: FontWeight.w500,
            height: 1.2,
          ),
        ),
        // Streak pill — compact, warm, ambient.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
          decoration: BoxDecoration(
            color: SproutColors.tintGold,
            borderRadius: BorderRadius.circular(SproutRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  color: SproutColors.gold, size: 14),
              const SizedBox(width: 5),
              Text(
                '${data.user.dayStreak}',
                style: SproutType.metricValue(
                  color: SproutColors.goldInk,
                  size: 13,
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
        size: 14,
        weight: FontWeight.w500,
        height: 1.3,
      ),
    );
  }
}

class _MascotHero extends StatelessWidget {
  const _MascotHero({required this.healthScore});

  final int healthScore;

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
            // The mascot — compact, supporting the wealth number, not dominating.
            SproutMascot(
              size: 80,
              state: SproutMascotState.fromHealthScore(healthScore),
              animate: true,
              playOnMount: true,
              playKey: healthScore,
              enableBlink: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _WealthHero extends StatelessWidget {
  const _WealthHero({required this.wealth});

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
              size: 12,
              weight: FontWeight.w500,
              height: 1.2,
            ).copyWith(letterSpacing: 0.6),
          ),
          const SizedBox(height: 3),
          // The hero number — big Inter, heavy.
          Text(
            SproutFormat.compactCurrency(wealth.totalPkr),
            style: SproutType.scoreValue(
              color: colors.ink,
              size: 42,
              weight: FontWeight.w500,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          // Movement chips: today + month-to-date
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MovementChip(
                value: wealth.changeVsYesterday,
                label: 'today',
                isDown: isDown,
              ),
              const SizedBox(width: 8),
              _MovementChip(
                value: wealth.changeMtd,
                label: 'this month',
                isDown: !mtdUp,
              ),
            ],
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
  });

  final int value;
  final String label;
  final bool isDown;

  @override
  Widget build(BuildContext context) {
    final isFlat = value == 0;
    final color = isFlat
        ? SproutColors.muted
        : (isDown ? SproutColors.gold : SproutColors.seed);
    final bgColor = isFlat
        ? SproutColorScheme.of(context).line.withValues(alpha: 0.4)
        : (isDown ? SproutColors.tintGold : SproutColors.tintMint);
    final arrow = isFlat ? '—' : (isDown ? '▼' : '▲');
    final formatted =
        isFlat ? '—' : SproutFormat.compactCurrency(value.abs());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(SproutRadius.pill),
      ),
      child: Text(
        '$arrow $formatted $label',
        style: SproutType.metricValue(
          color: color,
          size: 12,
          weight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SproutRead extends StatelessWidget {
  const _SproutRead({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: SproutColors.tintMint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: SproutType.body(
          color: SproutColors.leaf,
          size: 14,
          weight: FontWeight.w500,
          height: 1.45,
        ),
      ),
    );
  }
}

class _OneStep extends StatelessWidget {
  const _OneStep({required this.action});

  final RecommendedAction action;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final isDark = colors.brightness == Brightness.dark;
    final fill = isDark ? SproutColors.darkSeed : SproutColors.seed;
    final edgeColor = isDark ? const Color(0xFF0E5A35) : const Color(0xFF1A6B3F);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            'YOUR ONE STEP',
            style: SproutType.body(
              color: SproutColors.leaf.withValues(alpha: 0.85),
              size: 11,
              weight: FontWeight.w500,
              height: 1.2,
            ).copyWith(letterSpacing: 0.5),
          ),
        ),
        // Chunky pressable button
        _ChunkyPressButton(
          onTap: () {
            HapticFeedback.mediumImpact();
            SystemSound.play(SystemSoundType.click);
          },
          semanticLabel: action.title,
          fill: fill,
          edgeColor: edgeColor,
          edgeHeight: 5,
          borderRadius: 16,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            child: Text(
              action.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: SproutType.body(
                color: Colors.white,
                size: 15,
                weight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Divider band
// ──────────────────────────────────────────────────────────────

class _DividerBand extends StatelessWidget {
  const _DividerBand();

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Container(
      height: 8,
      color: colors.brightness == Brightness.dark
          ? colors.line.withValues(alpha: 0.3)
          : SproutColors.background,
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Below-fold widgets
// ──────────────────────────────────────────────────────────────

class _HoldingsBreakdown extends StatelessWidget {
  const _HoldingsBreakdown({required this.holdings});

  final List<Holding> holdings;

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
            size: 14,
            weight: FontWeight.w500,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        for (final holding in holdings) ...[
          _HoldingRow(holding: holding),
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
          onTap: () => SproutBottomSheet.show(
            context,
            title: '6-day wealth trend',
            rows: const [
              SheetInfoRow(
                icon: Icons.show_chart_rounded,
                label: 'Trend',
                value: 'Your total wealth over the last 6 days.',
              ),
            ],
          ),
          scale: 0.97,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: colors.line.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.line.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
            child: Center(
              child: Text(
                'View 6-day trend chart →',
                style: SproutType.body(
                  color: SproutColors.sky,
                  size: 13,
                  weight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HoldingRow extends StatelessWidget {
  const _HoldingRow({required this.holding});

  final Holding holding;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final change = holding.changeVsYesterday;
    final isDown = change < 0;
    final isFlat = change == 0;
    final changeColor = isFlat
        ? colors.muted
        : (isDown ? SproutColors.gold : SproutColors.seed);

    return Padding(
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
                    size: 14,
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
                      size: 12,
                      weight: FontWeight.w500,
                      height: 1.2,
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
                  size: 14,
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
                  size: 12,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
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
          : (holding.currency == 'USD'
              ? SproutColors.sky
              : SproutColors.gold),
      HoldingKind.equity => SproutColors.sky,
      HoldingKind.other => SproutColors.muted,
    };

    return SizedBox(
      width: 22,
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _WhyItMoved extends StatelessWidget {
  const _WhyItMoved({required this.interpretation});

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
            size: 14,
            weight: FontWeight.w500,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          interpretation.join(' '),
          style: SproutType.body(
            color: colors.muted,
            size: 13,
            weight: FontWeight.w500,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _GoalsSection extends StatelessWidget {
  const _GoalsSection({required this.goals});

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
            size: 14,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              goal.name,
              style: SproutType.body(
                color: colors.ink,
                size: 13,
                weight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            Text(
              isComplete
                  ? 'complete ✓'
                  : '${_formatCompact(goal.currentAmount)} / ${_formatCompact(goal.targetAmount)}',
              style: SproutType.metricValue(
                color: isComplete ? SproutColors.seed : colors.muted,
                size: 13,
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: colors.line.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(SproutRadius.pill),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: SproutColors.seed,
                borderRadius: BorderRadius.circular(SproutRadius.pill),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          goal.paceNote,
          style: SproutType.body(
            color: isComplete ? colors.muted : SproutColors.seed,
            size: 12,
            weight: FontWeight.w500,
            height: 1.2,
          ),
        ),
      ],
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
            size: 14,
            weight: FontWeight.w500,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        for (final thread in threads)
          SproutButtonPress(
            onTap: () => SproutBottomSheet.show(
              context,
              title: thread.title,
              rows: [
                SheetInfoRow(
                  icon: Icons.lightbulb_rounded,
                  label: 'Summary',
                  value: thread.summary,
                ),
                SheetInfoRow(
                  icon: Icons.menu_book_rounded,
                  label: 'Explanation',
                  value: thread.body,
                ),
              ],
            ),
            scale: 0.97,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: SproutColors.tintLilac,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_rounded,
                      color: SproutColors.lilac, size: 20),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          thread.title,
                          style: SproutType.body(
                            color: SproutColors.lilac,
                            size: 13,
                            weight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          thread.summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SproutType.body(
                            color:
                                SproutColors.lilac.withValues(alpha: 0.85),
                            size: 12,
                            weight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: SproutColors.lilac, size: 20),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ProvenanceFooter extends StatelessWidget {
  const _ProvenanceFooter({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.line.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: SproutType.body(
          color: colors.muted,
          size: 12,
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
        duration: reducedMotion
            ? Duration.zero
            : const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, translateY, 0),
        decoration: BoxDecoration(
          color: widget.edgeColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: AnimatedPadding(
          duration: reducedMotion
              ? Duration.zero
              : const Duration(milliseconds: 90),
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddScreen(),
    );
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
              onTap: () {},
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
