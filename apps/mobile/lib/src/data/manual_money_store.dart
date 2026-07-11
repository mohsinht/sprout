import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/sprout_models.dart';
import 'api/sprout_api_client.dart';
import 'auth_store.dart';
import 'context_refresh.dart';
import 'mock_sprout_data.dart';

const _useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

final accountsProvider =
    StateNotifierProvider<AccountsNotifier, List<SproutAccount>>((ref) {
  final notifier = AccountsNotifier(ref);
  ref.listen(authSessionProvider, (_, session) {
    if (session != null) notifier.syncFromServer();
  });
  return notifier;
});

class AccountsNotifier extends StateNotifier<List<SproutAccount>> {
  AccountsNotifier(this._ref)
      : super(_useMock ? mockAccounts : const [_localCash]) {
    _restore();
  }

  static const _storageKey = 'accounts.local.v1';
  static const _localCash = SproutAccount(
      id: 'local-cash',
      name: 'Cash',
      type: AccountType.cash,
      balance: 0,
      currency: 'PKR',
      lastUpdatedLabel: 'Tracked manually',
      isManual: true);
  final Ref _ref;

  Future<void> _restore() async {
    if (_useMock) return;
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_storageKey);
    if (encoded != null) {
      try {
        state = (jsonDecode(encoded) as List)
            .map((e) => _accountFromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    if (_ref.read(authSessionProvider) != null) await syncFromServer();
  }

  Future<void> syncFromServer() async {
    if (_useMock || _ref.read(authSessionProvider) == null) return;
    try {
      var rows = ((_ref.read(apiClientProvider).get('/v1/accounts')));
      var response = await rows;
      var remote = (response['accounts'] as List? ?? const [])
          .map((e) => _accountFromJson(e as Map<String, dynamic>))
          .toList();
      if (remote.isEmpty) {
        final created =
            await _ref.read(apiClientProvider).post('/v1/accounts', {
          'label': 'Cash',
          'type': 'cash',
          'openingBalance':
              state.where((a) => a.id == 'local-cash').firstOrNull?.balance ??
                  0,
          'currency': 'PKR'
        });
        remote = [_accountFromJson(created)];
      }
      state = remote;
      await _persist();
    } catch (_) {}
  }

  Future<void> _persist() async {
    if (_useMock) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _storageKey, jsonEncode(state.map(_accountToJson).toList()));
  }

  Future<void> updateBalance(String id, int newBalance) async {
    state = [
      for (final a in state)
        if (a.id == id) _copyAccount(a, balance: newBalance) else a
    ];
    await _persist();
  }

  Future<void> applyTransaction(SproutTransaction transaction) async {
    final accountId = transaction.accountId ?? state.first.id;
    state = [
      for (final a in state)
        if (a.id == accountId)
          _copyAccount(a,
              balance: transaction.type == TransactionType.income
                  ? a.balance + transaction.amount
                  : a.balance - transaction.amount)
        else
          a
    ];
    await _persist();
  }

  static SproutAccount _copyAccount(SproutAccount a, {required int balance}) =>
      SproutAccount(
          id: a.id,
          name: a.name,
          type: a.type,
          balance: balance,
          currency: a.currency,
          lastUpdatedLabel: 'Edited just now',
          isManual: a.isManual);
}

final manualTransactionsProvider =
    StateNotifierProvider<ManualTransactionsNotifier, List<SproutTransaction>>(
        (ref) {
  final notifier = ManualTransactionsNotifier(ref);
  ref.listen(authSessionProvider, (_, session) {
    if (session != null) notifier.syncFromServer();
  });
  return notifier;
});

class ManualTransactionsNotifier
    extends StateNotifier<List<SproutTransaction>> {
  ManualTransactionsNotifier(this._ref) : super(const []) {
    _restore();
  }
  static const _storageKey = 'transactions.local.v1';
  final Ref _ref;

  Future<void> _restore() async {
    if (_useMock) return;
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_storageKey);
    if (encoded != null) {
      try {
        state = (jsonDecode(encoded) as List)
            .map((e) => _transactionFromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    if (_ref.read(authSessionProvider) != null) await syncFromServer();
  }

  Future<void> add(SproutTransaction transaction) async {
    state = [transaction, ...state];
    await _persist();
    if (_useMock || _ref.read(authSessionProvider) == null) return;
    final accountId =
        RegExp(r'^[0-9a-f-]{36}$').hasMatch(transaction.accountId ?? '')
            ? transaction.accountId
            : null;
    try {
      final created =
          await _ref.read(apiClientProvider).post('/v1/transactions', {
        'amount': transaction.amount,
        'currency': transaction.currency,
        'type': transaction.type.name,
        'category': transaction.category,
        'merchant': transaction.merchant,
        'note': transaction.note,
        'occurredAt': transaction.date.toUtc().toIso8601String(),
        'source': 'manual',
        'confidence': 1,
        if (accountId != null) 'accountId': accountId
      });
      state = [
        for (final tx in state)
          if (tx.id == transaction.id) _transactionFromJson(created) else tx
      ];
      await _persist();
      await _ref.read(accountsProvider.notifier).syncFromServer();
      await _ref
          .read(apiClientProvider)
          .post('/v1/briefing/refresh', {'contextChanged': true});
      _ref.read(briefingRevisionProvider.notifier).state++;
    } catch (_) {}
  }

  Future<void> syncFromServer() async {
    if (_useMock || _ref.read(authSessionProvider) == null) return;
    try {
      final response =
          await _ref.read(apiClientProvider).get('/v1/transactions');
      final remote = (response['transactions'] as List? ?? const [])
          .map((e) => _transactionFromJson(e as Map<String, dynamic>))
          .toList();
      final pending =
          state.where((tx) => !RegExp(r'^[0-9a-f-]{36}$').hasMatch(tx.id));
      state = [...pending, ...remote];
      await _persist();
    } catch (_) {}
  }

  Future<void> _persist() async {
    if (_useMock) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _storageKey, jsonEncode(state.map(_transactionToJson).toList()));
  }
}

final visibleTransactionsProvider = Provider<List<SproutTransaction>>((ref) => [
      ...ref.watch(manualTransactionsProvider),
      if (_useMock) ...mockTransactions
    ]);

final adjustedBudgetProvider = Provider<SproutBudget>((ref) {
  final manual = ref.watch(manualTransactionsProvider);
  final base = _useMock
      ? mockBudget
      : SproutBudget(
          monthlyIncome: 0,
          safeToSpend: 0,
          spent: 0,
          remaining: 0,
          month: '${_monthName(DateTime.now().month)} ${DateTime.now().year}');
  final extraIncome = manual
      .where((t) => t.type == TransactionType.income)
      .fold<int>(0, (sum, t) => sum + t.amount);
  final extraSpend = manual
      .where((t) => t.type == TransactionType.expense)
      .fold<int>(0, (sum, t) => sum + t.amount);
  return SproutBudget(
      monthlyIncome: base.monthlyIncome + extraIncome,
      safeToSpend: base.safeToSpend + extraIncome,
      spent: base.spent + extraSpend,
      remaining: base.remaining + extraIncome - extraSpend,
      month: base.month);
});

SproutAccount _accountFromJson(Map<String, dynamic> json) => SproutAccount(
    id: json['id'] as String,
    name: (json['label'] ?? json['name']) as String,
    type: _accountType(json['type'] as String? ?? 'other'),
    balance: (json['balance'] as num?)?.toInt() ?? 0,
    currency: json['currency'] as String? ?? 'PKR',
    lastUpdatedLabel: (json['updatedLabel'] ??
        json['lastUpdatedLabel'] ??
        'Tracked manually') as String,
    isManual: json['isManual'] as bool? ?? true);
Map<String, dynamic> _accountToJson(SproutAccount a) => {
      'id': a.id,
      'name': a.name,
      'type': a.type.name,
      'balance': a.balance,
      'currency': a.currency,
      'lastUpdatedLabel': a.lastUpdatedLabel,
      'isManual': a.isManual
    };
AccountType _accountType(String value) =>
    AccountType.values.where((e) => e.name == value).firstOrNull ??
    AccountType.other;

SproutTransaction _transactionFromJson(Map<String, dynamic> json) =>
    SproutTransaction(
        id: json['id'] as String,
        amount: (json['amount'] as num).toInt(),
        currency: json['currency'] as String? ?? 'PKR',
        type: TransactionType.values
                .where((e) => e.name == json['type'])
                .firstOrNull ??
            TransactionType.expense,
        category: json['category'] as String? ?? 'Other',
        merchant: json['merchant'] as String? ??
            json['category'] as String? ??
            'Manual',
        note: json['note'] as String? ?? '',
        date: DateTime.tryParse(
                (json['occurredAt'] ?? json['date']) as String? ?? '') ??
            DateTime.now(),
        source: TransactionSource.manual,
        needsReview: json['needsReview'] as bool? ?? false,
        confidence: double.tryParse('${json['confidence'] ?? 1}'),
        accountId: json['accountId'] as String?);
Map<String, dynamic> _transactionToJson(SproutTransaction tx) => {
      'id': tx.id,
      'amount': tx.amount,
      'currency': tx.currency,
      'type': tx.type.name,
      'category': tx.category,
      'merchant': tx.merchant,
      'note': tx.note,
      'date': tx.date.toIso8601String(),
      'needsReview': tx.needsReview,
      'confidence': tx.confidence,
      'accountId': tx.accountId
    };
String _monthName(int month) => const [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ][month - 1];
