import 'package:flutter/material.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../domain/learn_models.dart';
import '../shell/nav_metrics.dart';
import '../../theme/sprout_strings.dart';
import '../../theme/sprout_theme.dart';
import '../../theme/sprout_tokens.dart';
import '../../widgets/sprout_card.dart';
import '../../widgets/sprout_mascot.dart';
import '../../widgets/sprout_mascot_state.dart';
import '../../widgets/sprout_page.dart';
import '../today/today_widgets.dart';

/// Primary Learn tab content: hero, lesson path, and daily lesson quest.
class LearnContent extends StatelessWidget {
  const LearnContent({
    required this.data,
    required this.onStartLesson,
    super.key,
  });

  final LearnData data;
  final ValueChanged<LessonNode> onStartLesson;

  @override
  Widget build(BuildContext context) {
    final currentNode = data.currentNode;
    return SproutPage(
      title: SproutStrings.learnTitle,
      subtitle: SproutStrings.learnSubtitle,
      trailing: StreakPill(days: data.user.dayStreak),
      children: [
        LearnHero(data: data),
        const SizedBox(height: SproutSpacing.md),
        LearnPathPanel(data: data, onStartLesson: onStartLesson),
        const SizedBox(height: SproutSpacing.md),
        LessonQuestCard(
          node: currentNode,
          complete: data.isComplete,
          onTap: currentNode == null ? null : () => onStartLesson(currentNode),
        ),
      ],
    );
  }
}

/// Top Learn summary card, connected to the shared XP/streak economy.
class LearnHero extends StatelessWidget {
  const LearnHero({required this.data, super.key});

  final LearnData data;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: SproutGradients.lilac,
        borderRadius: BorderRadius.circular(SproutRadius.hero),
        boxShadow: SproutElevation.hero(SproutColors.lilac),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SproutSpacing.xl),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SproutStrings.learningStreak,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: SproutSpacing.xs),
                  Text(
                    SproutStrings.days(data.user.dayStreak),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: SproutSpacing.xs),
                  Text(
                    data.currentNode == null
                        ? SproutStrings.pathComplete
                        : SproutStrings.todayLesson(
                            data.currentNode!.title.resolve(),
                          ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.86),
                        ),
                  ),
                ],
              ),
            ),
            const RepaintBoundary(
              child: SproutMascot(size: 78, state: SproutMascotState.reading),
            ),
          ],
        ),
      ),
    );
  }
}

/// Duolingo-style ordered path of locked, available, and completed lessons.
class LearnPathPanel extends StatelessWidget {
  const LearnPathPanel({
    required this.data,
    required this.onStartLesson,
    super.key,
  });

  final LearnData data;
  final ValueChanged<LessonNode> onStartLesson;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return SproutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  SproutStrings.yourPath,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SourceStatusPill(label: data.path.levelLabel, connected: true),
            ],
          ),
          const SizedBox(height: SproutSpacing.lg),
          for (var i = 0; i < data.path.nodes.length; i++)
            LessonPathNode(
              node: data.path.nodes[i],
              step: i + 1,
              last: i == data.path.nodes.length - 1,
              lineColor: colors.line,
              onTap: data.path.nodes[i].status == LessonNodeStatus.available
                  ? () => onStartLesson(data.path.nodes[i])
                  : null,
            ),
        ],
      ),
    );
  }
}

/// A single lesson node row inside the path.
class LessonPathNode extends StatelessWidget {
  const LessonPathNode({
    required this.node,
    required this.step,
    required this.last,
    required this.lineColor,
    this.onTap,
    super.key,
  });

  final LessonNode node;
  final int step;
  final bool last;
  final Color lineColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = node.status;
    final done = status == LessonNodeStatus.done;
    final available = status == LessonNodeStatus.available;
    final color = done
        ? SproutColors.seed
        : available
            ? SproutColors.sky
            : SproutColors.locked;
    final label = switch (status) {
      LessonNodeStatus.done => SproutStrings.done,
      LessonNodeStatus.available => SproutStrings.available,
      LessonNodeStatus.locked => SproutStrings.locked,
    };

    return SproutButtonPress(
      onTap: onTap,
      scale: 0.97,
      semanticLabel: '${node.title.resolve()}, $label. Reward: +${node.xp} XP.',
      child: Padding(
        padding: EdgeInsets.only(bottom: last ? 0 : SproutSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                _LessonBadge(
                  color: color,
                  label: step.toString(),
                  icon: done
                      ? Icons.check_rounded
                      : available
                          ? Icons.play_arrow_rounded
                          : Icons.lock_rounded,
                  active: done || available,
                ),
                if (!last)
                  Container(
                    width: 3,
                    height: 28,
                    margin: const EdgeInsets.only(top: SproutSpacing.sm),
                    decoration: BoxDecoration(
                      color: lineColor,
                      borderRadius: BorderRadius.circular(SproutRadius.pill),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: SproutSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: SproutSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.title.resolve(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: SproutSpacing.xs),
                    Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(width: SproutSpacing.sm),
            _XpPill(xp: node.xp),
          ],
        ),
      ),
    );
  }
}

