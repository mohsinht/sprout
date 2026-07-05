import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/learn_models.dart';

final learnRepositoryProvider = Provider<LearnRepository>((ref) {
  return MockLearnRepository();
});

/// Repository boundary for the Learn feature; swap this for HTTP later.
abstract interface class LearnRepository {
  Future<LearnData> fetchLearn();

  Future<LessonCompletionResult> completeLesson({
    required String lessonId,
    required int selectedIndex,
  });
}

/// In-memory Learn repository that mirrors the backend mock payload.
class MockLearnRepository implements LearnRepository {
  LearnData _data = _initialLearnData;

  @override
  Future<LearnData> fetchLearn() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _data;
  }

  @override
  Future<LessonCompletionResult> completeLesson({
    required String lessonId,
    required int selectedIndex,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final lesson = _data.path.lessonFor(lessonId);
    if (lesson == null) {
      return LessonCompletionResult(
        correct: false,
        awardedXp: 0,
        explanation: 'This lesson is not ready yet.',
        data: _data,
      );
    }

    final correct = selectedIndex == lesson.checkQuestion.correctIndex;
    if (!correct) {
      return LessonCompletionResult(
        correct: false,
        awardedXp: 0,
        explanation: lesson.checkQuestion.explanation.resolve(),
        data: _data,
      );
    }

    final nodeIndex =
        _data.path.nodes.indexWhere((node) => node.id == lessonId);
    if (nodeIndex < 0 ||
        _data.path.nodes[nodeIndex].status == LessonNodeStatus.done) {
      return LessonCompletionResult(
        correct: true,
        awardedXp: 0,
        explanation: lesson.checkQuestion.explanation.resolve(),
        data: _data,
      );
    }

    final updatedNodes = [
      for (var i = 0; i < _data.path.nodes.length; i++)
        if (i == nodeIndex)
          _data.path.nodes[i].copyWith(status: LessonNodeStatus.done)
        else if (i == nodeIndex + 1 &&
            _data.path.nodes[i].status == LessonNodeStatus.locked)
          _data.path.nodes[i].copyWith(status: LessonNodeStatus.available)
        else
          _data.path.nodes[i],
    ];
    final awardedXp = _data.path.nodes[nodeIndex].xp;
    _data = _data.copyWith(
      user: _data.user.copyWith(xp: _data.user.xp + awardedXp),
      path: _data.path.copyWith(nodes: updatedNodes),
    );

    return LessonCompletionResult(
      correct: true,
      awardedXp: awardedXp,
      explanation: lesson.checkQuestion.explanation.resolve(),
      data: _data,
    );
  }
}

