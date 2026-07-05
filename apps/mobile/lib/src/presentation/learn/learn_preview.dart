import 'package:flutter/material.dart';

import '../../domain/learn_models.dart';
import '../../theme/sprout_theme.dart';
import '../../theme/sprout_tokens.dart';
import 'learn_widgets.dart';

/// Standalone Learn preview rendering path, in-lesson, result, and complete states.
class LearnPreview extends StatelessWidget {
  const LearnPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildSproutTheme(),
      home: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(SproutSpacing.pageHorizontal),
            children: [
              SizedBox(
                height: 720,
                child: LearnContent(data: _pathData, onStartLesson: (_) {}),
              ),
              const SizedBox(height: SproutSpacing.xl),
              LessonStoryCard(
                card: _lesson.cards.first,
                step: 1,
                total: _lesson.cards.length,
              ),
              const SizedBox(height: SproutSpacing.xl),
              LessonQuestionCard(
                question: _lesson.checkQuestion,
                selectedIndex: -1,
                answering: false,
                onAnswer: (_) {},
              ),
              const SizedBox(height: SproutSpacing.xl),
              LessonResultCard(
                result: LessonCompletionResult(
                  correct: true,
                  awardedXp: 20,
                  explanation: _lesson.checkQuestion.explanation.resolve(),
                  data: _completeData,
                ),
                onDone: () {},
              ),
              const SizedBox(height: SproutSpacing.xl),
              SizedBox(
                height: 620,
                child: LearnContent(data: _completeData, onStartLesson: (_) {}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _lesson = Lesson(
  id: 'ibft',
  cards: [
    LessonCard(
      title: LocalizedText(en: 'IBFT moves money between banks'),
      body: LocalizedText(
        en: 'IBFT is the everyday bank-to-bank transfer used from Pakistani banking apps.',
      ),
    ),
  ],
  checkQuestion: CheckQuestion(
    prompt: LocalizedText(en: 'Before an IBFT, what should you confirm?'),
    options: [
      LocalizedText(en: 'Receiver name, amount, and fee'),
      LocalizedText(en: 'Only your balance'),
    ],
    correctIndex: 0,
    explanation: LocalizedText(
      en: 'Exactly. A quick check prevents most transfer mistakes.',
    ),
  ),
);

const _pathData = LearnData(
  user: LearnUser(level: 6, xp: 1840, dayStreak: 12),
  path: LessonPath(
    id: 'preview',
    title: LocalizedText(en: 'Money Basics'),
    levelLabel: 'Level 3',
    nodes: [
      LessonNode(
        id: 'ibft',
        title: LocalizedText(en: 'What is IBFT'),
        status: LessonNodeStatus.done,
        xp: 20,
      ),
      LessonNode(
        id: 'raast',
        title: LocalizedText(en: 'Raast vs card'),
        status: LessonNodeStatus.available,
        xp: 25,
      ),
      LessonNode(
        id: 'tax',
        title: LocalizedText(en: 'Salary tax basics'),
        status: LessonNodeStatus.locked,
        xp: 25,
      ),
    ],
    lessons: [_lesson],
  ),
);

const _completeData = LearnData(
  user: LearnUser(level: 6, xp: 1910, dayStreak: 12),
  path: LessonPath(
    id: 'preview',
    title: LocalizedText(en: 'Money Basics'),
    levelLabel: 'Level 3',
    nodes: [
      LessonNode(
        id: 'ibft',
        title: LocalizedText(en: 'What is IBFT'),
        status: LessonNodeStatus.done,
        xp: 20,
      ),
      LessonNode(
        id: 'raast',
        title: LocalizedText(en: 'Raast vs card'),
        status: LessonNodeStatus.done,
        xp: 25,
      ),
      LessonNode(
        id: 'tax',
        title: LocalizedText(en: 'Salary tax basics'),
        status: LessonNodeStatus.done,
        xp: 25,
      ),
    ],
    lessons: [_lesson],
  ),
);
