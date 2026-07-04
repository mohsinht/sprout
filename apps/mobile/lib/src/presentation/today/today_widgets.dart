import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../theme/sprout_tokens.dart';
import '../../widgets/coin_sprout_mascot.dart';

enum SproutMascotMood {
  happy,
  thumbsUp,
  thinking,
  supportive,
  celebrating,
  peek,
  reading,
}

class SproutMascot extends StatelessWidget {
  const SproutMascot({
    required this.mood,
    this.size = 72,
    super.key,
  });

  final SproutMascotMood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    final mascot = Stack(
      clipBehavior: Clip.none,
      children: [
        CoinSproutMascot(size: size),
        Positioned(
          right: -4,
          bottom: mood == SproutMascotMood.peek ? -2 : 2,
          child: _MoodBadge(mood: mood),
        ),
      ],
    );

    if (reducedMotion) return mascot;
    return mascot.sproutMascotIdle();
  }
}

class _MoodBadge extends StatelessWidget {
  const _MoodBadge({required this.mood});

  final SproutMascotMood mood;

  @override
  Widget build(BuildContext context) {
    final icon = switch (mood) {
      SproutMascotMood.thumbsUp => Icons.thumb_up_alt_rounded,
      SproutMascotMood.thinking => Icons.psychology_alt_rounded,
      SproutMascotMood.supportive => Icons.favorite_rounded,
      SproutMascotMood.celebrating => Icons.celebration_rounded,
      SproutMascotMood.peek => Icons.visibility_rounded,
      SproutMascotMood.reading => Icons.menu_book_rounded,
      SproutMascotMood.happy => Icons.eco_rounded,
    };

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: SproutColors.ink.withValues(alpha: 0.12),
            blurRadius: 8,
          ),
        ],
      ),
      child: Icon(icon, size: 15, color: SproutColors.seed),
    );
  }
}

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
  const AnimatedScoreRing({required this.score, this.size = 106, super.key});

  final int score;
  final double size;

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
                backgroundColor: Colors.white.withValues(alpha: 0.24),
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
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontSize: size >= 100 ? 34 : 30,
                                  height: 1,
                                ),
                      ),
                      Text(
                        'score',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.78),
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
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
      lowerBound: 0.985,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
              : [const Color(0xFF41C368), const Color(0xFF2E9E4C)],
        ),
        borderRadius: BorderRadius.circular(24),
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
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.completed
                    ? Icons.check_rounded
                    : Icons.track_changes_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: SproutSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAILY QUEST',
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
                      widget.completed ? 'Quest complete' : 'Save PKR 10K',
                      maxLines: 1,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.white, fontSize: 23),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SproutSpacing.sm),
            const _QuestRewardBadge(text: '+20 XP'),
            IconButton(
              onPressed: () => SproutBottomSheet.show(
                context,
                title: 'Why this quest?',
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
              tooltip: 'Why this quest?',
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

    if (reducedMotion || widget.completed) return pressed;
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
  const _QuestRewardBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: Colors.white),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: SproutColors.mint,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SproutColors.seed.withValues(alpha: 0.18)),
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
            color: connected ? SproutColors.seed : SproutColors.muted,
            size: 17,
          ),
        ],
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
      width: 102,
      child: SproutButtonPress(
        onTap: onTap,
        scale: 0.92,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(22),
            border:
                Border.all(color: SproutColors.line.withValues(alpha: 0.55)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
            child: Column(
              children: [
                Icon(icon, color: SproutColors.leaf),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label,
                      style: Theme.of(context).textTheme.labelLarge),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: SproutColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SproutBottomSheet(title: title, rows: rows),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
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
          backgroundColor: SproutColors.mint,
          child: Icon(icon, color: SproutColors.seed, size: 20),
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
      duration: SproutDurations.xpReward,
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
        final curved = Curves.easeOutCubic.transform(_controller.value);
        return Opacity(
          opacity: 1 - curved,
          child: Transform.translate(
            offset: Offset(0, -46 * curved),
            child: Transform.scale(
              scale: 0.9 + curved * 0.2,
              child: child,
            ),
          ),
        );
      },
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: SproutColors.gold,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: SproutColors.gold.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            widget.text,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white),
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
