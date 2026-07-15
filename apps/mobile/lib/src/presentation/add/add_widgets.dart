import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../data/mock_sprout_data.dart';
import '../../data/manual_money_store.dart';
import '../../data/statement_import_service.dart';
import '../../domain/sprout_models.dart';
import '../../theme/sprout_strings.dart';
import '../../theme/sprout_tokens.dart';
import '../../theme/sprout_theme.dart';
import '../../widgets/sprout_helpers.dart';
import '../../widgets/sprout_panel.dart';

/// Copy for the Add screen. Kept private so no other file is edited.
class AddStrings {
  const AddStrings._();

  static const sectionQuickExpense = 'Quick add expense';
  static const sectionQuickExpenseHint = 'Tap one. Done in 10 seconds.';
  static const sectionIncome = 'Add income';
  static const sectionIncomeHint = 'Salary, freelance, gifts — log it once.';
  static const sectionImport = 'Import statement';
  static const sectionImportHint =
      'Upload a statement. Sprout extracts transactions, then you confirm them.';
  static const sectionEmail = 'Connect Email';
  static const sectionEmailHint =
      'Connect Gmail to auto-detect salary, bills, and card alerts.';
  static const connectGmail = 'Connect Gmail';
  static const optionalConnections = 'Optional connections';
  static const emailSheetTitle = 'Gmail connection';
  static const emailSheetBody =
      'This is a coming-soon feature. Sprout will never ask for your bank '
      'password, and you can disconnect anytime. No emails are read yet.';
  static const emailSheetCta = 'Got it';
  static const sectionSms = 'Android SMS detection';
  static const sectionSmsHint = 'Coming soon';
  static const sectionSmsBody =
      'Sprout will detect card alerts from SMS on Android. Not available yet.';

  static const amountLabel = 'Amount';
  static const amountHint = 'PKR 0';
  static const noteLabel = 'Note (optional)';
  static const noteHint = 'e.g. Office break';
  static const accountLabel = 'Account';
  static const save = 'Save';
  static const cancel = 'Cancel';
  static const sourceLabel = 'Source';
  static const sourceHint = 'e.g. Employer, Client';
  static const dateLabel = 'Date';
  static const addIncome = 'Add income';

  static const importCta = 'Upload statement';
  static const importIdle = 'CSV, PDF, or XLSX — Sprout extracts, you confirm.';
  static const importUploaded = 'Statement uploaded (demo).';
  static const importProcessing = 'Reading transactions (demo)…';
  static const importNeedsReview =
      'Demo: Sprout will list transactions here for you to confirm.';
  static const importCompleted = 'Demo done. Real parsing is coming soon.';

  static const recentTitle = 'Just added';
  static const recentHint = 'Your latest entries appear here.';
  static const emptyTitle = 'Log something in 10 seconds.';
  static const emptySubtitle = 'Tap a chip above — Chai, Fuel, Groceries.';
  static const emptyAction = 'Quick add';

  static const saved = 'Saved. Nice and calm.';
  static const incomeSaved = 'Income logged.';
  static const loading = 'Opening Quick Add…';
  static const error = 'Sprout could not open Quick Add.';
}

