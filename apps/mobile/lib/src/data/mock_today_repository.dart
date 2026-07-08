import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/today_models.dart';

final todayRepositoryProvider = Provider<TodayRepository>((ref) {
  return MockTodayRepository();
});

abstract interface class TodayRepository {
  Future<TodayData> fetchToday();
}

class MockTodayRepository implements TodayRepository {
  @override
  Future<TodayData> fetchToday() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    const holdings = [
      Holding(
        id: 'meezan',
        kind: HoldingKind.mutualFund,
        institution: 'Al Meezan',
        label: 'Al Meezan funds',
        currency: 'PKR',
        valuePkr: 5390000,
        valueNative: 5390000,
        units: 53900,
        price: PriceQuote(
          value: 100.18,
          asOf: '2026-07-08',
          source: 'Al Meezan redemption prices',
        ),
        priceAsOf: '2026-07-08',
        priceSource: 'Al Meezan redemption prices',
        freshness: 'fresh',
        changeVsYesterday: -39000,
        changeMtd: 21000,
        detail: '5 funds · equity + income',
      ),
      Holding(
        id: 'wise-eur',
        kind: HoldingKind.cash,
        institution: 'Wise',
        label: 'Wise EUR cash',
        currency: 'EUR',
        valuePkr: 7960000,
        valueNative: 25060,
        fxRate: FxRate(
          pair: 'EUR/PKR',
          value: 317.54,
          asOf: '2026-07-09',
          source: 'Xe',
        ),
        priceAsOf: '2026-07-09',
        priceSource: 'Xe FX',
        freshness: 'fresh',
        changeVsYesterday: 2000,
        changeMtd: 15000,
        detail: '€25,060 · @ 317.54',
      ),
      Holding(
        id: 'wise-usd',
        kind: HoldingKind.cash,
        institution: 'Wise',
        label: 'Wise USD cash',
        currency: 'USD',
        valuePkr: 327000,
        valueNative: 1175,
        fxRate: FxRate(
          pair: 'USD/PKR',
          value: 277.99,
          asOf: '2026-07-09',
          source: 'Xe',
        ),
        priceAsOf: '2026-07-09',
        priceSource: 'Xe FX',
        freshness: 'fresh',
        changeVsYesterday: 0,
        changeMtd: 0,
        detail: '\$1,175 · @ 277.99',
      ),
      Holding(
        id: 'pkr-cash',
        kind: HoldingKind.cash,
        institution: 'Cash',
        label: 'PKR cash',
        currency: 'PKR',
        valuePkr: 0,
        valueNative: 0,
        priceAsOf: '2026-07-09',
        priceSource: 'Manual',
        freshness: 'manual',
        changeVsYesterday: 0,
        changeMtd: 0,
        detail: 'ready to spend',
      ),
    ];

    const wealthSnapshot = WealthSnapshot(
      date: '2026-07-09',
      totalPkr: 13677000,
      holdings: holdings,
      changeVsYesterday: -38490,
      changeMtd: 14831,
      mainReason: 'NAV movement',
      interpretation: [
        "Al Meezan pulled back after yesterday's strong jump, mostly an equity NAV correction — about −39k.",
        'Your Wise EUR balance rose slightly on FX (+2k) but not enough to offset it.',
        'USD and PKR were flat.',
        'Net for the day: −38,490. You\'re still +14,831 since the month began.',
      ],
      provenanceSummary:
          'Valued using Al Meezan redemption prices (8 Jul 2026) and Xe FX: USD 277.99, EUR 317.54. Units reconciled with your statement.',
    );

    const wealthEvents = [
      WealthEvent(
        id: 'nav-pullback',
        date: '2026-07-09',
        kind: WealthEventKind.navMove,
        magnitudePkr: -39000,
        direction: 'down',
        plainWhy:
            "Al Meezan pulled back after yesterday's strong jump, mostly an equity NAV correction.",
        holdingId: 'meezan',
        learnMoreId: 'nav-explainer',
        severity: 'heads_up',
      ),
      WealthEvent(
        id: 'eur-fx-up',
        date: '2026-07-09',
        kind: WealthEventKind.fxMove,
        magnitudePkr: 2000,
        direction: 'up',
        plainWhy: 'Your Wise EUR balance rose slightly on FX.',
        holdingId: 'wise-eur',
        severity: 'all_good',
      ),
    ];

