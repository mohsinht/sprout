import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/manual_money_store.dart';
import '../domain/sprout_models.dart';
import '../theme/sprout_strings.dart';
import '../theme/sprout_theme.dart';
import '../theme/sprout_tokens.dart';
import 'sprout_helpers.dart';

/// One row in a recent-transactions list. Shows the source as a small badge
/// and, when the source is uncertain, a calm "Needs review" tag instead of a
/// scary warning. Dark-mode aware via [SproutColorScheme].
class TransactionRow extends ConsumerWidget {
  const TransactionRow(
      {required this.transaction, this.balanceVisible = true, super.key});

  final SproutTransaction transaction;
  final bool balanceVisible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = SproutColorScheme.of(context);
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? SproutColors.seed : colors.ink;
    final sign = isIncome ? '+' : '−';
    final srcColor = sourceColor(transaction.source);

    final row = Padding(
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
                    balanceVisible
                        ? '$sign${SproutFormat.currency(transaction.amount)}'
                        : '••••',
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
    if (!transaction.needsReview) return row;
    return Semantics(
      button: true,
      label: 'Review ${transaction.merchant}',
      child: InkWell(
        onTap: () => _review(context, ref),
        borderRadius: BorderRadius.circular(SproutRadius.tile),
        child: row,
      ),
    );
  }

  Future<void> _review(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Is this transaction correct?',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: SproutSpacing.sm),
            Text(
              'Sprout is unsure, so it waits for your tap before trusting it.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: SproutSpacing.lg),
            Text('${transaction.merchant} · ${transaction.category}'),
            Text(SproutFormat.currency(transaction.amount)),
            const SizedBox(height: SproutSpacing.lg),
            FilledButton(
              onPressed: () async {
                await ref
                    .read(manualTransactionsProvider.notifier)
                    .confirm(transaction.id);
                if (sheetContext.mounted) Navigator.pop(sheetContext);
              },
              child: const Text('Yes, count it'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(sheetContext),
              child: const Text('Not now'),
            ),
            TextButton(
              onPressed: () async {
                await ref
                    .read(manualTransactionsProvider.notifier)
                    .remove(transaction.id);
                if (sheetContext.mounted) Navigator.pop(sheetContext);
              },
              child: const Text('This is not mine'),
            ),
          ],
        ),
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
