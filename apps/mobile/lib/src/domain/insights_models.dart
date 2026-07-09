import 'package:flutter/material.dart';

enum InsightCategory { funds, goals, cash, wealth }

enum InsightActionKind { none, money, goal, learn }

class MoneyInsight {
  const MoneyInsight({
    required this.id,
    required this.category,
    required this.icon,
    required this.headline,
    required this.personalMeaning,
    required this.detail,
    required this.relevanceTag,
    required this.source,
    required this.asOf,
    required this.actionLabel,
    required this.actionKind,
  });

  final String id;
  final InsightCategory category;
  final IconData icon;
  final String headline;
  final String personalMeaning;
  final String detail;
  final String relevanceTag;
  final String source;
  final String asOf;
  final String? actionLabel;
  final InsightActionKind actionKind;
}

class InsightsData {
  const InsightsData({
    required this.items,
    required this.refreshedLabel,
    required this.offline,
    required this.thinData,
  });

  final List<MoneyInsight> items;
  final String refreshedLabel;
  final bool offline;
  final bool thinData;
}
