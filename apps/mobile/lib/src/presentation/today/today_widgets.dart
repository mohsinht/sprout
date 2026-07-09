import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../theme/sprout_strings.dart';
import '../../theme/sprout_tokens.dart';
import '../../theme/sprout_theme.dart';
import '../../widgets/sprout_mascot.dart';
import '../../widgets/sprout_mascot_state.dart';

class StreakPill extends StatelessWidget {
  const StreakPill({required this.days, super.key});

  final int days;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SproutColors.gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department_rounded,
              color: SproutColors.gold, size: 20),
          const SizedBox(width: 5),
          Text('$days', style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );

    if (reducedMotion) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeInOut,
      builder: (context, scale, _) =>
          Transform.scale(scale: scale, child: child),
      onEnd: () {},
    );
  }
}

class AnimatedScoreRing extends StatelessWidget {
  const AnimatedScoreRing({
    required this.score,
    this.size = 106,
    this.foregroundColor = Colors.white,
    this.trackColor,
    super.key,
  });

  final int score;
  final double size;
  final Color foregroundColor;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    final duration =
        reducedMotion ? Duration.zero : SproutDurations.progressRing;

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: score / 100),
        duration: duration,
        curve: SproutCurves.progress,
        builder: (context, value, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 10,
                color: SproutColors.gold,
                backgroundColor:
                    trackColor ?? Colors.white.withValues(alpha: 0.24),
                strokeCap: StrokeCap.round,
              ),
              Center(
                child: SproutNumberCounter(
                  value: score,
                  duration: duration,
                  builder: (context, animatedScore) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        animatedScore.round().toString(),
                        style: SproutType.scoreValue(
                          color: foregroundColor,
                          size: size >= 100 ? 34 : 30,
                          weight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        SproutStrings.scoreLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: foregroundColor.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ScoreChip extends StatelessWidget {
  const ScoreChip({
    required this.label,
    required this.icon,
    required this.positive,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool positive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = positive ? Colors.white : SproutColors.gold;
    return SproutButtonPress(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: positive ? 0.18 : 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class SnapshotTile extends StatelessWidget {
  const SnapshotTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SproutButtonPress(
        onTap: onTap,
        scale: 0.94,
        semanticLabel: '$label: $value. Tap for details.',
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(SproutRadius.card),
            boxShadow: [
              BoxShadow(
                color: SproutColors.ink.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: SproutColors.leaf, size: 22),
                const SizedBox(height: SproutSpacing.sm),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                const SizedBox(height: 2),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DailyQuestCard extends StatefulWidget {
  const DailyQuestCard({
    required this.completed,
    required this.onComplete,
    super.key,
  });

  final bool completed;
  final VoidCallback onComplete;

  @override
  State<DailyQuestCard> createState() => _DailyQuestCardState();
}

class _DailyQuestCardState extends State<DailyQuestCard>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _completeController;
  late final Animation<double> _completeScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
      lowerBound: 0.985,
      upperBound: 1,
    )..repeat(reverse: true);

    _completeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _completeScale = Tween<double>(begin: 1, end: 1.06).animate(
      CurvedAnimation(
        parent: _completeController,
        curve: SproutCurves.playful,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant DailyQuestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.completed && widget.completed) {
      _completeController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _completeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    final card = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.completed
              ? [SproutColors.gold, const Color(0xFFFFCA68)]
              : [SproutColors.heroGreenStart, SproutColors.heroGreenEnd],
        ),
        borderRadius: BorderRadius.circular(SproutRadius.card),
        boxShadow: [
          const BoxShadow(
            color: Color(0xFF248A3F),
            blurRadius: 0,
            offset: Offset(0, 5),
          ),
          BoxShadow(
            color: SproutColors.seed.withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            // Mascot in the icon slot — celebrates when complete.
            SizedBox(
              width: 56,
              height: 56,
              child: Center(
                child: widget.completed
                    ? const SproutMascot(
                        size: 52,
                        state: SproutMascotState.celebrate,
                      )
                    : const SproutMascot(
                        size: 48,
                        state: SproutMascotState.happy,
                      ),
              ),
            ),
            const SizedBox(width: SproutSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SproutStrings.dailyQuest,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 0.4,
                        ),
                  ),
                  const SizedBox(height: 1),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.completed
                          ? SproutStrings.questPlanted
                          : SproutStrings.plantPkr10k,
                      maxLines: 1,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.white, fontSize: 23),
                    ),
                  ),
                  if (widget.completed) ...[
                    const SizedBox(height: 4),
                    Text(
                      '+3 Health',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: SproutSpacing.sm),
            _QuestRewardBadge(text: '+20 XP', completed: widget.completed),
            IconButton(
              onPressed: () => SproutBottomSheet.show(
                context,
                title: SproutStrings.whyThisQuest,
                rows: const [
                  SheetInfoRow(
                    icon: Icons.lightbulb_rounded,
                    label: 'Recommendation',
                    value: 'Save PKR 10K.',
                  ),
                  SheetInfoRow(
                    icon: Icons.psychology_alt_rounded,
                    label: 'Why',
                    value:
                        'Spending is controlled and your buffer needs a nudge.',
                  ),
                  SheetInfoRow(
                    icon: Icons.verified_user_rounded,
                    label: 'Confidence',
                    value: 'Medium. Some bank alerts may still be pending.',
                  ),
                ],
              ),
              icon: const Icon(Icons.info_outline_rounded),
              color: Colors.white,
              tooltip: SproutStrings.whyThisQuest,
            ),
          ],
        ),
      ),
    );

    final pressed = SproutButtonPress(
      onTap: widget.completed ? null : widget.onComplete,
      scale: 0.98,
      child: card,
    );

    if (reducedMotion) return pressed;

    // Completion bounce takes priority over idle pulse.
    if (widget.completed && _completeController.isAnimating) {
      return AnimatedBuilder(
        animation: _completeScale,
        builder: (context, child) =>
            Transform.scale(scale: _completeScale.value, child: child),
        child: pressed,
      );
    }

    if (widget.completed) return pressed;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) => Transform.scale(
        scale: _pulseController.value,
        child: child,
      ),
      child: pressed,
    );
  }
}

class _QuestRewardBadge extends StatelessWidget {
  const _QuestRewardBadge({required this.text, this.completed = false});

  final String text;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: completed ? 0.3 : 0.2),
        borderRadius: BorderRadius.circular(SproutRadius.pill),
        border: Border.all(
          color: Colors.white.withValues(alpha: completed ? 0.6 : 0.4),
          width: completed ? 1.5 : 1,
        ),
        boxShadow: completed
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class SourceStatusPill extends StatelessWidget {
  const SourceStatusPill({
    required this.label,
    required this.connected,
    super.key,
  });

  final String label;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Semantics(
      label: '$label: ${connected ? 'connected' : 'not connected'}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _todayWidgetTint(context, SproutColors.tintMint),
          borderRadius: BorderRadius.circular(SproutRadius.pill),
          border: Border.all(color: _todayWidgetBorder(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(width: 6),
            Icon(
              connected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: connected
                  ? _todayWidgetAccent(context, SproutColors.seed)
                  : colors.muted,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: SproutButtonPress(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        scale: 0.9,
        semanticLabel: label,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _quickActionRim(color),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _quickActionOutline(color),
                  width: 2,
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                child: Column(
                  children: [
                    Icon(icon, color: SproutColors.leaf, size: 28),
                    const SizedBox(height: 9),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
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

  Color _quickActionRim(Color color) {
    if (color == SproutColors.tintWarm) return const Color(0xFFE0B66D);
    if (color == SproutColors.tintSky) return const Color(0xFF9DBFEF);
    if (color == SproutColors.tintMint) return const Color(0xFF9FD8B7);
    if (color == SproutColors.tintLilac) return const Color(0xFFC3AAF0);
    return SproutColors.line;
  }

  Color _quickActionOutline(Color color) {
    if (color == SproutColors.tintWarm) return const Color(0xFFF0C77E);
    if (color == SproutColors.tintSky) return const Color(0xFFB8D2F5);
    if (color == SproutColors.tintMint) return const Color(0xFFB7E6C9);
    if (color == SproutColors.tintLilac) return const Color(0xFFD5C2F6);
    return SproutColors.line;
  }
}

class SproutBottomSheet extends StatelessWidget {
  const SproutBottomSheet({
    required this.title,
    required this.rows,
    super.key,
  });

  final String title;
  final List<SheetInfoRow> rows;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<SheetInfoRow> rows,
  }) {
    final colors = SproutColorScheme.of(context);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SproutBottomSheet(title: title, rows: rows),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: SproutSpacing.lg),
            for (final row in rows) ...[
              row,
              const SizedBox(height: SproutSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

/// A drawer that contains real data rows AND at least one action button.
/// This is the "signal" drawer — it never dead-ends with just a paragraph.
/// Every drawer must offer a real action or a drill into real data.
class SproutActionSheet extends StatelessWidget {
  const SproutActionSheet({
    required this.title,
    required this.rows,
    this.actions = const [],
    super.key,
  });

  final String title;
  final List<SheetInfoRow> rows;

  /// Action buttons at the bottom. Each must lead to a real action or drill.
  final List<SheetAction> actions;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<SheetInfoRow> rows,
    List<SheetAction> actions = const [],
  }) {
    final colors = SproutColorScheme.of(context);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) =>
          SproutActionSheet(title: title, rows: rows, actions: actions),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: SproutSpacing.lg),
            for (final row in rows) ...[
              row,
              const SizedBox(height: SproutSpacing.md),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: SproutSpacing.sm),
              for (final action in actions) ...[
                action,
                const SizedBox(height: SproutSpacing.sm),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// An action button inside a [SproutActionSheet]. Must lead to a real action
/// or a drill into real data — never a dead end.
class SheetAction extends StatelessWidget {
  const SheetAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.isDestructive = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final color = isDestructive
        ? SproutColors.tomato
        : (isPrimary ? SproutColors.seed : colors.ink);

    return SizedBox(
      width: double.infinity,
      child: SproutButtonPress(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        scale: 0.97,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: isPrimary
                ? SproutColors.seed.withValues(alpha: 0.08)
                : colors.line.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class SheetInfoRow extends StatelessWidget {
  const SheetInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: _todayWidgetTint(context, SproutColors.tintMint),
          child: Icon(
            icon,
            color: _todayWidgetAccent(context, SproutColors.seed),
            size: 20,
          ),
        ),
        const SizedBox(width: SproutSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class XpRewardAnimation extends StatefulWidget {
  const XpRewardAnimation({required this.text, super.key});

  final String text;

  @override
  State<XpRewardAnimation> createState() => _XpRewardAnimationState();
}

class _XpRewardAnimationState extends State<XpRewardAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Pop in (0-0.25) then float up and fade (0.25-1).
        final t = _controller.value;
        final popIn = (t / 0.25).clamp(0.0, 1.0).toDouble();
        final floatT = ((t - 0.25) / 0.75).clamp(0.0, 1.0).toDouble();
        final popScale = Curves.easeOutBack.transform(popIn);
        final floatCurve = Curves.easeOutCubic.transform(floatT);

        return Opacity(
          opacity: 1 - floatCurve * 0.9,
          child: Transform.translate(
            offset: Offset(0, -80 * floatCurve),
            child: Transform.scale(
              scale: 0.7 + popScale * 0.4,
              child: child,
            ),
          ),
        );
      },
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [SproutColors.gold, Color(0xFFFFCA68)],
            ),
            borderRadius: BorderRadius.circular(SproutRadius.pill),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: SproutColors.gold.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                widget.text,
                style: SproutType.metricValue(
                  color: Colors.white,
                  size: 22,
                  weight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key});

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SproutDurations.confetti,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _ConfettiPainter(progress: _controller.value),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.progress});

  final double progress;

  static const _colors = [
    SproutColors.gold,
    SproutColors.seed,
    SproutColors.sky,
    SproutColors.lilac,
    Color(0xFFFF8A65),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final eased = Curves.easeOutCubic.transform(progress);
    for (var i = 0; i < 36; i++) {
      final angle = (i / 36) * math.pi * 2;
      final radius = 24 + eased * (size.width * 0.46);
      final center = Offset(
        size.width / 2 + math.cos(angle) * radius,
        size.height * 0.42 + math.sin(angle) * radius * 0.58 + eased * 90,
      );
      paint.color = _colors[i % _colors.length].withValues(alpha: 1 - progress);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle + progress * math.pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-3, -6, 6, 12),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

bool _todayWidgetIsDark(BuildContext context) {
  return SproutColorScheme.of(context).brightness == Brightness.dark;
}

Color _todayWidgetTint(BuildContext context, Color lightTint) {
  if (!_todayWidgetIsDark(context)) return lightTint;
  if (lightTint == SproutColors.tintMint || lightTint == SproutColors.mint) {
    return SproutColors.darkMint.withValues(alpha: 0.78);
  }
  if (lightTint == SproutColors.tintGold ||
      lightTint == SproutColors.tintWarm) {
    return SproutColors.darkGold.withValues(alpha: 0.18);
  }
  if (lightTint == SproutColors.tintSky) {
    return SproutColors.darkSky.withValues(alpha: 0.16);
  }
  if (lightTint == SproutColors.tintLilac) {
    return SproutColors.darkLilac.withValues(alpha: 0.18);
  }
  return SproutColorScheme.of(context).surface;
}

Color _todayWidgetAccent(BuildContext context, Color lightAccent) {
  if (!_todayWidgetIsDark(context)) return lightAccent;
  if (lightAccent == SproutColors.seed || lightAccent == SproutColors.leaf) {
    return SproutColors.darkSeed;
  }
  if (lightAccent == SproutColors.gold || lightAccent == SproutColors.goldInk) {
    return SproutColors.darkGold;
  }
  if (lightAccent == SproutColors.sky) return SproutColors.darkSky;
  if (lightAccent == SproutColors.lilac) return SproutColors.darkLilac;
  return lightAccent;
}

Color _todayWidgetBorder(BuildContext context) {
  final colors = SproutColorScheme.of(context);
  return _todayWidgetIsDark(context)
      ? colors.line.withValues(alpha: 0.95)
      : SproutColors.seed.withValues(alpha: 0.18);
}
