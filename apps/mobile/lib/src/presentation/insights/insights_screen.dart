import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../data/mock_insights_repository.dart';
import '../../data/goal_store.dart';
import '../../domain/insights_models.dart';
import '../../domain/today_models.dart';
import '../../theme/sprout_tokens.dart';
import '../../theme/sprout_theme.dart';
import '../../widgets/sprout_page.dart';
import '../../widgets/sprout_panel.dart';
import '../../widgets/sprout_states.dart';
import '../goals/goal_editor_sheet.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(insightsProvider);
    return insights.when(
      data: (data) => _InsightsContent(data: data),
      loading: () =>
          const SproutLoadingView(label: 'Gathering what matters...'),
      error: (error, stackTrace) => SproutErrorView(
        message:
            'I could not refresh insights, so your last calm money picture is still safe.',
        onRetry: () => ref.invalidate(insightsProvider),
      ),
    );
  }
}

class _InsightsContent extends StatelessWidget {
  const _InsightsContent({required this.data});

  final InsightsData data;

  @override
  Widget build(BuildContext context) {
    if (data.items.isEmpty) {
      return SproutPage(
        title: 'Insights',
        subtitle: data.offline
            ? 'Offline. Showing your last cached insight state.'
            : 'Nothing major moved your money this week.',
        children: const [
          SproutEmptyView(
            icon: Icons.explore_rounded,
            title: "Quiet week. That's useful too.",
            subtitle:
                'Sprout will not pad this with generic market noise. If something touches your holdings, goals, or cash, it will show up here.',
          ),
        ],
      );
    }

    return SproutPage(
      title: 'Insights',
      subtitle: 'A few things worth knowing about your money this week.',
      children: [
        _FreshnessStrip(data: data),
        for (final group in _groupInsights(data.items)) ...[
          const SizedBox(height: SproutSpacing.md),
          _GroupHeader(label: group.label),
          const SizedBox(height: SproutSpacing.sm),
          for (final insight in group.items) ...[
            _InsightCard(insight: insight),
            const SizedBox(height: SproutSpacing.md),
          ],
        ],
      ],
    );
  }
}

class _FreshnessStrip extends StatelessWidget {
  const _FreshnessStrip({required this.data});