/// A small muted header that groups the optional email/SMS connection cards so
/// they read as optional, not as pressure to connect on the manual-first Add
/// screen.
class OptionalConnectionsHeader extends StatelessWidget {
  const OptionalConnectionsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        AddStrings.optionalConnections,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.muted,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

/// A single tinted expense chip. Background is a Sprout tint, icon is leaf.
class AddExpenseChip extends StatelessWidget {
  const AddExpenseChip({
    required this.label,
    required this.icon,
    required this.tint,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SproutButtonPress(
      onTap: onTap,
      scale: 0.94,
      semanticLabel: 'Quick add $label',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(SproutRadius.pill),
          border: Border.all(color: SproutColors.leaf.withValues(alpha: 0.12)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: SproutColors.leaf, size: 18),
              const SizedBox(width: 7),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: SproutColors.leaf,
                      fontSize: 14,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The 13 canonical quick-add categories, with a tint + icon each.
const kExpenseChips = <_ExpenseChipData>[
  _ExpenseChipData('Chai', Icons.coffee_rounded, SproutColors.tintMint),
  _ExpenseChipData(
      'Groceries', Icons.shopping_cart_rounded, SproutColors.tintSky),
  _ExpenseChipData(
      'Fuel', Icons.local_gas_station_rounded, SproutColors.tintWarm),
  _ExpenseChipData('Ride', Icons.local_taxi_rounded, SproutColors.tintLilac),
  _ExpenseChipData(
      'Mobile Load', Icons.phone_android_rounded, SproutColors.tintGold),
  _ExpenseChipData(
      'Utility Bill', Icons.receipt_long_rounded, SproutColors.tintSky),
  _ExpenseChipData('School Fee', Icons.school_rounded, SproutColors.tintMint),
  _ExpenseChipData('Medicine', Icons.medication_rounded, SproutColors.tintWarm),
  _ExpenseChipData(
      'Shopping', Icons.shopping_bag_rounded, SproutColors.tintLilac),
  _ExpenseChipData('Food', Icons.restaurant_rounded, SproutColors.tintGold),
  _ExpenseChipData(
      'Zakat', Icons.volunteer_activism_rounded, SproutColors.tintMint),
  _ExpenseChipData('Sadaqah', Icons.favorite_rounded, SproutColors.tintMint),
  _ExpenseChipData('Committee', Icons.groups_rounded, SproutColors.tintSky),
];

class _ExpenseChipData {
  const _ExpenseChipData(this.label, this.icon, this.tint);

  final String label;
  final IconData icon;
  final Color tint;
}

/// Opens a calm bottom sheet to confirm an expense, returns the built
/// transaction (or null). Account defaults to Cash — the manual-only path.
Future<SproutTransaction?> showExpenseSheet(
  BuildContext context, {
  required String category,
}) {
  return showModalBottomSheet<SproutTransaction>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useRootNavigator: true,
    useSafeArea: true,
    backgroundColor: SproutColorScheme.of(context).surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _ExpenseSheet(category: category),
  );
}

class _ExpenseSheet extends StatefulWidget {
  const _ExpenseSheet({required this.category});

  final String category;

  @override
  State<_ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends State<_ExpenseSheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  SproutAccount _account = mockAccounts.first;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final value = int.tryParse(_amount.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (value == null || value <= 0) return;
    Navigator.of(context).pop(
      SproutTransaction(
        id: 'add-${DateTime.now().millisecondsSinceEpoch}',
        amount: value,
        currency: 'PKR',
        type: TransactionType.expense,
        category: widget.category,
        merchant: widget.category,
        note: _note.text.trim(),
        date: DateTime.now(),
        source: TransactionSource.manual,
        needsReview: false,
        confidence: 1.0,
        accountId: _account.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.category,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: SproutSpacing.lg),
            TextFormField(
              controller: _amount,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: AddStrings.amountLabel,
                hintText: AddStrings.amountHint,
                prefixText: 'PKR ',
              ),
              validator: (v) {
                final n =
                    int.tryParse((v ?? '').replaceAll(RegExp(r'[^0-9]'), ''));
                if (n == null || n <= 0) return 'Enter an amount';
                return null;
              },
            ),
            const SizedBox(height: SproutSpacing.md),
            TextFormField(
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: AddStrings.noteLabel,
                hintText: AddStrings.noteHint,
              ),
            ),
            const SizedBox(height: SproutSpacing.md),
            DropdownButtonFormField<SproutAccount>(
              initialValue: _account,
              decoration:
                  const InputDecoration(labelText: AddStrings.accountLabel),
              items: [
                for (final a in mockAccounts)
                  DropdownMenuItem(
                    value: a,
                    child: Row(
                      children: [
                        Icon(accountIcon(a.type),
                            color: accountColor(a.type), size: 20),
                        const SizedBox(width: SproutSpacing.md),
                        Text(a.name),
                      ],
                    ),
                  ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _account = v);
              },
            ),
            const SizedBox(height: SproutSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text(AddStrings.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Income mark-as options.
enum _IncomeKind { salary, freelance, gift, refund, other }

extension _IncomeKindLabel on _IncomeKind {
  String get label => switch (this) {
        _IncomeKind.salary => 'Salary',
        _IncomeKind.freelance => 'Freelance',
        _IncomeKind.gift => 'Gift',
        _IncomeKind.refund => 'Refund',
        _IncomeKind.other => 'Other',
      };
}

/// Quick add income form. Calls [onSaved] with a built transaction.
class IncomeForm extends StatefulWidget {
  const IncomeForm({required this.onSaved, super.key});

  final ValueChanged<SproutTransaction> onSaved;

  @override
  State<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  final _amount = TextEditingController();
  final _source = TextEditingController();
  DateTime _date = DateTime.now();
  _IncomeKind _kind = _IncomeKind.salary;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amount.dispose();
    _source.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final value = int.tryParse(_amount.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (value == null || value <= 0) return;
    widget.onSaved(
      SproutTransaction(
        id: 'inc-${DateTime.now().millisecondsSinceEpoch}',
        amount: value,
        currency: 'PKR',
        type: TransactionType.income,
        category: _kind.label,
        merchant:
            _source.text.trim().isEmpty ? _kind.label : _source.text.trim(),
        note: '',
        date: _date,
        source: TransactionSource.manual,
        needsReview: false,
        confidence: 1.0,
        accountId: 'cash',
      ),
    );
    _amount.clear();
    _source.clear();
    setState(() => _kind = _IncomeKind.salary);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: AddStrings.amountLabel,
              hintText: AddStrings.amountHint,
              prefixText: 'PKR ',
            ),
            validator: (v) {
              final n =
                  int.tryParse((v ?? '').replaceAll(RegExp(r'[^0-9]'), ''));
              if (n == null || n <= 0) return 'Enter an amount';
              return null;
            },
          ),
          const SizedBox(height: SproutSpacing.md),
          TextFormField(
            controller: _source,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: AddStrings.sourceLabel,
              hintText: AddStrings.sourceHint,
            ),
          ),
          const SizedBox(height: SproutSpacing.md),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(SproutRadius.card),
            child: InputDecorator(
              decoration:
                  const InputDecoration(labelText: AddStrings.dateLabel),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(SproutFormat.date(_date)),
                  const Icon(Icons.calendar_today_rounded, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: SproutSpacing.md),
          Text('Type', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: SproutSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final kind in _IncomeKind.values)
                ChoiceChip(
                  label: Text(kind.label),
                  selected: _kind == kind,
                  onSelected: (_) => setState(() => _kind = kind),
                ),
            ],
          ),
          const SizedBox(height: SproutSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.add_rounded),
              label: const Text(AddStrings.addIncome),
            ),
          ),
        ],
      ),
    );
  }
}

