import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../domain/today_models.dart';
import '../../theme/sprout_strings.dart';
import '../../theme/sprout_tokens.dart';
import '../../theme/sprout_theme.dart';
import '../../widgets/sprout_mascot.dart';
import '../../widgets/sprout_mascot_state.dart';
import '../../widgets/sprout_states.dart';
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
  var _showReward = false;

  int get _score {
    return ref.watch(todayQuestCompletedProvider)
        ? 81
        : widget.data.health.score;
  }

  void _completeQuest() {
    if (ref.read(todayQuestCompletedProvider)) return;
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
    setState(() {
      _showReward = true;
    });
    ref.read(todayQuestCompletedProvider.notifier).state = true;

    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() => _showReward = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    final questCompleted = ref.watch(todayQuestCompletedProvider);
    final reviewCount = widget.data.snapshot.unconfirmedTransactions;
    final children = [
      _TodayStatusRow(data: widget.data, questCompleted: questCompleted),
      const SizedBox(height: 18),
      _TodayGreeting(data: widget.data),
      const SizedBox(height: 18),
      _QuestHero(
        completed: questCompleted,
        onComplete: _completeQuest,
      ),
      const SizedBox(height: 18),
      _GardenHealthCard(
        score: _score,
        completed: questCompleted,
        health: widget.data.health,
        reviewCount: reviewCount,
      ),
      const SizedBox(height: 24),
      _YourMoneyInventory(
        snapshot: widget.data.snapshot,
      ),
      const SizedBox(height: 24),
      _MoneyRadarStrip(
        sources: widget.data.autoCapture,
        reviewCount: reviewCount,
      ),
      const SizedBox(height: 24),
      const QuickActionGrid(),
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
        if (_showReward && !reducedMotion) ...[
          const Positioned.fill(
            child: ExcludeSemantics(child: ConfettiBurst()),
          ),
          const Positioned.fill(
            child: ExcludeSemantics(
              child: Align(
                alignment: Alignment(0, -0.04),
                child: XpRewardAnimation(text: '+20 XP'),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TodayStatusRow extends StatelessWidget {
  const _TodayStatusRow({
    required this.data,
    required this.questCompleted,
  });

  final TodayData data;
  final bool questCompleted;

  @override
  Widget build(BuildContext context) {
    final streak = data.user.dayStreak + (questCompleted ? 1 : 0);
    final colors = SproutColorScheme.of(context);

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: SproutColors.tintGold,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: SproutColors.gold.withValues(alpha: 0.22),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: SproutMascot(
              size: 34,
              state: SproutMascotState.happy,
              enableBlink: false,
            ),
          ),
        ),
        const SizedBox(width: SproutSpacing.sm),
        Flexible(
          fit: FlexFit.tight,
          child: _WalletMetric(
            label: 'Wallet',
            value: SproutFormat.compactCurrency(data.snapshot.availableCash),
            color: colors.ink,
          ),
        ),
        const SizedBox(width: SproutSpacing.sm),
        _StatusMetric(
          icon: Icons.local_fire_department_rounded,
          value: '$streak',
          color: SproutColors.gold,
          pulse: questCompleted,
          label: 'Streak',
        ),
        const SizedBox(width: 5),
        _StatusMetric(
          icon: Icons.star_rounded,
          value: '${data.user.xp + (questCompleted ? 20 : 0)}',
          color: SproutColors.sky,
          label: 'XP',
        ),
        const SizedBox(width: 5),
        SproutButtonPress(
          onTap: () => context.go('/money'),
          semanticLabel: 'Review transactions',
          child: _StatusMetric(
            icon: Icons.circle_rounded,
            value: '${data.snapshot.unconfirmedTransactions}',
            color: SproutColors.gold,
            label: 'Review',
          ),
        ),
      ],
    );
  }
}

class _StatusMetric extends StatelessWidget {
  const _StatusMetric({
    required this.icon,
    required this.value,
    required this.color,
    required this.label,
    this.pulse = false,
  });

  final IconData icon;
  final String value;
  final Color color;
  final String label;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final metric = Semantics(
      label: '$label $value',
      child: SizedBox(
        width: 42,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 2),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: SproutType.metricValue(
                        color: SproutColorScheme.of(context).ink,
                        size: 13,
                        weight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    color: SproutColorScheme.of(context).muted,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      ),
    );

    if (!pulse || MediaQuery.of(context).disableAnimations) return metric;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: metric,
    );
  }
}

