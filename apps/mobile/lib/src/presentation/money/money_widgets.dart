import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../data/manual_money_store.dart';
import '../../data/mock_sprout_data.dart';
import '../../domain/sprout_models.dart';
import '../../theme/sprout_strings.dart';
import '../../theme/sprout_copy_guard.dart';
import '../../theme/sprout_theme.dart';
import '../../theme/sprout_tokens.dart';
import '../../widgets/sprout_helpers.dart';
import '../../widgets/sprout_page.dart';
import '../../widgets/sprout_panel.dart';
import '../../widgets/transaction_row.dart';

/// Copy that is specific to the Money screen. Kept local so we never touch
/// `sprout_strings.dart` (another agent may be editing it).
class _MoneyStrings {
  const _MoneyStrings._();

  static const recentTransactions = 'Recent transactions';
  static const investmentsSnapshot = 'Investments snapshot';

  static const edit = 'Edit';
  static const viewAll = 'View all';
  static const showBalances = 'Show balances';
  static const hideBalances = 'Hide balances';

  static const income = 'Income';
  static const safeToSpend = 'Safe to spend';
  static const budgetHealth = 'Budget health';

  static const healthComfortable = 'Looking comfortable. Nice pace.';
  static const healthOkay = 'Looks okay. One small action can improve this.';
  static const healthNear = 'Nearly there. Small adjustments keep it calm.';

  static const investmentsNote =
      'Investment values are estimates until updated.';
  static const mutualFunds = 'Mutual funds';
  static const cashBuffer = 'Cash buffer';
  static const foreignCurrency = 'Foreign currency savings';
  static const lastUpdated = 'Last updated';

  static const editAccount = 'Edit account';
  static const editAccountHint = 'Update the balance. Sprout saves your edit.';
  static const balanceLabel = 'Balance';
  static const updated = 'Updated';
  static const updatedReassurance = 'Saved. No bank connection needed.';
  static const allTransactions = 'All transactions';
}

/// A small section header with an optional trailing widget (e.g. a toggle).
class MoneySectionHeader extends StatelessWidget {
  const MoneySectionHeader({
    required this.title,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
          top: SproutSpacing.sm, bottom: SproutSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: colors.ink),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// A calm hide/show balances toggle. Calls back so the parent can rebuild
/// every balance section at once.
class BalanceToggle extends StatelessWidget {
  const BalanceToggle({
    required this.visible,
    required this.onToggle,
    super.key,
  });

  final bool visible;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return SproutButtonPress(
      onTap: onToggle,
      semanticLabel:
          visible ? _MoneyStrings.hideBalances : _MoneyStrings.showBalances,
      child: Semantics(
        button: true,
        toggled: visible,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: SproutColors.mint,
            borderRadius: BorderRadius.circular(SproutRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                visible
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: SproutColors.leaf,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                visible
                    ? _MoneyStrings.hideBalances
                    : _MoneyStrings.showBalances,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: SproutColors.leaf,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One account row inside the Cash and accounts panel. Tapping opens a calm
/// edit bottom sheet; the new balance persists in-session via accountsProvider.
class AccountRow extends StatelessWidget {
  const AccountRow({
    required this.account,
    required this.balanceVisible,
    super.key,
  });

  final SproutAccount account;
  final bool balanceVisible;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final accent = accountColor(account.type);
    final balanceText = balanceVisible
        ? SproutFormat.compactCurrency(account.balance)
        : SproutStrings.hiddenBalance;

    return SproutButtonPress(
      onTap: () => _AccountEditSheet.show(context, account: account),
      semanticLabel: '${_MoneyStrings.edit} ${account.name}',
      child: Semantics(
        button: true,
        label: '${account.name}, balance $balanceText',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: accent.withValues(alpha: 0.14),
                child: Icon(accountIcon(account.type), color: accent, size: 18),
              ),
              const SizedBox(width: SproutSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: colors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      account.lastUpdatedLabel,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 12, color: colors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SproutSpacing.sm),
              Flexible(
                child: Text(
                  balanceText,
                  maxLines: 2,
                  textAlign: TextAlign.end,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: colors.ink),
                ),
              ),
              const SizedBox(width: SproutSpacing.sm),
              Icon(Icons.chevron_right_rounded, color: colors.muted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// A calm edit sheet for a single account. Edits persist in-session via
/// [accountsProvider] (survives tab switches; resets on app restart).
class _AccountEditSheet extends ConsumerStatefulWidget {
  const _AccountEditSheet({required this.account});

  final SproutAccount account;

  static Future<void> show(BuildContext context,
      {required SproutAccount account}) {
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
      builder: (context) => _AccountEditSheet(account: account),
    );
  }

  @override
  ConsumerState<_AccountEditSheet> createState() => _AccountEditSheetState();
}

class _AccountEditSheetState extends ConsumerState<_AccountEditSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.account.balance}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_MoneyStrings.editAccount,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: SproutSpacing.sm),
          Text(
            _MoneyStrings.editAccountHint,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: colors.muted),
          ),
          const SizedBox(height: SproutSpacing.lg),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: _MoneyStrings.balanceLabel,
              prefixText: 'PKR ',
            ),
          ),
          const SizedBox(height: SproutSpacing.lg),
          FilledButton(
            onPressed: () {
              final parsed = int.tryParse(
                    _controller.text.replaceAll(RegExp(r'[^0-9]'), ''),
                  ) ??
                  widget.account.balance;
              ref
                  .read(accountsProvider.notifier)
                  .updateBalance(widget.account.id, parsed);
              Navigator.of(context).maybePop();
              ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                const SnackBar(
                  content: Text(_MoneyStrings.updatedReassurance),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(_MoneyStrings.updated),
          ),
        ],
      ),
    );
  }
}

