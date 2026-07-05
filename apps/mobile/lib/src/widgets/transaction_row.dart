import 'package:flutter/material.dart';

import '../domain/sprout_models.dart';
import '../theme/sprout_strings.dart';
import '../theme/sprout_theme.dart';
import '../theme/sprout_tokens.dart';
import 'sprout_helpers.dart';

/// One row in a recent-transactions list. Shows the source as a small badge
/// and, when the source is uncertain, a calm "Needs review" tag instead of a
/// scary warning. Dark-mode aware via [SproutColorScheme].
class TransactionRow extends StatelessWidget {
  const TransactionRow({required this.transaction, super.key});

  final SproutTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? SproutColors.seed : colors.ink;
    final sign = isIncome ? '+' : '−';
    final srcColor = sourceColor(transaction.source);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: srcColor.withValues(alpha: 0.14),
            child:
                Icon(sourceIcon(transaction.source), color: srcColor, size: 18),
          ),
          const SizedBox(width: SproutSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.merchant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: colors.ink),
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: SproutSpacing.sm,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      transaction.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: colors.muted),
                    ),
                    _SourceChip(source: transaction.source),
                    if (transaction.needsReview) const _NeedsReviewChip(),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 96, maxWidth: 132),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$sign${SproutFormat.currency(transaction.amount)}',
                    maxLines: 1,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: amountColor),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  SproutFormat.date(transaction.date),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 12, color: colors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.source});

  final TransactionSource source;

  @override
  Widget build(BuildContext context) {
    final color = sourceColor(source);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(SproutRadius.pill),
      ),
      child: Text(
        sourceLabel(source),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontSize: 11,
            ),
      ),
    );
  }
}

class _NeedsReviewChip extends StatelessWidget {
  const _NeedsReviewChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: SproutColors.gold.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(SproutRadius.pill),
      ),
      child: Text(
        'Needs review',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: SproutColors.goldInk,
              fontSize: 11,
            ),
      ),
    );
  }
}