class _LessonBadge extends StatelessWidget {
  const _LessonBadge({
    required this.color,
    required this.label,
    required this.icon,
    required this.active,
  });

  final Color color;
  final String label;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color.lerp(color, Colors.black, 0.18)!,
            blurRadius: 0,
            offset: const Offset(0, SproutSpacing.xs),
          ),
        ],
      ),
      child: Center(
        child: active
            ? Icon(icon, color: Colors.white)
            : Text(
                label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: SproutColors.muted,
                    ),
              ),
      ),
    );
  }
}

class _XpPill extends StatelessWidget {
  const _XpPill({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SproutSpacing.md,
        vertical: SproutSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: SproutColors.lilac.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(SproutRadius.pill),
      ),
      child: Text(
        '+$xp',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: SproutColors.lilac,
            ),
      ),
    );
  }
}

/// The current lesson quest entry point.
class LessonQuestCard extends StatelessWidget {
  const LessonQuestCard({
    required this.node,
    required this.complete,
    required this.onTap,
    super.key,
  });

  final LessonNode? node;
  final bool complete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SproutButtonPress(
      onTap: onTap,
      semanticLabel: complete
          ? SproutStrings.pathComplete
          : SproutStrings.startLesson(node?.title.resolve() ?? ''),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: complete ? SproutGradients.green : SproutGradients.sky,
          borderRadius: BorderRadius.circular(SproutRadius.card),
          boxShadow: SproutElevation.hero(
            complete ? SproutColors.seed : SproutColors.sky,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SproutSpacing.lg),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                child: Icon(
                  complete ? Icons.verified_rounded : Icons.menu_book_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: SproutSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SproutStrings.lessonQuest,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                    const SizedBox(height: SproutSpacing.xs),
                    Text(
                      complete
                          ? SproutStrings.allLessonsPlanted
                          : SproutStrings.finishLesson(
                              node?.title.resolve() ?? SproutStrings.lesson,
                            ),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
              if (node != null) _QuestRewardBadge(text: '+${node!.xp} XP'),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestRewardBadge extends StatelessWidget {
  const _QuestRewardBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SproutSpacing.md,
        vertical: SproutSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(SproutRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

/// Swipeable lesson player ending in a single comprehension check.
class LearnLessonPlayer extends StatefulWidget {
  const LearnLessonPlayer({
    required this.node,
    required this.lesson,
    required this.result,
    required this.onAnswer,
    required this.onClose,
    super.key,
  });

  final LessonNode node;
  final Lesson lesson;
  final LessonCompletionResult? result;
  final ValueChanged<int> onAnswer;
  final VoidCallback onClose;

  @override
  State<LearnLessonPlayer> createState() => _LearnLessonPlayerState();
}

class _LearnLessonPlayerState extends State<LearnLessonPlayer> {
  final _pageController = PageController();
  var _page = 0;
  var _selectedIndex = -1;
  var _answering = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_page < widget.lesson.cards.length - 1) {
      if (MediaQuery.of(context).disableAnimations) {
        _pageController.jumpToPage(_page + 1);
        return;
      }
      await _pageController.nextPage(
        duration: SproutDurations.pageTransition,
        curve: SproutCurves.standard,
      );
      return;
    }
    setState(() => _page = widget.lesson.cards.length);
  }

  Future<void> _answer(int index) async {
    if (_answering) return;
    setState(() {
      _answering = true;
      _selectedIndex = index;
    });
    widget.onAnswer(index);
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.lesson.checkQuestion;
    final result = widget.result;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            SproutSpacing.pageHorizontal,
            SproutSpacing.md,
            SproutSpacing.pageHorizontal,
            NavMetrics.bottomContentPadding(context),
          ),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close_rounded),
                    tooltip: SproutStrings.close,
                  ),
                  const SizedBox(width: SproutSpacing.sm),
                  Expanded(
                    child: SproutProgressBar(
                      value: (_page + 1) / (widget.lesson.cards.length + 1),
                      color: SproutColors.lilac,
                    ),
                  ),
                  const SizedBox(width: SproutSpacing.sm),
                  _XpPill(xp: widget.node.xp),
                ],
              ),
              const SizedBox(height: SproutSpacing.lg),
              if (result != null)
                LessonResultCard(result: result, onDone: widget.onClose)
              else if (_page < widget.lesson.cards.length)
                _CardPager(
                  pageController: _pageController,
                  lesson: widget.lesson,
                  page: _page,
                  onPageChanged: (page) => setState(() => _page = page),
                  onNext: _next,
                )
              else
                LessonQuestionCard(
                  question: question,
                  selectedIndex: _selectedIndex,
                  answering: _answering,
                  onAnswer: _answer,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardPager extends StatelessWidget {
  const _CardPager({
    required this.pageController,
    required this.lesson,
    required this.page,
    required this.onPageChanged,
    required this.onNext,
  });

  final PageController pageController;
  final Lesson lesson;
  final int page;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final cardHeight = MediaQuery.sizeOf(context).height < 720 ? 400.0 : 430.0;
    return Column(
      children: [
        SizedBox(
          height: cardHeight,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: onPageChanged,
            itemCount: lesson.cards.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SproutSpacing.xs,
                ),
                child: LessonStoryCard(
                  card: lesson.cards[index],
                  step: index + 1,
                  total: lesson.cards.length,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: SproutSpacing.lg),
        FilledButton.icon(
          onPressed: onNext,
          icon: Icon(
            page == lesson.cards.length - 1
                ? Icons.quiz_rounded
                : Icons.arrow_forward_rounded,
          ),
          label: Text(
            page == lesson.cards.length - 1
                ? SproutStrings.takeCheck
                : SproutStrings.next,
          ),
        ),
      ],
    );
  }
}

/// A single swipeable teaching card.
class LessonStoryCard extends StatelessWidget {
  const LessonStoryCard({
    required this.card,
    required this.step,
    required this.total,
    super.key,
  });

