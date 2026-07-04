import 'package:flutter/material.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../theme/sprout_tokens.dart';
import '../../widgets/sprout_page.dart';
import '../today/today_widgets.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  static const _lessons = [
    _Lesson('Budget Basics', 'Done', 1, 20, 1),
    _Lesson('Emergency Fund', 'Done', 2, 25, 1),
    _Lesson('Diversification', 'Today', 3, 20, .62),
    _Lesson('Compound Growth', 'Next', 4, 30, 0),
    _Lesson('Smart Investing', 'Next', 5, 30, 0),
  ];

  @override
  Widget build(BuildContext context) {
    return const SproutPage(
      title: 'Learn',
      subtitle: 'Tiny money lessons. One minute max.',
      trailing: _StreakBadge(),
      children: [
        _LearnHero(),
        SizedBox(height: SproutSpacing.md),
        _LessonPath(),
        SizedBox(height: SproutSpacing.md),
        _LearnQuest(),
      ],
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: SproutColors.gold.withValues(alpha: .18),
            borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.local_fire_department_rounded,
              color: SproutColors.gold, size: 20),
          const SizedBox(width: 5),
          Text('12', style: Theme.of(context).textTheme.labelLarge)
        ]),
      );
}

class _LearnHero extends StatelessWidget {
  const _LearnHero();
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF9E70F2), Color(0xFF7A47E4)]),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                  color: SproutColors.lilac.withValues(alpha: .25),
                  blurRadius: 26,
                  offset: const Offset(0, 16))
            ]),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Learning Streak',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white)),
                  Text('12 days',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: Colors.white, fontSize: 38)),
                  Text('Today: Diversification',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: .86)))
                ])),
            const SproutMascot(size: 78, mood: SproutMascotMood.reading),
          ]),
        ),
      );
}

class _LessonPath extends StatelessWidget {
  const _LessonPath();
  @override
  Widget build(BuildContext context) => _RaisedPanel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Your path', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            const SourceStatusPill(label: 'Level 3', connected: true)
          ]),
          const SizedBox(height: SproutSpacing.md),
          for (final lesson in LearnScreen._lessons)
            _LessonNode(lesson: lesson),
        ]),
      );
}

class _LessonNode extends StatelessWidget {
  const _LessonNode({required this.lesson});
  final _Lesson lesson;
  @override
  Widget build(BuildContext context) {
    final done = lesson.progress == 1;
    final active = lesson.progress > 0 && lesson.progress < 1;
    final color = done
        ? SproutColors.seed
        : active
            ? SproutColors.sky
            : const Color(0xFFC6D1CC);
    return SproutButtonPress(
      onTap: () => SproutBottomSheet.show(
        context,
        title: lesson.title,
        rows: [
          SheetInfoRow(
              icon: Icons.school_rounded,
              label: lesson.status,
              value: active
                  ? 'A tiny quiz is ready.'
                  : done
                      ? 'Completed. XP earned.'
                      : 'Unlocks after today.'),
          SheetInfoRow(
              icon: Icons.bolt_rounded,
              label: 'Reward',
              value: '+${lesson.xp} XP'),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: SproutSpacing.md),
        child: Row(children: [
          Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Color.lerp(color, Colors.black, .18)!,
                        blurRadius: 0,
                        offset: const Offset(0, 4))
                  ]),
              child: Center(
                  child: done
                      ? const Icon(Icons.check_rounded, color: Colors.white)
                      : Text('${lesson.step}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white)))),
          const SizedBox(width: SproutSpacing.md),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(lesson.title,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(lesson.status,
                    style: Theme.of(context).textTheme.bodyMedium),
                if (active) ...[
                  const SizedBox(height: 6),
                  SproutProgressBar(
                      value: lesson.progress, color: SproutColors.sky)
                ]
              ])),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                  color: SproutColors.lilac.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(999)),
              child: Text('+${lesson.xp}',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: SproutColors.lilac, fontSize: 12))),
        ]),
      ),
    );
  }
}

class _LearnQuest extends StatelessWidget {
  const _LearnQuest();
  @override
  Widget build(BuildContext context) => _MiniQuestCard(
        color: SproutColors.lilac,
        icon: Icons.menu_book_rounded,
        label: 'LESSON QUEST',
        title: 'Finish Diversification',
        reward: '+20 XP',
        onTap: () => SproutBottomSheet.show(context,
            title: 'Diversification',
            rows: const [
              SheetInfoRow(
                  icon: Icons.timer_rounded,
                  label: 'Time',
                  value: '45 seconds'),
              SheetInfoRow(
                  icon: Icons.psychology_alt_rounded,
                  label: 'Takeaway',
                  value: 'Do not keep all money in one place.')
            ]),
      );
}

class _Lesson {
  const _Lesson(this.title, this.status, this.step, this.xp, this.progress);
  final String title;
  final String status;
  final int step;
  final int xp;
  final double progress;
}

class _RaisedPanel extends StatelessWidget {
  const _RaisedPanel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
      decoration: BoxDecoration(
          color: SproutColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: SproutColors.line),
          boxShadow: [
            BoxShadow(
                color: SproutColors.ink.withValues(alpha: .08),
                blurRadius: 26,
                offset: const Offset(0, 14))
          ]),
      child: Padding(padding: const EdgeInsets.all(16), child: child));
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
  Widget build(BuildContext context) => SproutButtonPress(
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
              ]),
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white.withValues(alpha: .2),
                    child: Icon(icon, color: Colors.white)),
                const SizedBox(width: SproutSpacing.md),
                Expanded(
                    child: Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Colors.white))),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .22),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: .35))),
                    child: Text(reward,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Colors.white)))
              ]))));
}