const _initialLearnData = LearnData(
  user: LearnUser(level: 6, xp: 1840, dayStreak: 12),
  path: LessonPath(
    id: 'money-basics-pk',
    title: LocalizedText(en: 'Money Basics', ur: 'پیسے کی بنیادی باتیں'),
    levelLabel: 'Level 3',
    nodes: [
      LessonNode(
        id: 'ibft',
        title: LocalizedText(en: 'What is IBFT', ur: 'آئی بی ایف ٹی کیا ہے'),
        status: LessonNodeStatus.available,
        xp: 20,
      ),
      LessonNode(
        id: 'raast-vs-card',
        title: LocalizedText(en: 'Raast vs card', ur: 'راست یا کارڈ'),
        status: LessonNodeStatus.locked,
        xp: 25,
      ),
      LessonNode(
        id: 'salary-tax-basics',
        title: LocalizedText(
          en: 'Salary tax basics',
          ur: 'تنخواہ ٹیکس کی بنیاد',
        ),
        status: LessonNodeStatus.locked,
        xp: 25,
      ),
      LessonNode(
        id: 'cash-buffer',
        title: LocalizedText(
          en: 'What is a cash buffer',
          ur: 'کیش بفر کیا ہے',
        ),
        status: LessonNodeStatus.locked,
        xp: 20,
      ),
      LessonNode(
        id: 'emergency-fund',
        title: LocalizedText(
          en: 'Emergency fund basics',
          ur: 'ایمرجنسی فنڈ کی بنیاد',
        ),
        status: LessonNodeStatus.locked,
        xp: 25,
      ),
      LessonNode(
        id: 'inflation-savings',
        title: LocalizedText(
          en: 'Inflation and your savings',
          ur: 'مہنگائی اور بچت',
        ),
        status: LessonNodeStatus.locked,
        xp: 30,
      ),
      LessonNode(
        id: 'mutual-fund',
        title: LocalizedText(
          en: 'What is a mutual fund',
          ur: 'مٹوئل فنڈ کیا ہے',
        ),
        status: LessonNodeStatus.locked,
        xp: 20,
      ),
      LessonNode(
        id: 'zakat-savings',
        title: LocalizedText(
          en: 'Zakat and savings',
          ur: 'زکات اور بچت',
        ),
        status: LessonNodeStatus.locked,
        xp: 25,
      ),
    ],
    lessons: [
      Lesson(
        id: 'ibft',
        cards: [
          LessonCard(
            title: LocalizedText(en: 'IBFT moves money between banks'),
            body: LocalizedText(
              en: 'IBFT is the everyday bank-to-bank transfer you use from Meezan, HBL, UBL, JazzCash, Easypaisa, and other apps.',
            ),
          ),
          LessonCard(
            title: LocalizedText(en: 'Check the name before sending'),
            body: LocalizedText(
              en: 'The safest habit is tiny: confirm the receiver name, amount, and fee before you tap send.',
            ),
          ),
        ],
        checkQuestion: CheckQuestion(
          prompt: LocalizedText(en: 'Before an IBFT, what should you confirm?'),
          options: [
            LocalizedText(en: 'Receiver name, amount, and fee'),
            LocalizedText(en: 'Only your account balance'),
            LocalizedText(en: 'The chai category'),
          ],
          correctIndex: 0,
          explanation: LocalizedText(
            en: 'Exactly. A quick name, amount, and fee check prevents most transfer mistakes.',
          ),
        ),
      ),
      Lesson(
        id: 'raast-vs-card',
        cards: [
          LessonCard(
            title: LocalizedText(en: 'Raast is built for instant transfers'),
            body: LocalizedText(
              en: 'Raast often works well for quick person-to-person payments without sharing long account numbers.',
            ),
          ),
          LessonCard(
            title: LocalizedText(en: 'Cards are better for merchant records'),
            body: LocalizedText(
              en: 'For groceries, fuel, and subscriptions, cards can leave a cleaner receipt trail for your budget.',
            ),
          ),
        ],
        checkQuestion: CheckQuestion(
          prompt: LocalizedText(
            en: 'Which choice usually gives a cleaner spending record?',
          ),
          options: [
            LocalizedText(en: 'Card payment at the merchant'),
            LocalizedText(en: 'Cash with no note'),
          ],
          correctIndex: 0,
          explanation: LocalizedText(
            en: 'Nice. Cards can make later review easier because the merchant name is usually captured.',
          ),
        ),
      ),
      Lesson(
        id: 'salary-tax-basics',
        cards: [
          LessonCard(
            title: LocalizedText(en: 'Gross and net salary are different'),
            body: LocalizedText(
              en: 'Gross salary is before deductions. Net salary is what lands in your account after tax, provident fund, and other deductions.',
            ),
          ),
          LessonCard(
            title: LocalizedText(en: 'Plan from net salary'),
            body: LocalizedText(
              en: 'Your monthly budget should use the amount that actually arrives in your salary account.',
            ),
          ),
        ],
        checkQuestion: CheckQuestion(
          prompt: LocalizedText(
            en: 'Which salary number should drive your monthly budget?',
          ),
          options: [
            LocalizedText(en: 'Net salary'),
            LocalizedText(en: 'Gross salary'),
          ],
          correctIndex: 0,
          explanation: LocalizedText(
            en: 'Correct. Net salary is the money you can actually assign to bills, committee, Zakat, and savings.',
          ),
        ),
      ),
      Lesson(
        id: 'cash-buffer',
        cards: [
          LessonCard(
            title: LocalizedText(
              en: 'A cash buffer covers the days before salary',
            ),
            body: LocalizedText(
              en: 'A cash buffer is money you keep aside for the days just '
                  'before salary. It stops you from borrowing or skipping '
                  'bills.',
            ),
          ),
          LessonCard(
            title: LocalizedText(
              en: 'A small buffer keeps surprises small',
            ),
            body: LocalizedText(
              en: 'Keeping PKR 10,000 aside means a surprise bill on the '
                  '28th does not worry you.',
            ),
          ),
          LessonCard(
            title: LocalizedText(en: 'A tiny step you can take today'),
            body: LocalizedText(
              en: 'Move PKR 2,000 to your cash buffer today.',
            ),
          ),
        ],
        checkQuestion: CheckQuestion(
          prompt: LocalizedText(en: 'What is a cash buffer for?'),
          options: [
            LocalizedText(
              en: 'Money kept aside for the days before salary',
            ),
            LocalizedText(en: 'Money for treats and outings'),
            LocalizedText(en: 'A type of credit card'),
          ],
          correctIndex: 0,
          explanation: LocalizedText(
            en: 'Yes. A small buffer is just money set aside so the days '
                'before salary feel calmer.',
          ),
        ),
      ),
      Lesson(
        id: 'emergency-fund',
        cards: [
          LessonCard(
            title: LocalizedText(
              en: 'An emergency fund is a few months of expenses',
            ),
            body: LocalizedText(
              en: 'An emergency fund is 1 to 3 months of expenses kept aside '
                  'for real surprises, not treats.',
            ),
          ),
          LessonCard(
            title: LocalizedText(en: 'Start with one month of expenses'),
            body: LocalizedText(
              en: 'If you spend PKR 80,000 a month, aim for PKR 80,000+ '
                  'first.',
            ),
          ),
          LessonCard(
            title: LocalizedText(en: 'Pick a starting amount this month'),
            body: LocalizedText(
              en: 'Pick one amount to start your emergency fund this month.',
            ),
          ),
        ],
        checkQuestion: CheckQuestion(
          prompt: LocalizedText(en: 'What size is an emergency fund?'),
          options: [
            LocalizedText(en: '1 to 3 months of expenses'),
            LocalizedText(en: 'One week of chai money'),
            LocalizedText(en: 'Your full year salary'),
          ],
          correctIndex: 0,
          explanation: LocalizedText(
            en: 'Right. One to three months of expenses is a calm, reachable '
                'target.',
          ),
        ),
      ),
      Lesson(
        id: 'inflation-savings',
        cards: [
          LessonCard(
            title: LocalizedText(en: 'Inflation shrinks idle cash'),
            body: LocalizedText(
              en: 'If prices rise faster than your cash grows, the same PKR buys less chai, fuel, and groceries later.',
            ),
          ),
          LessonCard(
            title: LocalizedText(en: 'Match money to timing'),
            body: LocalizedText(
              en: 'Keep near-term bills in cash. Longer-term goals can sit in safer growth buckets after you understand the risk.',
            ),
          ),
        ],
        checkQuestion: CheckQuestion(
          prompt: LocalizedText(
            en: 'What does inflation do to cash that sits idle?',
          ),
          options: [
            LocalizedText(en: 'It can reduce buying power'),
            LocalizedText(en: 'It guarantees profit'),
          ],
          correctIndex: 0,
          explanation: LocalizedText(
            en: 'Yes. Inflation is not a reason to rush, but it is a reason to plan calmly.',
          ),
        ),
      ),
      Lesson(
        id: 'mutual-fund',
        cards: [
          LessonCard(
            title: LocalizedText(
              en: 'A mutual fund pools many people money',
            ),
            body: LocalizedText(
              en: 'A mutual fund pools money from many people and invests '
                  'it. You own small units of the whole pool.',
            ),
          ),
          LessonCard(
            title: LocalizedText(en: 'You can start small in Pakistan'),
            body: LocalizedText(
              en: 'Al Meezan and NBP funds let you start with a few thousand.',
            ),
          ),
          LessonCard(
            title: LocalizedText(en: 'A tiny way to learn more'),
            body: LocalizedText(
              en: 'Look up one mutual fund name you have heard of.',
            ),
          ),
        ],
        checkQuestion: CheckQuestion(
          prompt: LocalizedText(en: 'What does a mutual fund do?'),
          options: [
            LocalizedText(
              en: 'Pools money from many people to invest together',
            ),
            LocalizedText(en: 'Guarantees no losses'),
            LocalizedText(en: 'Lends you cash before salary'),
          ],
          correctIndex: 0,
          explanation: LocalizedText(
            en: 'Correct. Pooling lets you own small units without picking '
                'investments alone.',
          ),
        ),
      ),
      Lesson(
        id: 'zakat-savings',
        cards: [
          LessonCard(
            title: LocalizedText(
              en: 'Zakat applies to savings held for a lunar year',
            ),
            body: LocalizedText(
              en: 'Zakat is 2.5 percent of savings you have held for a '
                  'lunar year above a threshold (nisab).',
            ),
          ),
          LessonCard(
            title: LocalizedText(en: 'A simple way to estimate it'),
            body: LocalizedText(
              en: 'On PKR 500,000 of qualifying savings, zakat is PKR 12,500.',
            ),
          ),
          LessonCard(
            title: LocalizedText(en: 'A small step you can take'),
            body: LocalizedText(
              en: 'Note roughly how much savings you have held for a year.',
            ),
          ),
        ],
        checkQuestion: CheckQuestion(
          prompt: LocalizedText(
            en: 'When does zakat apply to savings?',
          ),
          options: [
            LocalizedText(
              en: 'When savings are held for a lunar year above nisab',
            ),
            LocalizedText(en: 'Only on salary day'),
            LocalizedText(en: 'On every chai purchase'),
          ],
          correctIndex: 0,
          explanation: LocalizedText(
            en: 'Yes. Holding savings above nisab for a lunar year is the '
                'calm trigger to set aside 2.5 percent.',
          ),
        ),
      ),
    ],
  ),
);
