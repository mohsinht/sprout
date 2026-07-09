import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/sprout_models.dart';
import 'mock_sprout_data.dart';

final accountsProvider =
    StateNotifierProvider<AccountsNotifier, List<SproutAccount>>(
  (ref) => AccountsNotifier(),
);

class AccountsNotifier extends StateNotifier<List<SproutAccount>> {
  AccountsNotifier() : super(mockAccounts);

  void updateBalance(String id, int newBalance) {
    state = [
      for (final account in state)
        if (account.id == id)
          SproutAccount(
            id: account.id,
            name: account.name,
            type: account.type,
            balance: newBalance,
            currency: account.currency,
            lastUpdatedLabel: 'Edited just now',
            isManual: account.isManual,
          )
        else
          account,
    ];
  }

  void applyTransaction(SproutTransaction transaction) {
    final accountId = transaction.accountId ?? 'cash';
    state = [
      for (final account in state)
        if (account.id == accountId)
          SproutAccount(
            id: account.id,
            name: account.name,
            type: account.type,
            balance: transaction.type == TransactionType.income
                ? account.balance + transaction.amount
                : account.balance - transaction.amount,
            currency: account.currency,
            lastUpdatedLabel: 'Edited just now',
            isManual: account.isManual,
          )
        else
          account,
    ];
  }
}

final manualTransactionsProvider =
    StateNotifierProvider<ManualTransactionsNotifier, List<SproutTransaction>>(
  (ref) => ManualTransactionsNotifier(),
);

class ManualTransactionsNotifier
    extends StateNotifier<List<SproutTransaction>> {
  ManualTransactionsNotifier() : super(const []);

  void add(SproutTransaction transaction) {
    state = [transaction, ...state];
  }
}

final visibleTransactionsProvider = Provider<List<SproutTransaction>>((ref) {
  return [
    ...ref.watch(manualTransactionsProvider),
    ...mockTransactions,
  ];
});

final adjustedBudgetProvider = Provider<SproutBudget>((ref) {
  final manual = ref.watch(manualTransactionsProvider);
  final extraIncome = manual
      .where((txn) => txn.type == TransactionType.income)
      .fold<int>(0, (sum, txn) => sum + txn.amount);
  final extraSpend = manual
      .where((txn) => txn.type == TransactionType.expense)
      .fold<int>(0, (sum, txn) => sum + txn.amount);
  final monthlyIncome = mockBudget.monthlyIncome + extraIncome;
  final spent = mockBudget.spent + extraSpend;
  final remaining = (mockBudget.remaining + extraIncome - extraSpend);

  return SproutBudget(
    monthlyIncome: monthlyIncome,
    safeToSpend: mockBudget.safeToSpend + extraIncome,
    spent: spent,
    remaining: remaining,
    month: mockBudget.month,
  );
});
