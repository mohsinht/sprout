import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_sprout_data.dart';
import '../../domain/sprout_models.dart';
import '../../theme/sprout_theme.dart';
import '../../theme/sprout_tokens.dart';
import '../../widgets/sprout_panel.dart';
import '../../widgets/sprout_page.dart';
import '../../widgets/sprout_states.dart';
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
  var _balancesVisible = true;

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    // Cash/bank/wallet only here; investment + Wise live in the Investments
    // snapshot so a balance is never counted twice on the same screen.
    final cashAccounts = accounts
        .where((a) =>
            a.type != AccountType.investment && a.type != AccountType.wise)
        .toList();

    // Empty state: no accounts at all means a fresh, manual-first start.
    if (accounts.isEmpty && mockTransactions.isEmpty) {
      return SproutPage(
        title: 'Money',
        subtitle: 'A simple picture of your money.',
        children: [
          SproutEmptyView(
            title: 'You can start manually. No bank connection needed.',
            subtitle: 'Add one chai, fuel, or grocery spend and Sprout builds a calm overview from there.',
            actionLabel: 'Add first transaction',
            onAction: () => context.go('/add'),
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
            visible: _balancesVisible,
            onToggle: () => setState(() => _balancesVisible = !_balancesVisible),
          ),
        ),
        const SizedBox(height: SproutSpacing.sm),
        SproutRaisedPanel(
          child: Column(
            children: [
              for (final account in cashAccounts) ...[
                AccountRow(account: account, balanceVisible: _balancesVisible),
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
        const BudgetPanel(budget: mockBudget),

        // 3. Goals.
        const SizedBox(height: SproutSpacing.xl),
        const MoneySectionHeader(title: 'Goals'),
        const SizedBox(height: SproutSpacing.sm),
        SproutRaisedPanel(
          child: Column(
            children: [
              for (final goal in mockGoals) ...[
                GoalTile(goal: goal, balanceVisible: _balancesVisible),
                if (goal.id != mockGoals.last.id)
                  Divider(color: SproutColorScheme.of(context).line, height: 1),
              ],
            ],
          ),
        ),

        // 4. Recent transactions.
        const SizedBox(height: SproutSpacing.xl),
        const RecentTransactionsPanel(),

        // 5. Investments snapshot.
        const SizedBox(height: SproutSpacing.xl),
        const MoneySectionHeader(title: 'Investments snapshot'),
        const SizedBox(height: SproutSpacing.sm),
        InvestmentsPanel(balanceVisible: _balancesVisible),
      ],
    );
  }
}