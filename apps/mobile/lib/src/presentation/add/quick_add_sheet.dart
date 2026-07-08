import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../data/mock_sprout_data.dart';
import '../../domain/sprout_models.dart';
import '../../theme/sprout_tokens.dart';
import '../../theme/sprout_theme.dart';
import '../../widgets/sprout_mascot.dart';
import '../../widgets/sprout_mascot_state.dart';
import 'add_widgets.dart';

/// Copy for the Quick Add sheet.
class QuickAddStrings {
  const QuickAddStrings._();

  static const title = 'Quick add';
  static const expenseHint = 'Tap one. Done in 3 seconds.';
  static const more = 'More';
  static const iGotPaid = 'I got paid';
  static const import = 'Import statement';
  static const incomeTitle = 'Log income';
  static const incomeHint = 'So I can celebrate your payday.';
  static const incomeBack = 'Back';
  static const incomeAmount = 'Amount';
  static const incomeAmountHint = 'PKR 0';
  static const incomeType = 'Type';
  static const incomeSave = 'Save income';
  static const incomeSource = 'Source (optional)';
  static const incomeSourceHint = 'e.g. Employer, Client';
  static const saved = 'Saved. Nice and calm.';
  static const enterAmount = 'Enter an amount';
}

/// The Quick Add bottom sheet — a proper two-tap flow.
///
/// Sheet 1: expense chips (the 95% case) + "I got paid" + "Import" buttons.
/// Sheet 2: minimal income form with a back button.
///
/// Data-source connections (Gmail, SMS) are NOT here — they live in Settings.
class QuickAddSheet extends StatefulWidget {
  const QuickAddSheet({super.key});

  /// Opens the Quick Add sheet above the current screen.
  static void open(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      useSafeArea: true,
      barrierColor: colors.ink.withValues(alpha: 0.45),
      builder: (_) => const QuickAddSheet(),
    );
  }

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  /// true = expense chips (default), false = income form.
  bool _showIncome = false;

  void _logExpense(String category) {
    // For now, log with a sensible default and close.
    // The existing showExpenseSheet is still available for amount entry.
    Navigator.of(context).pop();
    _showSuccess(context, category);
  }

  void _logIncome(SproutTransaction txn) {
    Navigator.of(context).pop();
    _showSuccess(context, txn.category);
  }

  void _showSuccess(BuildContext context, String label) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    final reduced = MediaQuery.of(context).disableAnimations;
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SproutMascot(
                state: SproutMascotState.thumbsUp,
                size: 40,
                enableBlink: false,
              ),
              const SizedBox(width: SproutSpacing.md),
              Expanded(
                child: Text(
                  '$label ${QuickAddStrings.saved}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: SproutColors.leaf,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: SproutColors.seed,
                  borderRadius: BorderRadius.circular(SproutRadius.pill),
                ),
                child: Text(
                  '+5 XP',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: SproutColors.mint,
          elevation: 0,
          duration: Duration(milliseconds: reduced ? 1200 : 1600),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _showIncome
          ? _IncomeSheet(
              key: const ValueKey('income'),
              bottomInset: bottomInset,
              onBack: () => setState(() => _showIncome = false),
              onSaved: _logIncome,
            )
          : _ExpenseSheet(
              key: const ValueKey('expense'),
              bottomInset: bottomInset,
              onClose: () => Navigator.of(context).pop(),
              onChipTap: _logExpense,
              onMoreTap: () => _openMoreExpenseSheet(context),
              onIncomeTap: () => setState(() => _showIncome = true),
              onImportTap: () => _openImportSheet(context),
            ),
    );
  }

  Future<void> _openMoreExpenseSheet(BuildContext context) async {
    final txn = await showExpenseSheet(context, category: 'More');
    if (txn != null && mounted) {
      Navigator.of(context).pop();
      _showSuccess(context, txn.category);
    }
  }

  void _openImportSheet(BuildContext context) {
    Navigator.of(context).pop();
    // Re-open the import card as a standalone sheet.
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: colors(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Import statement',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: SproutSpacing.lg),
              const ImportStatementCard(),
              const SizedBox(height: SproutSpacing.xl),
            ],
          ),
        );
      },
    );
  }

  SproutColorScheme colors(BuildContext context) =>
      SproutColorScheme.of(context);
}

// ──────────────────────────────────────────────────────────────
// Sheet 1: Expense chips
// ──────────────────────────────────────────────────────────────

class _ExpenseSheet extends StatelessWidget {
  const _ExpenseSheet({
    required this.bottomInset,
    required this.onClose,
    required this.onChipTap,
    required this.onMoreTap,
    required this.onIncomeTap,
    required this.onImportTap,
    super.key,
  });