/// The monthly budget panel — one progress bar, calm status copy.
class BudgetPanel extends StatelessWidget {
  const BudgetPanel(
      {required this.budget, required this.balanceVisible, super.key});

  final SproutBudget budget;
  final bool balanceVisible;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final hasBudgetData = budget.monthlyIncome > 0 ||
        budget.spent > 0 ||
        budget.safeToSpend > 0 ||
        budget.remaining > 0;
    if (!hasBudgetData) {
      const emptyCopy =
          'No budget picture yet — log income and spending to build one';
      assert(SproutCopyGuard.isHonestForEmptyFinancialState(emptyCopy));
      return SproutRaisedPanel(
        key: const ValueKey('money-budget-empty'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              budget.month,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: colors.ink),
            ),
            const SizedBox(height: SproutSpacing.md),
            Text(
              emptyCopy,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colors.muted),
            ),
          ],
        ),
      );
    }
    final progress = budget.progress;
    // Calm status copy — never scary red. Gold only when near the limit.
    final Color barColor;
    final String status;
    if (progress < 0.5) {
      barColor = SproutColors.seed;
      status = _MoneyStrings.healthComfortable;
    } else if (progress < 0.8) {
      barColor = SproutColors.seed;
      status = _MoneyStrings.healthOkay;
    } else {
      barColor = SproutColors.gold;
      status = _MoneyStrings.healthNear;
    }

    return SproutRaisedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  budget.month,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: colors.ink),
                ),
              ),
              const SizedBox(width: SproutSpacing.sm),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: barColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(SproutRadius.pill),
                  ),
                  child: Text(
                    _MoneyStrings.budgetHealth,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: barColor,
                          fontSize: 11,
                        ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SproutSpacing.lg),
          _BudgetLine(
              label: _MoneyStrings.income,
              value: balanceVisible
                  ? SproutFormat.compactCurrency(budget.monthlyIncome)
                  : '••••'),
          const SizedBox(height: SproutSpacing.sm),
          _BudgetLine(
              label: _MoneyStrings.safeToSpend,
              value: balanceVisible
                  ? SproutFormat.compactCurrency(budget.safeToSpend)
                  : '••••'),
          const SizedBox(height: SproutSpacing.md),
          SproutProgressBar(value: progress, color: barColor, height: 10),
          const SizedBox(height: SproutSpacing.sm),
          Text(
            balanceVisible
                ? '${SproutFormat.compactCurrency(budget.remaining)} left to spend'
                : 'Amounts hidden',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: colors.ink),
          ),
          const SizedBox(height: SproutSpacing.md),
          Text(status,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colors.ink)),
        ],
      ),
    );
  }
}

class _BudgetLine extends StatelessWidget {
  const _BudgetLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: colors.muted),
          ),
        ),
        const SizedBox(width: SproutSpacing.sm),
        Flexible(
          child: Text(
            value,
            maxLines: 2,
            textAlign: TextAlign.end,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: colors.ink),
          ),
        ),
      ],
    );
  }
}

