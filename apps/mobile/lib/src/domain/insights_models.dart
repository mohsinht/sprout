import 'package:flutter/material.dart';

enum InsightCategory { funds, goals, cash, wealth }

enum InsightActionKind { none, money, goal, learn }

class InsightProvenance {
  const InsightProvenance({
    required this.sourceLabel,
    required this.asOf,
    required this.isMock,
  });

  final String sourceLabel;
  final String asOf;
  final bool isMock;

  String get displayLabel => '$sourceLabel · $asOf';
}

class MoneyInsight {
  const MoneyInsight({
    required this.id,
    required this.category,
    required this.icon,
    required this.headline,
    required this.personalMeaning,
    required this.detail,
    required this.relevanceTag,
    required this.provenance,
    required this.actionLabel,
    required this.actionKind,
    this.targetId,
  });

  final String id;
  final InsightCategory category;
  final IconData icon;
  final String headline;
  final String personalMeaning;
  final String detail;
  final String relevanceTag;
  final InsightProvenance provenance;
  final String? actionLabel;
  final InsightActionKind actionKind;
  final String? targetId;
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