  final double bottomInset;
  final VoidCallback onClose;
  final void Function(String category) onChipTap;
  final VoidCallback onMoreTap;
  final VoidCallback onIncomeTap;
  final VoidCallback onImportTap;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle + close button row
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  QuickAddStrings.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                _CloseButton(onTap: onClose),
              ],
            ),
            const SizedBox(height: SproutSpacing.xs),
            Text(
              QuickAddStrings.expenseHint,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colors.muted),
            ),
            const SizedBox(height: SproutSpacing.xl),

            // Expense chips — the 95% case, front and center.
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final chip in kExpenseChips)
                  AddExpenseChip(
                    label: chip.label,
                    icon: chip.icon,
                    tint: chip.tint,
                    onTap: () => onChipTap(chip.label),
                  ),
                // "More" chip for unusual items — opens the amount sheet.
                AddExpenseChip(
                  label: QuickAddStrings.more,
                  icon: Icons.add_rounded,
                  tint: colors.line.withValues(alpha: 0.3),
                  onTap: onMoreTap,
                ),
              ],
            ),

            const SizedBox(height: SproutSpacing.xxl),

            // Demoted actions — small, quiet, one tap deeper.
            Row(
              children: [
                Expanded(
                  child: _SecondaryButton(
                    label: QuickAddStrings.iGotPaid,
                    icon: Icons.savings_rounded,
                    onTap: onIncomeTap,
                  ),
                ),
                const SizedBox(width: SproutSpacing.md),
                Expanded(
                  child: _SecondaryButton(
                    label: QuickAddStrings.import,
                    icon: Icons.upload_file_rounded,
                    onTap: onImportTap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SproutSpacing.lg),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Sheet 2: Income form (minimal — one amount, four type chips, one button)
// ──────────────────────────────────────────────────────────────

class _IncomeSheet extends StatefulWidget {
  const _IncomeSheet({
    required this.bottomInset,
    required this.onBack,
    required this.onSaved,
    super.key,
  });

  final double bottomInset;
  final VoidCallback onBack;
  final void Function(SproutTransaction) onSaved;

  @override
  State<_IncomeSheet> createState() => _IncomeSheetState();
}

class _IncomeSheetState extends State<_IncomeSheet> {
  final _amount = TextEditingController();
  final _source = TextEditingController();
  String _kind = 'Salary';
  final _formKey = GlobalKey<FormState>();

  static const _incomeTypes = ['Salary', 'Freelance', 'Gift', 'Other'];

  @override
  void dispose() {
    _amount.dispose();
    _source.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final value =
        int.tryParse(_amount.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (value == null || value <= 0) return;
    widget.onSaved(
      SproutTransaction(
        id: 'inc-${DateTime.now().millisecondsSinceEpoch}',
        amount: value,
        currency: 'PKR',
        type: TransactionType.income,
        category: _kind,
        merchant:
            _source.text.trim().isEmpty ? _kind : _source.text.trim(),
        note: '',
        date: DateTime.now(),
        source: TransactionSource.manual,
        needsReview: false,
        confidence: 1.0,
        accountId: 'cash',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + widget.bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Back button + title row
              Row(
                children: [
                  _BackButton(onTap: widget.onBack),
                  const SizedBox(width: SproutSpacing.md),
                  Text(
                    QuickAddStrings.incomeTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: SproutSpacing.xs),
              Text(
                QuickAddStrings.incomeHint,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colors.muted),
              ),
              const SizedBox(height: SproutSpacing.xl),

              // Amount — the one field
              TextFormField(
                controller: _amount,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: QuickAddStrings.incomeAmount,
                  hintText: QuickAddStrings.incomeAmountHint,
                  prefixText: 'PKR ',
                ),
                validator: (v) {
                  final n = int.tryParse(
                      (v ?? '').replaceAll(RegExp(r'[^0-9]'), ''));
                  if (n == null || n <= 0) return QuickAddStrings.enterAmount;
                  return null;
                },
              ),
              const SizedBox(height: SproutSpacing.md),

              // Source — optional, one line
              TextFormField(
                controller: _source,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: QuickAddStrings.incomeSource,
                  hintText: QuickAddStrings.incomeSourceHint,
                ),
              ),
              const SizedBox(height: SproutSpacing.lg),

              // Type chips — tap over type
              Text(QuickAddStrings.incomeType,
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: SproutSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in _incomeTypes)
                    ChoiceChip(
                      label: Text(type),
                      selected: _kind == type,
                      onSelected: (_) => setState(() => _kind = type),
                    ),
                ],
              ),
              const SizedBox(height: SproutSpacing.xl),

              // One save button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text(QuickAddStrings.incomeSave),
                ),
              ),
              const SizedBox(height: SproutSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Small reusable buttons for the sheet
// ──────────────────────────────────────────────────────────────

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return SproutButtonPress(
      onTap: onTap,
      scale: 0.9,
      semanticLabel: 'Close',
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.line.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close_rounded, color: colors.muted, size: 20),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return SproutButtonPress(
      onTap: onTap,
      scale: 0.9,
      semanticLabel: QuickAddStrings.incomeBack,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.line.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.arrow_back_rounded, color: colors.muted, size: 20),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return SproutButtonPress(
      onTap: onTap,
      scale: 0.96,
      semanticLabel: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: colors.line.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(SproutRadius.tile),
          border: Border.all(color: colors.line.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colors.muted, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.ink,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}