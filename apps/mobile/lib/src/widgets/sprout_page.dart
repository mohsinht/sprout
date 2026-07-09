import 'package:flutter/material.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../presentation/shell/nav_metrics.dart';
import '../theme/sprout_tokens.dart';

class SproutPage extends StatelessWidget {
  const SproutPage({
    required this.title,
    required this.subtitle,
    required this.children,
    this.trailing,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: NavMetrics.pagePadding(context),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: SproutSpacing.xs),
                        Text(subtitle,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: SproutSpacing.lg),
              ...children,
            ].asMap().entries.map((entry) {
              return entry.value.sproutCardEntrance(
                delay: Duration(milliseconds: entry.key * 55),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class SproutProgressBar extends StatelessWidget {
  const SproutProgressBar({
    required this.value,
    required this.color,
    this.height = 9,
    super.key,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1).toDouble(),
        minHeight: height,
        color: color,
        backgroundColor: SproutColors.line.withValues(alpha: 0.65),
      ),
    );
  }
}

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    required this.recommendation,
    required this.why,
    required this.confidence,
    required this.color,
    super.key,
  });

  final String recommendation;
  final String why;
  final String confidence;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SproutSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ExplainableRow(
              label: 'Recommendation',
              value: recommendation,
              icon: Icons.lightbulb_rounded,
              color: color,
            ),
            const SizedBox(height: SproutSpacing.md),
            _ExplainableRow(
              label: 'Why',
              value: why,
              icon: Icons.psychology_alt_rounded,
              color: color,
            ),
            const SizedBox(height: SproutSpacing.md),
            _ExplainableRow(
              label: 'Confidence',
              value: confidence,
              icon: Icons.verified_user_rounded,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExplainableRow extends StatelessWidget {
  const _ExplainableRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 21),
        const SizedBox(width: SproutSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
