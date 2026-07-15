import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/insights_models.dart';
import 'api/sprout_api_client.dart';
import 'insights_validation.dart';

abstract class InsightsRepository {
  Future<InsightsData> fetchInsights();
}

final insightsRepositoryProvider = Provider<InsightsRepository>((ref) {
  const useMock =
      String.fromEnvironment('SPROUT_ENV', defaultValue: 'production') == 'dev';
  if (useMock) return const MockInsightsRepository();
  return ApiInsightsRepository(ref.read(apiClientProvider));
});

final insightsProvider = FutureProvider<InsightsData>((ref) {
  return ref.watch(insightsRepositoryProvider).fetchInsights();
});

class MockInsightsRepository implements InsightsRepository {
  const MockInsightsRepository();

  @override
  Future<InsightsData> fetchInsights() async {
    const data = InsightsData(
      refreshedLabel: 'Development fixture · refreshed Jul 10, 2026',
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
            sourceLabel: 'Development SBP policy fixture',
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
            sourceLabel: 'Development FX fixture',
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
            sourceLabel: 'Development auto-market fixture',
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
            sourceLabel: 'Development CPI fixture',
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

class ApiInsightsRepository implements InsightsRepository {
  ApiInsightsRepository(this._client);

  final SproutApiClient _client;
  static const _cacheKey = 'insights.cache.v1';

  @override
  Future<InsightsData> fetchInsights() async {
    try {
      final response = await _client.get('/v1/insights');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(response));
      return _fromJson(response, offline: false);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached == null) rethrow;
      return _fromJson(jsonDecode(cached) as Map<String, dynamic>,
          offline: true);
    }
  }

  InsightsData _fromJson(Map<String, dynamic> json, {required bool offline}) {
    final rows =
        (json['insights'] as List? ?? const []).cast<Map<String, dynamic>>();
    final items = rows.map((row) {
      final template = row['templateId'] as String? ?? '';
      final category = row['matchedGoalId'] != null
          ? InsightCategory.goals
          : row['matchedCurrency'] != null
              ? InsightCategory.cash
              : template.startsWith('nav_move')
                  ? InsightCategory.funds
                  : InsightCategory.wealth;
      final icon = switch (category) {
        InsightCategory.goals => Icons.flag_rounded,
        InsightCategory.cash => Icons.currency_exchange_rounded,
        InsightCategory.funds => Icons.account_balance_rounded,
        InsightCategory.wealth => Icons.trending_up_rounded,
      };
      return MoneyInsight(
        id: row['id'] as String,
        category: category,
        icon: icon,
        headline: row['headline'] as String,
        personalMeaning: row['personalMeaning'] as String,
        detail: row['detail'] as String,
        relevanceTag: row['matchedCurrency'] as String? ??
            (row['matchedGoalId'] != null ? 'Your goal' : 'Your holding'),
        provenance: InsightProvenance(
          sourceLabel: row['sourceLabel'] as String,
          asOf: row['asOf'] as String,
          isMock: false,
        ),
        actionLabel: row['matchedGoalId'] != null ? 'Review goal' : 'See Money',
        actionKind: row['matchedGoalId'] != null
            ? InsightActionKind.goal
            : InsightActionKind.money,
        targetId: row['matchedGoalId'] as String? ??
            row['matchedHoldingId'] as String?,
      );
    }).toList();
    validateInsights(items);
    final asOf = items.isEmpty ? 'Quiet state' : items.first.provenance.asOf;
    return InsightsData(
        items: items,
        refreshedLabel: asOf,
        offline: offline,
        thinData: items.isEmpty);
  }
}
