import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout_mobile/src/data/mock_learn_repository.dart';
import 'package:sprout_mobile/src/domain/learn_models.dart';
import 'package:sprout_mobile/src/presentation/learn/learn_screen.dart';
import 'package:sprout_mobile/src/presentation/learn/learn_widgets.dart';
import 'package:sprout_mobile/src/theme/sprout_theme.dart';

void main() {
  testWidgets('LearnScreen shows loading and error states', (tester) async {
    final completer = Completer<LearnData>();
    await tester.pumpWidget(_appWithRepo(_PendingLearnRepository(completer)));

    expect(find.text('Opening your lesson path…'), findsOneWidget);

    completer.completeError(Exception('offline'));
    await tester.pumpAndSettle();

    expect(find.text('Sprout could not load Learn.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('correct answer awards XP and unlocks the next node',
      (tester) async {
    await tester.pumpWidget(_appWithRepo(MockLearnRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('What is IBFT').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take the check'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Receiver name, amount, and fee'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text('Lesson complete'), findsOneWidget);
    expect(find.textContaining('+20 XP added'), findsOneWidget);

    await tester.tap(find.text('Back to path'));
    await tester.pumpAndSettle();

    expect(find.text('Raast vs card'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
  });

  testWidgets('wrong answer is gently corrective', (tester) async {
    await tester.pumpWidget(_appWithRepo(MockLearnRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('What is IBFT').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take the check'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Only your account balance'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text('Almost. No XP lost — this is just practice.'),
        findsOneWidget);
  });

  testWidgets('golden: path with locked and available nodes', (tester) async {
    await tester.pumpWidget(_goldenHost(
      LearnContent(data: _pathData, onStartLesson: (_) {}),
    ));
    await _pumpGolden(tester);
    await expectLater(
      find.byType(LearnContent),
      matchesGoldenFile('goldens/learn_path.png'),
    );
  });

  testWidgets('golden: in-lesson card', (tester) async {
    await tester.pumpWidget(_goldenHost(
      LessonStoryCard(card: _lesson.cards.first, step: 1, total: 1),
    ));
    await _pumpGolden(tester);
    await expectLater(
      find.byType(LessonStoryCard),
      matchesGoldenFile('goldens/learn_in_lesson.png'),
    );
  });

  testWidgets('golden: result state', (tester) async {
    await tester.pumpWidget(_goldenHost(
      LessonResultCard(
        result: LessonCompletionResult(
          correct: true,
          awardedXp: 20,
          explanation: _lesson.checkQuestion.explanation.resolve(),
          data: _completeData,
        ),
        onDone: () {},
      ),
    ));
    await _pumpGolden(tester);
    await expectLater(
      find.byType(LessonResultCard),
      matchesGoldenFile('goldens/learn_result.png'),
    );
  });

  testWidgets('golden: path complete', (tester) async {
    await tester.pumpWidget(_goldenHost(
      LearnContent(data: _completeData, onStartLesson: (_) {}),
    ));
    await _pumpGolden(tester);
    await expectLater(
      find.byType(LearnContent),
      matchesGoldenFile('goldens/learn_path_complete.png'),
    );
  });
}

Widget _appWithRepo(LearnRepository repository) {
  return ProviderScope(
    overrides: [learnRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: buildSproutTheme(),
      home: const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Scaffold(body: SafeArea(child: LearnScreen())),
      ),
    ),
  );
}

Widget _goldenHost(Widget child) {
  return MaterialApp(
    theme: buildSproutTheme(),
    home: Scaffold(
      body: SafeArea(
        child: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: SizedBox(width: 390, height: 844, child: child),
        ),
      ),
    ),
  );
}

Future<void> _pumpGolden(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 250));
}

class _PendingLearnRepository implements LearnRepository {
  const _PendingLearnRepository(this.completer);

  final Completer<LearnData> completer;

  @override
  Future<LearnData> fetchLearn() => completer.future;

  @override
  Future<LessonCompletionResult> completeLesson({
    required String lessonId,
    required int selectedIndex,
  }) {
    throw UnimplementedError();
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