  final InsightsData data;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SproutSpacing.lg,
        vertical: SproutSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.mint,
        borderRadius: BorderRadius.circular(SproutRadius.tile),
        border: Border.all(color: colors.line),
      ),
      child: Row(
        children: [
          Icon(
            data.offline ? Icons.cloud_off_rounded : Icons.verified_rounded,
            color: SproutColors.seed,
            size: 18,
          ),
          const SizedBox(width: SproutSpacing.sm),
          Expanded(
            child: Text(
              data.offline
                  ? 'Offline. Showing cached insights from ${data.refreshedLabel}.'
                  : data.refreshedLabel,
              style: SproutType.body(
                color: colors.ink,
                size: SproutTypeScale.s14,
                weight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Text(
      label,
      style: SproutType.playfulLabel(
        color: colors.ink,
        size: SproutTypeScale.s14,
        weight: FontWeight.w700,
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final MoneyInsight insight;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final accent = _categoryAccent(insight.category, context);
    return SproutButtonPress(
      onTap: () {
        HapticFeedback.lightImpact();
        _InsightDetailSheet.show(context, insight: insight);
      },
      semanticLabel: '${insight.headline}. ${insight.personalMeaning}',
      scale: 0.98,
      child: SproutRaisedPanel(
        padding: const EdgeInsets.all(SproutSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: accent.withValues(alpha: 0.16),
              child: Icon(insight.icon, color: accent, size: 21),
            ),
            const SizedBox(width: SproutSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          insight.headline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: colors.ink),
                        ),
                      ),
                      const SizedBox(width: SproutSpacing.sm),
                      Icon(Icons.chevron_right_rounded,
                          color: colors.muted, size: 22),
                    ],
                  ),
                  const SizedBox(height: SproutSpacing.xs),
                  Text(
                    insight.personalMeaning,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: SproutType.body(
                      color: colors.muted,
                      size: SproutTypeScale.s14,
                      weight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: SproutSpacing.md),
                  _RelevancePill(label: insight.relevanceTag, color: accent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RelevancePill extends StatelessWidget {
  const _RelevancePill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(SproutRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: SproutType.body(
          color: color,
          size: 12,
          weight: FontWeight.w800,
          height: 1.1,
        ),
      ),
    );
  }
}

class _InsightDetailSheet extends StatelessWidget {
  const _InsightDetailSheet({required this.insight});

  final MoneyInsight insight;

  static Future<void> show(
    BuildContext context, {
    required MoneyInsight insight,
  }) {
    final colors = SproutColorScheme.of(context);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(SproutRadius.hero)),
      ),
      builder: (_) => _InsightDetailSheet(insight: insight),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final accent = _categoryAccent(insight.category, context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: accent.withValues(alpha: 0.16),
                child: Icon(insight.icon, color: accent, size: 22),
              ),
              const SizedBox(width: SproutSpacing.md),
              Expanded(
                child: Text(
                  insight.headline,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: SproutSpacing.lg),
          _DetailBlock(
            icon: Icons.person_pin_circle_rounded,
            label: 'What it means for you',
            value: insight.personalMeaning,
            color: accent,
          ),
          _DetailBlock(
            icon: Icons.lightbulb_rounded,
            label: 'Plain-language detail',
            value: insight.detail,
            color: accent,
          ),
          _DetailBlock(
            icon: Icons.verified_rounded,
            label: 'Source',
            value: insight.provenance.displayLabel,
            color: accent,
          ),
          if (insight.actionLabel != null) ...[
            const SizedBox(height: SproutSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _runAction(context, insight.actionKind),
                icon: Icon(_actionIcon(insight.actionKind)),
                label: Text(insight.actionLabel!),
              ),
            ),
          ] else ...[
            const SizedBox(height: SproutSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Got it'),
              ),
            ),
          ],
          const SizedBox(height: SproutSpacing.sm),
          Text(
            'Context only. No guaranteed returns, no buy/sell advice.',
            style: SproutType.body(
              color: colors.muted,
              size: SproutTypeScale.s14,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _runAction(BuildContext context, InsightActionKind kind) {
    Navigator.of(context).maybePop();
    switch (kind) {
      case InsightActionKind.money:
        context.go('/money');
      case InsightActionKind.goal:
        final goals =
            ProviderScope.containerOf(context).read(goalStoreProvider);
        Goal? goal;
        for (final candidate in goals) {
          if (candidate.id == insight.targetId) {
            goal = candidate;
            break;
          }
        }
        GoalEditorSheet.open(context, goal: goal);
      case InsightActionKind.learn:
        context.go('/learn');
      case InsightActionKind.none:
        break;
    }
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: SproutSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.14),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: SproutSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: SproutType.body(
                    color: colors.muted,
                    size: SproutTypeScale.s14,
                    weight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightGroup {
  const _InsightGroup({required this.label, required this.items});

  final String label;
  final List<MoneyInsight> items;
}

List<_InsightGroup> _groupInsights(List<MoneyInsight> items) {
  final groups = <_InsightGroup>[];
  void add(String label, InsightCategory category) {
    final groupItems =
        items.where((item) => item.category == category).toList();
    if (groupItems.isNotEmpty) {
      groups.add(_InsightGroup(label: label, items: groupItems));
    }
  }

  add('Affects your funds', InsightCategory.funds);
  add('Affects your cash', InsightCategory.cash);
  add('Affects your goals', InsightCategory.goals);
  add('Affects your wealth', InsightCategory.wealth);
  return groups;
}

Color _categoryAccent(InsightCategory category, BuildContext context) {
  final isDark = SproutColorScheme.of(context).brightness == Brightness.dark;
  return switch (category) {
    InsightCategory.funds => isDark ? SproutColors.darkSeed : SproutColors.seed,
    InsightCategory.goals =>
      isDark ? SproutColors.darkLilac : SproutColors.lilac,
    InsightCategory.cash => isDark ? SproutColors.darkSky : SproutColors.sky,
    InsightCategory.wealth =>
      isDark ? SproutColors.darkGold : SproutColors.goldInk,
  };
}

IconData _actionIcon(InsightActionKind kind) {
  return switch (kind) {
    InsightActionKind.money => Icons.account_balance_wallet_rounded,
    InsightActionKind.goal => Icons.flag_rounded,
    InsightActionKind.learn => Icons.menu_book_rounded,
    InsightActionKind.none => Icons.check_rounded,
  };
}