/// One goal tile inside the Goals section.
class GoalTile extends StatelessWidget {
  const GoalTile({required this.goal, required this.balanceVisible, super.key});

  final SproutGoal goal;
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: colors.ink),
                ),
              ),
              Text(
                '$currentText / $targetText',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colors.muted),
              ),
            ],
          ),
          const SizedBox(height: SproutSpacing.sm),
          SproutProgressBar(
              value: progress, color: SproutColors.seed, height: 8),
          const SizedBox(height: SproutSpacing.sm),
          Text(
            goal.nextStep,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: SproutColors.leaf,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}

/// The recent transactions panel. "View all" opens a calm sheet listing every
/// transaction.
class RecentTransactionsPanel extends ConsumerWidget {
  const RecentTransactionsPanel({required this.balanceVisible, super.key});

  final bool balanceVisible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = SproutColorScheme.of(context);
    final transactions = ref.watch(visibleTransactionsProvider);
    // Show the most recent three in the panel; the sheet shows all.
    final preview = transactions.take(3).toList();

    return SproutRaisedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _MoneyStrings.recentTransactions,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: colors.ink),
                ),
              ),
              SproutButtonPress(
                onTap: () =>
                    _AllTransactionsSheet.show(context, balanceVisible),
                semanticLabel: _MoneyStrings.viewAll,
                child: Semantics(
                  button: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 14),
                    child: Text(
                      _MoneyStrings.viewAll,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: SproutColors.seed,
                            fontSize: 12,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SproutSpacing.sm),
          for (final txn in preview)
            TransactionRow(transaction: txn, balanceVisible: balanceVisible),
        ],
      ),
    );
  }
}

class _AllTransactionsSheet extends StatelessWidget {
  const _AllTransactionsSheet({required this.balanceVisible});

  final bool balanceVisible;

  static Future<void> show(BuildContext context, bool balanceVisible) {
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
      builder: (context) =>
          _AllTransactionsSheet(balanceVisible: balanceVisible),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_MoneyStrings.allTransactions,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: SproutSpacing.md),
            Consumer(
              builder: (context, ref, _) {
                final transactions = ref.watch(visibleTransactionsProvider);
                return Column(
                  children: [
                    for (final txn in transactions)
                      TransactionRow(
                          transaction: txn, balanceVisible: balanceVisible),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A basic investments snapshot — no portfolio graphs.
class InvestmentsPanel extends StatelessWidget {
  const InvestmentsPanel({required this.balanceVisible, super.key});

  final bool balanceVisible;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final funds = mockInvestments.firstWhere(
      (a) => a.id == 'al-meezan',
      orElse: () => mockInvestments.first,
    );
    final buffer = mockInvestments.firstWhere(
      (a) => a.id == 'cash-buffer',
      orElse: () => mockInvestments.first,
    );
    final fx = mockInvestments.firstWhere(
      (a) => a.id == 'wise-usd',
      orElse: () => mockInvestments.first,
    );
    final lastUpdatedValue = funds.lastUpdatedLabel;

    return SproutRaisedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _MoneyStrings.investmentsSnapshot,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: colors.ink),
          ),
          const SizedBox(height: SproutSpacing.md),
          _InvestmentLine(
            label: _MoneyStrings.mutualFunds,
            value: funds.balance,
            visible: balanceVisible,
          ),
          _InvestmentLine(
            label: _MoneyStrings.cashBuffer,
            value: buffer.balance,
            visible: balanceVisible,
          ),
          _InvestmentLine(
            label: _MoneyStrings.foreignCurrency,
            value: fx.balance,
            visible: balanceVisible,
          ),
          const SizedBox(height: SproutSpacing.md),
          Text(
            '${_MoneyStrings.lastUpdated}: $lastUpdatedValue',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 12, color: colors.muted),
          ),
          const SizedBox(height: SproutSpacing.xs),
          Text(
            _MoneyStrings.investmentsNote,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 12, color: colors.muted),
          ),
        ],
      ),
    );
  }
}

class _InvestmentLine extends StatelessWidget {
  const _InvestmentLine({
    required this.label,
    required this.value,
    required this.visible,
  });

  final String label;
  final int value;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colors.ink)),
          ),
          Text(
            visible
                ? SproutFormat.compactCurrency(value)
                : SproutStrings.hiddenBalance,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: colors.ink),
          ),
        ],
      ),
    );
  }
}