class _WalletMetric extends StatelessWidget {
  const _WalletMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SproutType.moneyValue(
              color: color,
              size: 15,
              weight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 8,
                  color: SproutColorScheme.of(context).muted,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _TodayGreeting extends StatelessWidget {
  const _TodayGreeting({required this.data});

  final TodayData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          SproutStrings.greeting(data.user.firstName),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 24,
              ),
        ),
        const SizedBox(height: 3),
        Text(
          'Calm today.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: SproutColorScheme.of(context).muted,
              ),
        ),
      ],
    );
  }
}

class _QuestHero extends StatefulWidget {
  const _QuestHero({
    required this.completed,
    required this.onComplete,
  });

  final bool completed;
  final VoidCallback onComplete;

  @override
  State<_QuestHero> createState() => _QuestHeroState();
}

class _QuestHeroState extends State<_QuestHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _appearController;

  @override
  void initState() {
    super.initState();
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _appearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    final hero = SizedBox(
      height: 306,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 112,
            left: 0,
            right: 0,
            child: _QuestCard(
              completed: widget.completed,
              onComplete: widget.completed ? null : widget.onComplete,
            ),
          ),
          Positioned(
            top: 0,
            left: 8,
            child: AnimatedSwitcher(
              duration: reducedMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 320),
              child: Transform.rotate(
                angle: widget.completed ? -0.07 : 0.04,
                child: _MascotStage(
                  key: ValueKey(widget.completed),
                  state: widget.completed
                      ? SproutMascotState.celebrate
                      : SproutMascotState.pointing,
                  playKey: widget.completed,
                ),
              ),
            ),
          ),
          Positioned(
            top: 36,
            left: 132,
            right: 0,
            child: _MascotSpeechBubble(
              text: widget.completed ? "Done today." : "Tiny move. Big future.",
            ),
          ),
        ],
      ),
    );

    if (reducedMotion) return hero;
    return AnimatedBuilder(
      animation: _appearController,
      builder: (context, child) {
        final t = Curves.easeOutBack.transform(_appearController.value);
        return Opacity(
          opacity: _appearController.value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, 22 * (1 - t)),
            child: Transform.scale(scale: 0.96 + 0.04 * t, child: child),
          ),
        );
      },
      child: hero,
    );
  }
}

class _MascotStage extends StatelessWidget {
  const _MascotStage({
    required this.state,
    required this.playKey,
    super.key,
  });

  final SproutMascotState state;
  final Object playKey;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: 112,
        height: 112,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // Matches the neutral background baked into the temporary MP4/PNG
          // mascot assets so the character reads as embedded, not pasted.
          color: const Color(0xFFE8E8E2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: SproutColors.ink.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SproutMascot(
          size: 96,
          state: state,
          animate: true,
          playOnMount: true,
          playKey: playKey,
          enableBlink: false,
        ),
      ),
    );
  }
}

class _MascotSpeechBubble extends StatelessWidget {
  const _MascotSpeechBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -5,
          top: 18,
          child: Transform.rotate(
            angle: 0.75,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  left: BorderSide(
                    color: SproutColors.line.withValues(alpha: 0.7),
                  ),
                  bottom: BorderSide(
                    color: SproutColors.line.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: SproutColors.line.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: SproutColors.ink.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: SproutColors.ink,
                    fontSize: 17,
                    height: 1.15,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestCard extends StatelessWidget {
  const _QuestCard({
    required this.completed,
    required this.onComplete,
  });

  final bool completed;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final bottomColor =
        completed ? const Color(0xFFB87500) : const Color(0xFF148A35);
    final faceColor =
        completed ? const Color(0xFFFFC83D) : const Color(0xFF54D000);
    final outlineColor =
        completed ? const Color(0xFFD89000) : const Color(0xFF1FA340);
    return SproutButtonPress(
      onTap: onComplete,
      scale: 0.94,
      semanticLabel:
          completed ? SproutStrings.questComplete : SproutStrings.plantPkr10k,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bottomColor,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: faceColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: outlineColor, width: 3),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "TODAY'S QUEST",
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 14,
                                    letterSpacing: 0.6,
                                  ),
                        ),
                      ),
                      _RewardCapsule(text: '+20 XP', completed: completed),
                      const SizedBox(width: 8),
                      _RewardCapsule(text: '+3 Health', completed: completed),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: _QuestTitle(completed: completed),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.65),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: bottomColor,
                          blurRadius: 0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 11,
                      ),
                      child: Center(
                        child: Text(
                          completed ? 'Planted' : 'Plant it now',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: SproutColors.seed,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardCapsule extends StatelessWidget {
  const _RewardCapsule({required this.text, required this.completed});

  final String text;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    final badge = DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF15913A),
        borderRadius: BorderRadius.circular(SproutRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(SproutRadius.pill),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            child: Text(
              text,
              style: SproutType.metricValue(
                color: Colors.white,
                size: 12,
                weight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );

    if (!completed || reducedMotion) return badge;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1),
      duration: const Duration(milliseconds: 480),
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: badge,
    );
  }
}

