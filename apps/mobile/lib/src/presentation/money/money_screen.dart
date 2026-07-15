import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../data/goal_store.dart';
import '../../data/balance_privacy_store.dart';
import '../../data/manual_money_store.dart';
import '../../domain/sprout_models.dart';
import '../../domain/today_models.dart';
import '../../theme/sprout_strings.dart';
import '../../theme/sprout_theme.dart';
import '../../theme/sprout_tokens.dart';
import '../../widgets/sprout_panel.dart';
import '../../widgets/sprout_page.dart';
import '../../widgets/sprout_states.dart';
import '../goals/goal_editor_sheet.dart';
import '../today/today_screen.dart' show QuickActionGrid;
import '../today/today_controller.dart';
import 'money_widgets.dart';

/// Money — a calm overview of the user's financial picture.
///
/// Not a spreadsheet, not a dashboard. Open, understand, do one small thing,
/// close calmly. Works fully with zero connected accounts (manual-only).
class MoneyScreen extends ConsumerStatefulWidget {
  const MoneyScreen({super.key});

  @override
  ConsumerState<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends ConsumerState<MoneyScreen> {
  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final transactions = ref.watch(visibleTransactionsProvider);
    final budget = ref.watch(adjustedBudgetProvider);
    final today = ref.watch(todayControllerProvider);
    final balancesVisible = ref.watch(balancesVisibleProvider);
    // Cash/bank/wallet only here; investment + Wise live in the Investments
    // snapshot so a balance is never counted twice on the same screen.
    final cashAccounts = accounts
        .where((a) =>
            a.type != AccountType.investment && a.type != AccountType.wise)
        .toList();

    // Empty state: no accounts at all means a fresh, manual-first start.
    if (accounts.isEmpty && transactions.isEmpty) {
      return SproutPage(
        title: 'Money',
        subtitle: 'A simple picture of your money.',
        children: [
          SproutEmptyView(
            title: 'You can start manually. No bank connection needed.',
            subtitle:
                'Add one chai, fuel, or grocery spend and Sprout builds a calm overview from there.',
            actionLabel: 'Add first transaction',
            onAction: () => QuickActionGrid.openQuickAdd(context),
          ),
        ],
      );
    }

    return SproutPage(
      title: 'Money',
      subtitle: 'A simple picture of your money.',
      children: [
        // 1. Cash and accounts.
        MoneySectionHeader(
          title: 'Cash and accounts',
          trailing: BalanceToggle(
            visible: balancesVisible,
            onToggle: () => ref
                .read(balancesVisibleProvider.notifier)
                .setVisible(!balancesVisible),
          ),
        ),
        const SizedBox(height: SproutSpacing.sm),
        SproutRaisedPanel(
          child: Column(
            children: [
              for (final account in cashAccounts) ...[
                AccountRow(account: account, balanceVisible: balancesVisible),
                if (account.id != cashAccounts.last.id)
                  Divider(color: SproutColorScheme.of(context).line, height: 1),
              ],
            ],
          ),
        ),

        // 2. Monthly budget.
        const SizedBox(height: SproutSpacing.xl),
        const MoneySectionHeader(title: 'Monthly budget'),
        const SizedBox(height: SproutSpacing.sm),
        BudgetPanel(budget: budget, balanceVisible: balancesVisible),

        // 3. Goals.
        const SizedBox(height: SproutSpacing.xl),
        MoneySectionHeader(
          title: 'Goals',
          trailing: SproutButtonPress(
            onTap: () {
              HapticFeedback.lightImpact();
              GoalEditorSheet.open(context);
            },
            semanticLabel: 'Add a goal',
            child: Semantics(
              button: true,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: SproutColors.mint,
                  borderRadius: BorderRadius.circular(SproutRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded,
                        color: SproutColors.leaf, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Add',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: SproutColors.leaf,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: SproutSpacing.sm),
        _GoalsPanel(balanceVisible: balancesVisible),

        // 4. Recent transactions.
        const SizedBox(height: SproutSpacing.xl),
        RecentTransactionsPanel(balanceVisible: balancesVisible),

        // 5. Investments snapshot.
        const SizedBox(height: SproutSpacing.xl),
        const MoneySectionHeader(title: 'Investments snapshot'),
        const SizedBox(height: SproutSpacing.sm),
        InvestmentsPanel(
          balanceVisible: balancesVisible,
          holdings: today.asData?.value.wealthSnapshot.holdings ?? const [],
          loading: today.isLoading,
        ),
      ],
    );
  }
}

/// Goals panel for the Money screen. Reads from [goalStoreProvider] (the
/// same store Settings uses) so edits in either place are reflected in
/// both. Tapping a goal opens the shared [GoalEditorSheet].
class _GoalsPanel extends ConsumerWidget {
  const _GoalsPanel({required this.balanceVisible});

  final bool balanceVisible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = SproutColorScheme.of(context);
    final goals = ref.watch(goalStoreProvider);

    if (goals.isEmpty) {
      return SproutRaisedPanel(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: SproutSpacing.lg,
            horizontal: SproutSpacing.md,
          ),
          child: Column(
            children: [
              Text(
                'A goal makes Today\'s "one step" meaningful.',
                style: SproutType.body(
                  color: colors.muted,
                  size: SproutTypeScale.s14,
                  weight: FontWeight.w500,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SproutSpacing.md),
              FilledButton.icon(
                onPressed: () => GoalEditorSheet.open(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add a goal'),
                style: FilledButton.styleFrom(
                  backgroundColor: SproutColors.seed,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SproutRaisedPanel(
      child: Column(
        children: [
          for (final goal in goals) ...[
            _MoneyGoalRow(goal: goal, balanceVisible: balanceVisible),
            if (goal.id != goals.last.id)
              Divider(color: colors.line, height: 1),
          ],
        ],
      ),
    );
  }
}

/// A single goal row on the Money screen. Tapping opens the shared editor.
class _MoneyGoalRow extends StatelessWidget {
  const _MoneyGoalRow({required this.goal, required this.balanceVisible});

  final Goal goal;
  final bool balanceVisible;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final progress = goal.targetAmount <= 0
        ? 0.0
        : (goal.currentAmount / goal.targetAmount).clamp(0, 1).toDouble();
    final currentText = balanceVisible
        ? SproutFormat.compactCurrency(goal.currentAmount)
        : SproutStrings.hiddenBalance;
    final targetText = SproutFormat.compactCurrency(goal.targetAmount);

    return SproutButtonPress(
      onTap: () {
        HapticFeedback.lightImpact();
        GoalEditorSheet.open(context, goal: goal);
      },
      semanticLabel: '${goal.name}. Tap to edit.',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          goal.name,
                          maxLines: 2,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: colors.ink),
                        ),
                      ),
                      if (goal.isPrimary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: SproutColors.seed.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(SproutRadius.pill),
                          ),
                          child: Text(
                            'Primary',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: SproutColors.seed,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: SproutSpacing.sm),
                Flexible(
                  child: Text(
                    '$currentText / $targetText',
                    maxLines: 2,
                    textAlign: TextAlign.end,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colors.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SproutSpacing.sm),
            SproutProgressBar(
              value: progress,
              color: SproutColors.seed,
              height: 8,
            ),
            const SizedBox(height: SproutSpacing.sm),
            Text(
              goal.status == 'complete' ? 'Complete ✓' : goal.nextStep,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: SproutColors.leaf,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
