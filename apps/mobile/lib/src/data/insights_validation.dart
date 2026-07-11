import '../domain/insights_models.dart';

/// Shared boundary for the future gather -> write -> validate pipeline.
/// Mock data runs through it too, so an unscoped or provenance-free item
/// cannot quietly reach the screen.
void validateInsights(Iterable<MoneyInsight> items) {
  final list = items.toList(growable: false);
  if (list.length > 6) {
    throw StateError('Insights must stay finite: six items maximum.');
  }

  const bannedPhrases = [
    'buy now',
    'guaranteed',
    'you will earn',
    "you're missing out",
    'missing out',
  ];

  for (final insight in list) {
    final copy =
        '${insight.headline} ${insight.personalMeaning} ${insight.detail}'
            .toLowerCase();
    if (insight.headline.trim().isEmpty ||
        insight.personalMeaning.trim().isEmpty ||
        insight.detail.trim().isEmpty) {
      throw StateError(
          'Insight ${insight.id} is missing its explanation path.');
    }
    if (insight.relevanceTag.trim().isEmpty) {
      throw StateError('Insight ${insight.id} has no personal relevance tag.');
    }
    if (insight.provenance.sourceLabel.trim().isEmpty ||
        insight.provenance.asOf.trim().isEmpty) {
      throw StateError('Insight ${insight.id} has no provenance.');
    }
    if (bannedPhrases.any(copy.contains)) {
      throw StateError('Insight ${insight.id} contains unsafe pressure copy.');
    }
  }
}