class _QuestTitle extends StatelessWidget {
  const _QuestTitle({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return Text(
        SproutStrings.questPlanted,
        maxLines: 1,
        style: SproutType.playfulTitle(
          color: Colors.white,
          size: 28,
          weight: FontWeight.w800,
          height: 1.02,
        ),
      );
    }

    return Semantics(
      label: SproutStrings.plantPkr10k,
      child: ExcludeSemantics(
        child: RichText(
          maxLines: 1,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Plant ',
                style: SproutType.playfulTitle(
                  color: Colors.white,
                  size: 28,
                  weight: FontWeight.w800,
                  height: 1.02,
                ),
              ),
              TextSpan(
                text: 'PKR 10K',
                style: SproutType.moneyValue(
                  color: Colors.white,
                  size: 27,
                  weight: FontWeight.w800,
                  height: 1.02,
                ),
              ),
              TextSpan(
                text: ' 🌱',
                style: SproutType.playfulTitle(
                  color: Colors.white,
                  size: 28,
                  weight: FontWeight.w800,
                  height: 1.02,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GardenHealthCard extends StatelessWidget {
  const _GardenHealthCard({
    required this.score,
    required this.completed,
    required this.health,
    required this.reviewCount,
  });

  final int score;
  final bool completed;
  final FinancialHealthScore health;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return SproutButtonPress(
      semanticLabel: 'Garden Health: $score. Calm today. Review $reviewCount.',
      onTap: () => SproutBottomSheet.show(
        context,
        title: 'Garden Health',
        rows: [
          for (final factor in health.positiveFactors)
            SheetInfoRow(
              icon: Icons.check_circle_rounded,
              label: 'Working',
              value: factor,
            ),
          for (final factor in health.attentionFactors)
            SheetInfoRow(
              icon: Icons.warning_rounded,
              label: 'Review',
              value: factor,
            ),
          SheetInfoRow(
            icon: Icons.local_florist_rounded,
            label: 'Tiny next step',
            value: health.recommendedAction.title,
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.brightness == Brightness.dark
              ? const Color(0xFF233128)
              : const Color(0xFFC9D9CF),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: colors.line, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  AnimatedScoreRing(
                    score: score,
                    size: 82,
                    foregroundColor: colors.ink,
                    trackColor: colors.line.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: SproutSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Garden Health',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 21,
                                  ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          completed
                              ? 'Health +3. Nice.'
                              : 'Calm today. $reviewCount reviews.',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: colors.muted,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: SproutColors.seed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _YourMoneyInventory extends StatefulWidget {
  const _YourMoneyInventory({required this.snapshot});

  final TodaySnapshot snapshot;

  @override
  State<_YourMoneyInventory> createState() => _YourMoneyInventoryState();
}

class _YourMoneyInventoryState extends State<_YourMoneyInventory> {
  var _balancesVisible = true;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Your money',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            SproutButtonPress(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _balancesVisible = !_balancesVisible);
              },
              scale: 0.94,
              semanticLabel: _balancesVisible
                  ? SproutStrings.hideBalances
                  : SproutStrings.showBalances,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: colors.mint,
                  borderRadius: BorderRadius.circular(SproutRadius.pill),
                ),
                child: Icon(
                  _balancesVisible
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  size: 18,
                  color: SproutColors.seed,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: SproutSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _InventoryTile(
                title: 'Ready Wallet',
                value: _balancesVisible
                    ? SproutFormat.compactCurrency(
                        widget.snapshot.availableCash)
                    : SproutStrings.hiddenBalance,
                hint: 'Safe to spend',
                icon: Icons.account_balance_wallet_rounded,
                color: SproutColors.seed,
                onTap: () => _showStatusSheet(
                  context,
                  'Ready Wallet',
                  '${SproutFormat.currency(widget.snapshot.availableCash)} ready to use.',
                ),
              ),
              const SizedBox(width: 10),
              _InventoryTile(
                title: 'Savings Vault',
                value:
                    _balancesVisible ? 'PKR 5.2M' : SproutStrings.hiddenBalance,
                hint: 'Strong buffer',
                icon: Icons.savings_rounded,
                color: SproutColors.sky,
                onTap: () => _showStatusSheet(
                  context,
                  'Savings Vault',
                  'Your savings and investments are holding a strong buffer.',
                ),
              ),
              const SizedBox(width: 10),
              _InventoryTile(
                title: 'Car Goal',
                value: _balancesVisible ? '35%' : SproutStrings.hiddenBalance,
                hint: 'On track',
                icon: Icons.flag_rounded,
                color: SproutColors.lilac,
                onTap: () => _showStatusSheet(
                  context,
                  'Car Goal',
                  'Car fund is 35% complete.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InventoryTile extends StatelessWidget {
  const _InventoryTile({
    required this.title,
    required this.value,
    required this.hint,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String value;
  final String hint;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: SproutButtonPress(
        onTap: onTap,
        scale: 0.91,
        semanticLabel: '$title. $value. $hint.',
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _rimColor(color),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _tileFaceColor(color),
                borderRadius: BorderRadius.circular(22),
                border:
                    Border.all(color: color.withValues(alpha: 0.5), width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 12, 11, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: color, size: 25),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        maxLines: 1,
                        style: SproutType.moneyValue(
                          color: SproutColorScheme.of(context).ink,
                          size: 20,
                          weight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _tileFaceColor(Color color) {
    if (color == SproutColors.seed) return const Color(0xFFDDFBE8);
    if (color == SproutColors.sky) return const Color(0xFFE3F0FF);
    if (color == SproutColors.lilac) return const Color(0xFFEDE7FF);
    return color.withValues(alpha: 0.12);
  }

  Color _rimColor(Color color) {
    if (color == SproutColors.seed) return const Color(0xFF95D7AD);
    if (color == SproutColors.sky) return const Color(0xFF9CC3F6);
    if (color == SproutColors.lilac) return const Color(0xFFB6A6FF);
    return color.withValues(alpha: 0.35);
  }
}

class _MoneyRadarStrip extends StatelessWidget {
  const _MoneyRadarStrip({
    required this.sources,
    required this.reviewCount,
  });

  final List<AutoCaptureSource> sources;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final visibleSources = sources
        .where((source) => source.status != 'needs_review')
        .take(4)
        .toList();
    return SproutButtonPress(
      onTap: () => SproutBottomSheet.show(
        context,
        title: SproutStrings.moneyRadar,
        rows: [
          for (final source in sources)
            source.status == 'needs_review'
                ? _ReviewSheetInfoRow(
                    icon: Icons.warning_rounded,
                    label: source.label,
                    value: source.detail,
                    onTap: () => context.go('/money'),
                  )
                : SheetInfoRow(
                    icon: Icons.verified_rounded,
                    label: source.label,
                    value: source.detail,
                  ),
        ],
      ),
      scale: 0.98,
      semanticLabel: 'Money radar. $reviewCount need review.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  SproutStrings.moneyRadar,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: SproutColors.tintGold,
                  borderRadius: BorderRadius.circular(SproutRadius.pill),
                ),
                child: Text(
                  SproutStrings.needReview(reviewCount),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: SproutColors.goldInk,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SproutSpacing.sm),
          Wrap(
            spacing: SproutSpacing.sm,
            runSpacing: SproutSpacing.sm,
            children: [
              for (final source in visibleSources)
                SourceStatusPill(
                  label: source.label
                      .replaceAll(' connected', '')
                      .replaceAll(' alerts detected', '')
                      .replaceAll(' balance imported', '')
                      .replaceAll(' NAV updated', ''),
                  connected: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A [SheetInfoRow] whose "Tap to review" value is backed by a real action:
/// tapping it navigates to the Money tab. Visuals stay identical to a plain
/// info row; only the tap + semantics are added.
class _ReviewSheetInfoRow extends SheetInfoRow {
  const _ReviewSheetInfoRow({
    required super.icon,
    required super.label,
    required super.value,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SproutButtonPress(
      onTap: onTap,
      semanticLabel: 'Review transactions',
      child: super.build(context),
    );
  }
}

class PaydayBanner extends StatelessWidget {
  const PaydayBanner({required this.data, super.key});

  final TodayData data;

  @override
  Widget build(BuildContext context) {
    return SproutButtonPress(
      semanticLabel:
          'Payday in ${data.salary.daysUntilSalary} days. Tap for payday plan.',
      onTap: () => SproutBottomSheet.show(
        context,
        title: SproutStrings.paydayPlan,
        rows: [
          SheetInfoRow(
            icon: Icons.event_available_rounded,
            label: SproutStrings.expectedSalaryDate,
            value: SproutFormat.date(data.salary.nextPayday),
          ),
          const SheetInfoRow(
            icon: Icons.speed_rounded,
            label: SproutStrings.limitTillSalary,
            value: 'PKR 18K',
          ),
          const SheetInfoRow(
            icon: Icons.today_rounded,
            label: SproutStrings.safeSpendToday,
            value: 'PKR 6K',
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: SproutGradients.gold,
          border: Border.all(color: const Color(0xFFF6DA9E)),
          borderRadius: BorderRadius.circular(SproutRadius.card),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SproutStrings.paydayIn(data.salary.daysUntilSalary),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      SproutStrings.paydayAlmostThere,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SproutMascot(size: 52, state: SproutMascotState.celebrate),
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
      semanticLabel:
          'Financial Health Score: $score out of 100. Tap for details.',
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
          gradient: SproutGradients.green,
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
                SproutStrings.financialHealthScore,
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
                          SproutStrings.lookingGood,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: SproutSpacing.xs),
                        Text(
                          completed
                              ? SproutStrings.scoreClimbed
                              : SproutStrings.safeTodayReview,
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
              const Wrap(
                spacing: SproutSpacing.md,
                runSpacing: SproutSpacing.xs,
                children: [
                  _ScoreLegendDot(
                      color: SproutColors.attention,
                      label: SproutStrings.needsAttention),
                  _ScoreLegendDot(
                      color: SproutColors.gold, label: SproutStrings.okay),
                  _ScoreLegendDot(
                      color: SproutColors.healthy,
                      label: SproutStrings.healthy),
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

class MoneyStatusBoard extends StatefulWidget {
  const MoneyStatusBoard({required this.snapshot, super.key});

  final TodaySnapshot snapshot;

  @override
  State<MoneyStatusBoard> createState() => _MoneyStatusBoardState();
}

class _MoneyStatusBoardState extends State<MoneyStatusBoard> {
  var _balancesVisible = true;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(SproutRadius.card),
        border: Border.all(color: colors.line),
        boxShadow: SproutElevation.raised(color: colors.ink),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SproutSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with balance toggle
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Money status',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(width: SproutSpacing.sm),
                _BalanceToggle(
                  visible: _balancesVisible,
                  onToggle: () =>
                      setState(() => _balancesVisible = !_balancesVisible),
                ),
              ],
            ),
            const SizedBox(height: SproutSpacing.md),
            // 3 hero tiles
            Row(
              children: [
                Expanded(
                  child: _MoneyStatusTile(
                    label: SproutStrings.readyToUse,
                    value: _balancesVisible
                        ? SproutFormat.compactCurrency(
                            widget.snapshot.availableCash)
                        : SproutStrings.hiddenBalance,
                    hint: SproutStrings.readyToUseHint,
                    icon: Icons.account_balance_wallet_rounded,
                    color: SproutColors.seed,
                    plantState: _PlantState.sprout,
                    onTap: () => _showStatusSheet(
                      context,
                      SproutStrings.readyToUse,
                      'PKR ${widget.snapshot.availableCash} available to spend.',
                    ),
                  ),
                ),
                const SizedBox(width: SproutSpacing.sm),
                Expanded(
                  child: _MoneyStatusTile(
                    label: SproutStrings.savedAway,
                    value: _balancesVisible
                        ? 'PKR 5.2M'
                        : SproutStrings.hiddenBalance,
                    hint: SproutStrings.savedAwayHint,
                    icon: Icons.savings_rounded,
                    color: SproutColors.sky,
                    plantState: _PlantState.tree,
                    onTap: () => _showStatusSheet(
                      context,
                      SproutStrings.savedAway,
                      'Emergency fund + investments growing steadily.',
                    ),
                  ),
                ),
                const SizedBox(width: SproutSpacing.sm),
                Expanded(
                  child: _MoneyStatusTile(
                    label: SproutStrings.mainGoal,
                    value:
                        _balancesVisible ? '35%' : SproutStrings.hiddenBalance,
                    hint: SproutStrings.mainGoalHint,
                    icon: Icons.flag_rounded,
                    color: SproutColors.lilac,
                    plantState: _PlantState.mountain,
                    onTap: () => _showStatusSheet(
                      context,
                      SproutStrings.mainGoal,
                      'Car fund is 35% complete. Keep planting!',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _PlantState { sprout, tree, mountain }

class _MoneyStatusTile extends StatelessWidget {
  const _MoneyStatusTile({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
    required this.color,
    required this.plantState,
    required this.onTap,
  });

  final String label;
  final String value;
  final String hint;
  final IconData icon;
  final Color color;
  final _PlantState plantState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SproutButtonPress(
      onTap: onTap,
      scale: 0.95,
      semanticLabel: '$label: $value. $hint',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(SproutRadius.tile),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SproutSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const Spacer(),
                  _PlantBadge(state: plantState, color: color),
                ],
              ),
              const SizedBox(height: SproutSpacing.sm),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: SproutColorScheme.of(context).ink,
                      ),
                ),
              ),
              const SizedBox(height: 2),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 1),
              Text(hint,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

/// A tiny plant-state indicator that gives each tile a "garden" feel.
class _PlantBadge extends StatelessWidget {
  const _PlantBadge({required this.state, required this.color});

  final _PlantState state;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final icon = switch (state) {
      _PlantState.sprout => Icons.grass_rounded,
      _PlantState.tree => Icons.park_rounded,
      _PlantState.mountain => Icons.terrain_rounded,
    };
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 13, color: color),
    );
  }
}

class _BalanceToggle extends StatelessWidget {
  const _BalanceToggle({
    required this.visible,
    required this.onToggle,
  });

  final bool visible;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return SproutButtonPress(
      onTap: onToggle,
      scale: 0.95,
      semanticLabel:
          visible ? SproutStrings.hideBalances : SproutStrings.showBalances,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: SproutColorScheme.of(context).mint,
          borderRadius: BorderRadius.circular(SproutRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              visible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              size: 15,
              color: SproutColors.seed,
            ),
            const SizedBox(width: 5),
            Text(
              visible ? SproutStrings.hideBalances : SproutStrings.showBalances,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: SproutColors.leaf,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showStatusSheet(BuildContext context, String title, String value) {
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
                Expanded(
                  child: Text(
                    SproutStrings.moneyRadar,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(width: SproutSpacing.sm),
                SproutButtonPress(
                  semanticLabel: SproutStrings.needReview(3),
                  onTap: () => SproutBottomSheet.show(
                    context,
                    title: SproutStrings.moneyRadar,
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
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: SproutColors.gold.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(SproutRadius.pill),
                    ),
                    child: Text(
                      SproutStrings.needReview(3),
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: SproutColors.goldInk),
                    ),
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
                child: const Text(SproutStrings.viewDetails),
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
    ('Chai', Icons.local_cafe_rounded, SproutColors.tintWarm),
    ('Fuel', Icons.local_gas_station_rounded, SproutColors.tintSky),
    ('Groceries', Icons.shopping_basket_rounded, SproutColors.tintMint),
    ('IBFT', Icons.swap_horiz_rounded, SproutColors.tintLilac),
    ('Bill', Icons.receipt_rounded, SproutColors.tintWarm),
    ('Savings', Icons.savings_rounded, SproutColors.tintMint),
  ];

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
            return QuickActionButton(
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
