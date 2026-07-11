import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/insights_models.dart';
import 'insights_validation.dart';

abstract class InsightsRepository {
  Future<InsightsData> fetchInsights();
}

final insightsRepositoryProvider = Provider<InsightsRepository>((ref) {
  return const MockInsightsRepository();
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