  final LessonCard card;
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return SproutCard(
      color: SproutColorScheme.of(context).surface,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SourceStatusPill(label: '$step/$total', connected: true),
                const Spacer(),
                const RepaintBoundary(
                  child: SproutMascot(
                    size: 54,
                    state: SproutMascotState.reading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SproutSpacing.lg),
            Text(
              card.title.resolve(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: SproutSpacing.md),
            Text(
              card.body.resolve(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: SproutSpacing.lg),
            const RecommendationCard(
              recommendation: SproutStrings.oneMinuteTakeaway,
              why: SproutStrings.learnTinyHabit,
              confidence: SproutStrings.worksOffline,
              color: SproutColors.lilac,
            ),
          ],
        ),
      ),
    );
  }
}

/// Final comprehension check for a lesson.
class LessonQuestionCard extends StatelessWidget {
  const LessonQuestionCard({
    required this.question,
    required this.selectedIndex,
    required this.answering,
    required this.onAnswer,
    super.key,
  });

  final CheckQuestion question;
  final int selectedIndex;
  final bool answering;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) {
    return SproutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SourceStatusPill(
            label: SproutStrings.quickCheck,
            connected: true,
          ),
          const SizedBox(height: SproutSpacing.lg),
          Text(
            question.prompt.resolve(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: SproutSpacing.lg),
          for (var i = 0; i < question.options.length; i++) ...[
            _AnswerOption(
              label: question.options[i].resolve(),
              selected: selectedIndex == i,
              disabled: answering,
              onTap: () => onAnswer(i),
            ),
            if (i != question.options.length - 1)
              const SizedBox(height: SproutSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.label,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return SproutButtonPress(
      onTap: disabled ? null : onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? SproutColors.tintLilac : colors.surface,
          borderRadius: BorderRadius.circular(SproutRadius.tile),
          border: Border.all(
            color: selected ? SproutColors.lilac : colors.line,
            width: selected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SproutSpacing.lg),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? SproutColors.lilac : colors.muted,
              ),
              const SizedBox(width: SproutSpacing.md),
              Expanded(
                child:
                    Text(label, style: Theme.of(context).textTheme.bodyLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Result surface for correct and gently corrective wrong answers.
class LessonResultCard extends StatelessWidget {
  const LessonResultCard(
      {required this.result, required this.onDone, super.key});

  final LessonCompletionResult result;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final correct = result.correct;
    return SproutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SproutMascot(
              size: 96,
              state: correct
                  ? SproutMascotState.celebrate
                  : SproutMascotState.worried,
            ),
          ),
          const SizedBox(height: SproutSpacing.lg),
          Text(
            correct ? SproutStrings.lessonComplete : SproutStrings.tryAgainCalm,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: SproutSpacing.sm),
          Text(result.explanation,
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: SproutSpacing.lg),
          RecommendationCard(
            recommendation: correct
                ? SproutStrings.nextLessonUnlocked
                : SproutStrings.reReadTinyCard,
            why: correct
                ? SproutStrings.xpAdded(result.awardedXp)
                : SproutStrings.noLostXp,
            confidence: SproutStrings.worksOffline,
            color: correct ? SproutColors.seed : SproutColors.gold,
          ),
          const SizedBox(height: SproutSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onDone,
              icon: Icon(
                correct ? Icons.check_rounded : Icons.refresh_rounded,
              ),
              label: Text(
                correct ? SproutStrings.backToPath : SproutStrings.reviewAgain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared completion celebration using Today's XP reward animation contract.
class LearnRewardOverlay extends StatelessWidget {
  const LearnRewardOverlay({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Stack(
        children: [
          const Positioned.fill(child: ConfettiBurst()),
          Positioned.fill(
            child: Align(
              alignment: const Alignment(0, 0.12),
              child: XpRewardAnimation(text: text),
            ),
          ),
        ],
      ),
    );
  }
}
