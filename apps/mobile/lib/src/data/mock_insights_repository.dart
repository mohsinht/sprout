import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/insights_models.dart';
import '../domain/today_models.dart';
import 'http_today_repository.dart';
import 'insights_validation.dart';

abstract class InsightsRepository {
  Future<InsightsData> fetchInsights();
}

final insightsRepositoryProvider = Provider<InsightsRepository>((ref) {
  const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);
  if (useMock) return const MockInsightsRepository();
  return BriefingInsightsRepository(ref.read(todayRepositoryProvider));
});

final insightsProvider = FutureProvider<InsightsData>((ref) {
  return ref.watch(insightsRepositoryProvider).fetchInsights();
});

class MockInsightsRepository implements InsightsRepository {
  const MockInsightsRepository();

  @override
  Future<InsightsData> fetchInsights() async {
    const data = InsightsData(
      refreshedLabel: 'Mock briefing · refreshed Jul 10, 2026',
      offline: false,
      thinData: false,
      items: [
        MoneyInsight(
          id: 'sbp-rate-cut',
          category: InsightCategory.funds,
          icon: Icons.account_balance_rounded,
          headline: 'Policy rate eased',
          personalMeaning:
              'Your income funds may yield a little less; equity funds often like lower rates.',
          detail:
              'Rate cuts can reduce future income-fund yields, while equity funds may get support if companies borrow more cheaply. This is context for your Al Meezan mix, not a buy or sell signal.',
          relevanceTag: 'Al Meezan funds',
          provenance: InsightProvenance(
            sourceLabel: 'Mock SBP policy note · demo source',
            asOf: 'Jul 9, 2026',
            isMock: true,
          ),
          actionLabel: 'See holdings',
          actionKind: InsightActionKind.money,
        ),
        MoneyInsight(
          id: 'usd-pkr',
          category: InsightCategory.cash,
          icon: Icons.currency_exchange_rounded,
          headline: 'PKR softened vs USD',
          personalMeaning:
              'Your USD 1,175 Wise cash is worth a bit more in rupees this week.',
          detail:
              'A weaker PKR raises the PKR value of your USD cash. Sprout keeps this separate from spending money so the FX move does not look like salary or income.',
          relevanceTag: 'Wise USD cash',
          provenance: InsightProvenance(
            sourceLabel: 'Mock Xe FX snapshot · demo source',
            asOf: 'Jul 9, 2026',
            isMock: true,
          ),
          actionLabel: 'See Money',
          actionKind: InsightActionKind.money,
        ),
        MoneyInsight(
          id: 'car-prices',
          category: InsightCategory.goals,
          icon: Icons.directions_car_rounded,
          headline: 'Car prices moved up',
          personalMeaning:
              'Your PKR 2.5M car target may need a small review before you finish.',
          detail:
              'If the model you want became more expensive, your current target could understate the final gap. Treat this as a goal-planning prompt, not an urgent purchase signal.',
          relevanceTag: 'Car goal',
          provenance: InsightProvenance(
            sourceLabel: 'Mock Pakistan auto-market note · demo source',
            asOf: 'Jul 8, 2026',
            isMock: true,
          ),
          actionLabel: 'Adjust goal',
          actionKind: InsightActionKind.goal,
          targetId: 'car',
        ),
        MoneyInsight(
          id: 'inflation-cooler',
          category: InsightCategory.wealth,
          icon: Icons.trending_flat_rounded,
          headline: 'Inflation cooled',
          personalMeaning:
              'Your saved cash held its buying power a little better this month.',
          detail:
              'Lower inflation does not make prices fall, but it can slow how quickly everyday costs eat into saved cash. This matters for your emergency fund and PKR cash buffer.',
          relevanceTag: 'Emergency fund',
          provenance: InsightProvenance(
            sourceLabel: 'Mock Pakistan CPI briefing · demo source',
            asOf: 'Jul 5, 2026',
            isMock: true,
          ),
          actionLabel: 'Learn more',
          actionKind: InsightActionKind.learn,
        ),
      ],
    );
    validateInsights(data.items);
    return data;
  }
}

/// Production insights are projections of dated, provenance-bearing events in
/// the user's own briefing. If there is no relevant event, the honest result is
/// a quiet week rather than generic market content.
class BriefingInsightsRepository implements InsightsRepository {
  BriefingInsightsRepository(this._todayRepository);

  final TodayRepository _todayRepository;

  @override
  Future<InsightsData> fetchInsights() async {
    final today = await _todayRepository.fetchToday();
    final offline = today.provenanceSummary.contains('Waiting to sync');
    final items = today.wealthEvents.map((event) {
      final holding = today.wealthSnapshot.holdings
          .where((item) => item.id == event.holdingId)
          .firstOrNull;
      final category = switch (event.kind) {
        WealthEventKind.goalMilestone => InsightCategory.goals,
        WealthEventKind.fxMove => InsightCategory.cash,
        WealthEventKind.navMove => InsightCategory.funds,
        _ => InsightCategory.wealth,
      };
      final icon = switch (category) {
        InsightCategory.goals => Icons.flag_rounded,
        InsightCategory.cash => Icons.currency_exchange_rounded,
        InsightCategory.funds => Icons.account_balance_rounded,
        InsightCategory.wealth => Icons.trending_up_rounded,
      };
      return MoneyInsight(
        id: event.id,
        category: category,
        icon: icon,
        headline: _headline(event),
        personalMeaning: event.plainWhy,
        detail:
            '${event.plainWhy} This is based on your dated Sprout briefing, not a general market recommendation.',
        relevanceTag: holding?.label ?? 'Your money',
        provenance: InsightProvenance(
          sourceLabel: holding?.priceSource ?? 'Sprout manual record',
          asOf: event.date,
          isMock: false,
        ),
        actionLabel: holding == null ? null : 'See Money',
        actionKind:
            holding == null ? InsightActionKind.none : InsightActionKind.money,
      );
    }).toList();
    validateInsights(items);
    return InsightsData(
      items: items,
      refreshedLabel: 'From your briefing · ${today.wealthSnapshot.date}',
      offline: offline,
      thinData: items.isEmpty,
    );
  }

  String _headline(WealthEvent event) => switch (event.kind) {
        WealthEventKind.navMove => 'A holding value moved',
        WealthEventKind.fxMove => 'Currency movement affected your value',
        WealthEventKind.contribution => 'A contribution changed your picture',
        WealthEventKind.withdrawal => 'A withdrawal changed your picture',
        WealthEventKind.bill => 'A bill affected your cash',
        WealthEventKind.goalMilestone => 'A goal reached a milestone',
        WealthEventKind.newsContext => 'New context for one of your holdings',
      };
}