/// CSV statement import with an explicit review-before-counting step.
class ImportStatementCard extends ConsumerStatefulWidget {
  const ImportStatementCard({super.key});

  @override
  ConsumerState<ImportStatementCard> createState() =>
      _ImportStatementCardState();
}

enum _ImportState { idle, picking, needsReview, importing, completed }

class _ImportStatementCardState extends ConsumerState<ImportStatementCard> {
  _ImportState _state = _ImportState.idle;
  List<SproutTransaction> _transactions = const [];
  String? _error;

  String get _status => switch (_state) {
        _ImportState.idle =>
          'Choose a CSV with date, amount, and category columns.',
        _ImportState.picking => 'Opening your files…',
        _ImportState.needsReview =>
          '${_transactions.length} transactions are ready for your review.',
        _ImportState.importing => 'Saving confirmed transactions…',
        _ImportState.completed =>
          '${_transactions.length} transactions imported. Your source file was not stored.',
      };

  String get _cta => switch (_state) {
        _ImportState.idle => 'Choose CSV',
        _ImportState.picking => 'Opening…',
        _ImportState.needsReview => 'Import ${_transactions.length}',
        _ImportState.importing => 'Saving…',
        _ImportState.completed => 'Import another',
      };

  bool get _busy =>
      _state == _ImportState.picking || _state == _ImportState.importing;

  Future<void> _advance() async {
    if (_busy) return;
    if (_state == _ImportState.needsReview) {
      await _import();
      return;
    }
    if (_state == _ImportState.completed) {
      setState(() {
        _state = _ImportState.idle;
        _transactions = const [];
        _error = null;
      });
      return;
    }
    setState(() {
      _state = _ImportState.picking;
      _error = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        withData: true,
      );
      if (!mounted) return;
      if (result == null) {
        setState(() => _state = _ImportState.idle);
        return;
      }
      final bytes = result.files.single.bytes;
      if (bytes == null) {
        throw const StatementImportException(
          'Sprout could not read this file on your device.',
        );
      }
      final parsed =
          const StatementImportService().parseCsv(utf8.decode(bytes));
      setState(() {
        _transactions = parsed;
        _state = _ImportState.needsReview;
      });
    } on StatementImportException catch (error) {
      setState(() {
        _state = _ImportState.idle;
        _error = error.message;
      });
    } catch (_) {
      setState(() {
        _state = _ImportState.idle;
        _error = 'Sprout could not read this CSV. Nothing was imported.';
      });
    }
  }