    const goals = [
      Goal(
        id: 'car',
        name: 'Car fund',
        type: 'car',
        targetAmount: 2500000,
        currentAmount: 2300000,
        status: 'active',
        pace: 'on_track',
        nextStep: 'Add PKR 25k → only 2 lakh to your car',
        remainingToTarget: 200000,
        paceNote: 'Only PKR 2 lakh to go — closest goal.',
      ),
      Goal(
        id: 'emergency',
        name: 'Emergency fund',
        type: 'emergency',
        targetAmount: 1500000,
        currentAmount: 1500000,
        status: 'complete',
        pace: 'ahead',
        nextStep: 'Fully funded. Doing its job.',
        remainingToTarget: 0,
        paceNote: '6 months of cover. Doing its job.',
      ),
    ];

    const learnThreads = [
      LearnThread(
        id: 'nav-explainer',
        title: 'Why did my funds dip today?',
        summary: '2-min read on how NAVs move',
        body:
            'Mutual fund NAVs move daily based on the underlying securities. Equity funds track the stock market; income funds are steadier. A single-day dip after a jump is normal noise, not a trend.',
        relatedEventId: 'nav-pullback',
      ),
    ];

    return TodayData(
      user: const SproutUser(
        firstName: 'Mohsin',
        level: 6,
        xp: 1840,
        dayStreak: 12,
      ),
      currency: 'PKR',
      salary: SalaryInfo(
        nextPayday: DateTime(2026, 7, 6),
        daysUntilSalary: 3,
      ),
      health: const FinancialHealthScore(
        score: 78,
        status: 'healthy',
        summary:
            "Down a little today — your funds took a tea break after yesterday's jump. Not a crash. You're still up for the month.",
        positiveFactors: [
          'Emergency buffer is strong',
          'Salary lands in 3 days',
          'Al Meezan NAV updated yesterday',
        ],
        attentionFactors: [
          'Spending pace is slightly high',
          '3 transactions need confirmation',
        ],
        recommendedAction: RecommendedAction(
          title: 'Add PKR 25k → only 2 lakh to your car',
          xp: 20,
          impact: '+3 health score',
        ),
      ),
      autoCapture: const [
        AutoCaptureSource(
          label: 'Gmail connected',
          status: 'connected',
          detail: 'Finance senders only',
        ),
        AutoCaptureSource(
          label: 'Meezan alerts detected',
          status: 'detected',
          detail: '2 alerts today',
        ),
        AutoCaptureSource(
          label: 'Wise balance imported',
          status: 'imported',
          detail: 'USD and EUR balances',
        ),
        AutoCaptureSource(
          label: 'Al Meezan NAV updated',
          status: 'updated',
          detail: 'Updated yesterday',
        ),
        AutoCaptureSource(
          label: '3 transactions need confirmation',
          status: 'needs_review',
          detail: 'Tap to review',
        ),
      ],
      snapshot: const TodaySnapshot(
        availableCash: 168500,
        monthSpent: 216400,
        budgetRemaining: 83500,
        upcomingBills: 42000,
        unconfirmedTransactions: 3,
      ),
      quickActions: const [
        'Chai',
        'Fuel',
        'Groceries',
        'IBFT',
        'Utility Bill',
        'JazzCash',
        'Easypaisa',
        'Al Meezan Top-up',
        'Wise Transfer',
      ],
      wealthSnapshot: wealthSnapshot,
      wealthEvents: wealthEvents,
      goals: goals,
      learnThreads: learnThreads,
      provenanceSummary: wealthSnapshot.provenanceSummary,
    );
  }
}