  Future<void> _import() async {
    setState(() {
      _state = _ImportState.importing;
      _error = null;
    });
    final accounts = ref.read(accountsProvider);
    final account = accounts.firstOrNull;
    for (final transaction in _transactions) {
      final withAccount = SproutTransaction(
        id: transaction.id,
        amount: transaction.amount,
        currency: transaction.currency,
        type: transaction.type,
        category: transaction.category,
        merchant: transaction.merchant,
        note: transaction.note,
        date: transaction.date,
        source: transaction.source,
        needsReview: false,
        confidence: 1,
        accountId: account?.id,
      );
      if (account != null) {
        await ref.read(accountsProvider.notifier).applyTransaction(withAccount);
      }
      await ref.read(manualTransactionsProvider.notifier).add(withAccount);
    }
    if (mounted) setState(() => _state = _ImportState.completed);
  }

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final progress = switch (_state) {
      _ImportState.idle => 0.0,
      _ImportState.picking => 0.25,
      _ImportState.needsReview => 0.85,
      _ImportState.importing => 0.92,
      _ImportState.completed => 1.0,
    };
    return SproutRaisedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: SproutColors.tintLilac,
                child: Icon(Icons.upload_file_rounded,
                    color: SproutColors.lilac, size: 20),
              ),
              const SizedBox(width: SproutSpacing.md),
              Expanded(
                child: Text(
                  AddStrings.sectionImport,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (_state == _ImportState.completed)
                const Icon(Icons.check_circle_rounded,
                    color: SproutColors.seed),
            ],
          ),
          const SizedBox(height: SproutSpacing.sm),
          Text(
            AddStrings.sectionImportHint,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: SproutSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _formatBadge('CSV', SproutColors.tintMint, SproutColors.leaf),
              _formatBadge('Review before import', SproutColors.tintSky,
                  SproutColors.sky),
            ],
          ),
          const SizedBox(height: SproutSpacing.md),
          if (_state != _ImportState.idle) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(SproutRadius.pill),
              child: LinearProgressIndicator(
                value: progress == 0 ? null : progress,
                minHeight: 6,
                color: SproutColors.lilac,
                backgroundColor: colors.line,
              ),
            ),
            const SizedBox(height: SproutSpacing.md),
          ],
          Text(_status, style: Theme.of(context).textTheme.bodyMedium),
          if (_state == _ImportState.needsReview) ...[
            const SizedBox(height: SproutSpacing.md),
            for (final transaction in _transactions.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: SproutSpacing.sm),
                child: Text(
                  '${SproutFormat.date(transaction.date)} · ${transaction.category} · ${SproutFormat.currency(transaction.amount)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (_transactions.length > 3)
              Text('+ ${_transactions.length - 3} more',
                  style: Theme.of(context).textTheme.bodySmall),
          ],
          if (_error != null) ...[
            const SizedBox(height: SproutSpacing.md),
            Text(_error!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: SproutColors.tomato)),
          ],
          const SizedBox(height: SproutSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: _busy ? null : _advance,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_busy)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.file_upload_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(_cta),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formatBadge(String label, Color bg, Color ink) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(SproutRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: ink),
      ),
    );
  }
}

/// Privacy-first Gmail connection card. Honest placeholder, no fake success.
class ConnectEmailCard extends StatelessWidget {
  const ConnectEmailCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SproutRaisedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: SproutColors.tintSky,
                child: Icon(Icons.mail_outline_rounded,
                    color: SproutColors.sky, size: 20),
              ),
              const SizedBox(width: SproutSpacing.md),
              Expanded(
                child: Text(
                  AddStrings.sectionEmail,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const _ComingSoonPill(),
            ],
          ),
          const SizedBox(height: SproutSpacing.sm),
          Text(
            AddStrings.sectionEmailHint,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: SproutSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _showEmailSheet(context),
              child: const Text(AddStrings.connectGmail),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmailSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: SproutColorScheme.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(SproutRadius.hero)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AddStrings.emailSheetTitle,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: SproutSpacing.lg),
            Text(AddStrings.emailSheetBody,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: SproutSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(AddStrings.emailSheetCta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonPill extends StatelessWidget {
  const _ComingSoonPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: SproutColors.gold.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(SproutRadius.pill),
      ),
      child: Text(
        'Soon',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: SproutColors.goldInk,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

/// Disabled, clearly coming-soon SMS card.
class SmsComingSoonCard extends StatelessWidget {
  const SmsComingSoonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(SproutRadius.card),
        border: Border.all(color: colors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SproutSpacing.lg),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colors.line,
              child: Icon(Icons.sms_rounded, color: colors.muted, size: 20),
            ),
            const SizedBox(width: SproutSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        AddStrings.sectionSms,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: colors.muted,
                                ),
                      ),
                      const SizedBox(width: SproutSpacing.sm),
                      const _ComingSoonPill(),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AddStrings.sectionSmsBody,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small section header used across Add sections.
class AddSectionHeader extends StatelessWidget {
  const AddSectionHeader({
    required this.title,
    required this.hint,
    super.key,
  });

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: SproutSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(hint, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
