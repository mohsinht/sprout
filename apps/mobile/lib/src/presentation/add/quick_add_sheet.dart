import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../data/manual_money_store.dart';
import '../../data/mock_sprout_data.dart';
import '../../domain/sprout_models.dart';
import '../../theme/sprout_strings.dart';
import '../../theme/sprout_tokens.dart';
import '../../theme/sprout_theme.dart';
import '../../widgets/sprout_mascot.dart';
import '../../widgets/sprout_mascot_state.dart';
import 'add_widgets.dart';

class QuickAddStrings {
  const QuickAddStrings._();

  static const title = 'Quick add';
  static const expenseHint = 'Tap one. Confirm the usual amount.';
  static const more = 'More';
  static const iGotPaid = 'I got paid';
  static const import = 'Import';
  static const amountHint = 'Most days, this is two taps.';
  static const pocket = 'From';
  static const today = 'Today';
  static const addAmount = 'Add an amount to log this.';
  static const customAmount = 'Custom amount';
  static const incomeTitle = 'I got paid';
  static const incomeHint = 'Log income manually. No connection needed.';
  static const incomeType = 'Type';
  static const importTitle = 'Import statement';
  static const importHint =
      'Upload a file, confirm what Sprout reads, then re-baseline.';
  static const logged = 'Logged!';
  static const addAnother = 'Add another';
  static const done = 'Done';
  static const savedNote = 'Saved locally. Money updated.';
}

enum _QuickAddStep { categories, amount, more, income, import, success }

enum _IncomeKind {
  salary('Salary', Icons.work_rounded),
  freelance('Freelance', Icons.laptop_mac_rounded),
  gift('Gift', Icons.card_giftcard_rounded),
  other('Other', Icons.more_horiz_rounded);

  const _IncomeKind(this.label, this.icon);

  final String label;
  final IconData icon;
}

class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({this.startWithImport = false, super.key});

  final bool startWithImport;

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

  static void openImport(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      useSafeArea: true,
      barrierColor: colors.ink.withValues(alpha: 0.45),
      builder: (_) => const QuickAddSheet(startWithImport: true),
    );
  }

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  var _step = _QuickAddStep.categories;
  _QuickCategory? _category;
  SproutAccount _pocket = mockAccounts.first;
  int? _amount;
  String? _validation;
  bool _customAmountOpen = false;
  DateTime _date = DateTime.now();
  final _customAmount = TextEditingController();
  final _customCategory = TextEditingController();
  final _customFocus = FocusNode();
  final _incomeAmount = TextEditingController();
  var _incomeKind = _IncomeKind.salary;
  SproutTransaction? _lastTransaction;

  @override
  void initState() {
    super.initState();
    if (widget.startWithImport) _step = _QuickAddStep.import;
    _customAmount.addListener(_rebuildForAmountText);
    _incomeAmount.addListener(_rebuildForAmountText);
  }

  @override
  void dispose() {
    _customAmount.removeListener(_rebuildForAmountText);
    _incomeAmount.removeListener(_rebuildForAmountText);
    _customAmount.dispose();
    _customCategory.dispose();
    _customFocus.dispose();
    _incomeAmount.dispose();
    super.dispose();
  }

  void _rebuildForAmountText() {
    if (mounted) setState(() {});
  }

  void _chooseCategory(_QuickCategory category) {
    HapticFeedback.lightImpact();
    setState(() {
      _category = category;
      _amount = category.smartDefault;
      _customAmount.text =
          category.smartDefault == null ? '' : category.smartDefault.toString();
      _validation = null;
      _customAmountOpen = category.smartDefault == null;
      _step = _QuickAddStep.amount;
    });
    if (category.smartDefault == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _customFocus.requestFocus();
      });
    }
  }

  void _choosePreset(int amount) {
    HapticFeedback.lightImpact();
    setState(() {
      _amount = amount;
      _customAmount.text = amount.toString();
      _validation = null;
      _customAmountOpen = false;
    });
  }

  void _openCustomAmount() {
    setState(() => _customAmountOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _customFocus.requestFocus();
    });
  }

  void _confirmExpense() {
    final category = _category;
    final typed =
        int.tryParse(_customAmount.text.replaceAll(RegExp(r'[^0-9]'), ''));
    final amount = _customAmountOpen ? typed : _amount;
    if (category == null || amount == null || amount <= 0) {
      HapticFeedback.selectionClick();
      setState(() => _validation = QuickAddStrings.addAmount);
      return;
    }

    _saveTransaction(
      SproutTransaction(
        id: 'manual-${DateTime.now().microsecondsSinceEpoch}',
        amount: amount,
        currency: 'PKR',
        type: TransactionType.expense,
        category: category.label,
        merchant: category.label,
        note: 'Quick Add',
        date: _date,
        source: TransactionSource.manual,
        needsReview: false,
        confidence: 1.0,
        accountId: _pocket.id,
      ),
    );
  }

  void _confirmIncome() {
    final amount =
        int.tryParse(_incomeAmount.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amount == null || amount <= 0) {
      HapticFeedback.selectionClick();
      setState(() => _validation = QuickAddStrings.addAmount);
      return;
    }

    _saveTransaction(
      SproutTransaction(
        id: 'income-${DateTime.now().microsecondsSinceEpoch}',
        amount: amount,
        currency: 'PKR',
        type: TransactionType.income,
        category: _incomeKind.label,
        merchant: _incomeKind.label,
        note: 'Quick Add income',
        date: _date,
        source: TransactionSource.manual,
        needsReview: false,
        confidence: 1.0,
        accountId: _pocket.id,
      ),
    );
  }

  void _saveTransaction(SproutTransaction transaction) {
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
    ref.read(manualTransactionsProvider.notifier).add(transaction);
    ref.read(accountsProvider.notifier).applyTransaction(transaction);
    setState(() {
      _lastTransaction = transaction;
      _validation = null;
      _step = _QuickAddStep.success;
    });
  }

  void _resetToCategories() {
    HapticFeedback.lightImpact();
    setState(() {
      _step = _QuickAddStep.categories;
      _category = null;
      _amount = null;
      _validation = null;
      _customAmount.clear();
      _incomeAmount.clear();
      _customAmountOpen = false;
      _incomeKind = _IncomeKind.salary;
      _date = DateTime.now();
    });
  }

  void _openDateOptions() {
    HapticFeedback.lightImpact();
    final colors = SproutColorScheme.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SproutRadius.hero),
        ),
      ),
      builder: (sheetContext) {
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              SproutSpacing.pageHorizontal,
              SproutSpacing.lg,
              SproutSpacing.pageHorizontal,
              SproutSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Log date',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: SproutSpacing.md),
                _DateOptionTile(
                  label: QuickAddStrings.today,
                  date: today,
                  selected: _isSameDay(_date, today),
                  onTap: () {
                    setState(() => _date = today);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                _DateOptionTile(
                  label: 'Yesterday',
                  date: yesterday,
                  selected: _isSameDay(_date, yesterday),
                  onTap: () {
                    setState(() => _date = yesterday);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _useCustomCategory() {
    final text = _customCategory.text.trim();
    if (text.isEmpty) {
      setState(() => _validation = 'Name the category first.');
      return;
    }
    _chooseCategory(
      _QuickCategory(
        label: text,
        icon: Icons.more_horiz_rounded,
        tint: SproutColors.tintMint,
        smartDefault: null,
        presets: const [100, 250, 500, 1000],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    if (accounts.isNotEmpty &&
        !accounts.any((account) => account.id == _pocket.id)) {
      _pocket = accounts.first;
    }
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final paddingBottom =
        keyboardInset > 0 ? keyboardInset + SproutSpacing.lg : bottomInset + 24;

    return AnimatedSwitcher(
      duration: MediaQuery.of(context).disableAnimations
          ? Duration.zero
          : SproutDurations.pageTransition,
      child: switch (_step) {
        _QuickAddStep.categories => _SheetFrame(
            key: const ValueKey('categories'),
            bottomInset: paddingBottom,
            onClose: () => Navigator.of(context).maybePop(),
            child: _CategoryStep(
              onCategory: _chooseCategory,
              onMore: () => setState(() {
                _validation = null;
                _step = _QuickAddStep.more;
              }),
              onIncome: () => setState(() {
                _validation = null;
                _step = _QuickAddStep.income;
              }),
              onImport: () => setState(() {
                _validation = null;
                _step = _QuickAddStep.import;
              }),
            ),
          ),
        _QuickAddStep.amount => _SheetFrame(
            key: const ValueKey('amount'),
            bottomInset: paddingBottom,
            onClose: () => Navigator.of(context).maybePop(),
            child: _AmountStep(
              accounts: accounts,
              category: _category!,
              amount: _customAmountOpen ? null : _amount,
              controller: _customAmount,
              focusNode: _customFocus,
              customOpen: _customAmountOpen,
              pocket: _pocket,
              date: _date,
              validation: _validation,
              onBack: () => setState(() {
                _validation = null;
                _step = _QuickAddStep.categories;
              }),
              onPreset: _choosePreset,
              onCustomTap: _openCustomAmount,
              onPocket: (account) => setState(() => _pocket = account),
              onDateTap: _openDateOptions,
              onConfirm: _confirmExpense,
            ),
          ),
        _QuickAddStep.more => _SheetFrame(
            key: const ValueKey('more'),
            bottomInset: paddingBottom,
            onClose: () => Navigator.of(context).maybePop(),
            child: _MoreStep(
              controller: _customCategory,
              validation: _validation,
              onBack: _resetToCategories,
              onCategory: _chooseCategory,
              onCustom: _useCustomCategory,
            ),
          ),
        _QuickAddStep.income => _SheetFrame(
            key: const ValueKey('income'),
            bottomInset: paddingBottom,
            onClose: () => Navigator.of(context).maybePop(),
            child: _IncomeStep(
              accounts: accounts,
              controller: _incomeAmount,
              kind: _incomeKind,
              pocket: _pocket,
              validation: _validation,
              onBack: _resetToCategories,
              onKind: (kind) => setState(() {
                HapticFeedback.lightImpact();
                _incomeKind = kind;
              }),
              onPocket: (account) => setState(() => _pocket = account),
              onConfirm: _confirmIncome,
            ),
          ),
        _QuickAddStep.import => _SheetFrame(
            key: const ValueKey('import'),
            bottomInset: paddingBottom,
            onClose: () => Navigator.of(context).maybePop(),
            child: _ImportStep(onBack: _resetToCategories),
          ),
        _QuickAddStep.success => _SheetFrame(
            key: const ValueKey('success'),
            bottomInset: paddingBottom,
            onClose: () => Navigator.of(context).maybePop(),
            child: _SuccessStep(
              accounts: accounts,
              transaction: _lastTransaction!,
              onAddAnother: _resetToCategories,
              onDone: () => Navigator.of(context).maybePop(),
            ),
          ),
      },
    );
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({
    required this.child,
    required this.bottomInset,
    required this.onClose,
    super.key,
  });

  final Widget child;
  final double bottomInset;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SproutRadius.hero),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          SproutSpacing.pageHorizontal,
          SproutSpacing.sm,
          SproutSpacing.pageHorizontal,
          bottomInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: SproutSpacing.md),
            Align(
                alignment: Alignment.centerRight,
                child: _CloseButton(onTap: onClose)),
            child,
          ],
        ),
      ),
    );
  }
}

class _CategoryStep extends StatelessWidget {
  const _CategoryStep({
    required this.onCategory,
    required this.onMore,
    required this.onIncome,
    required this.onImport,
  });

  final ValueChanged<_QuickCategory> onCategory;
  final VoidCallback onMore;
  final VoidCallback onIncome;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(QuickAddStrings.title,
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: SproutSpacing.xs),
        Text(
          QuickAddStrings.expenseHint,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: colors.muted),
        ),
        const SizedBox(height: SproutSpacing.xl),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final category in _primaryCategories)
              AddExpenseChip(
                label: category.label,
                icon: category.icon,
                tint: colors.mint,
                onTap: () => onCategory(category),
              ),
            AddExpenseChip(
              label: QuickAddStrings.more,
              icon: Icons.add_rounded,
              tint: colors.mint,
              onTap: onMore,
            ),
          ],
        ),
        const SizedBox(height: SproutSpacing.xxl),
        Row(
          children: [
            Expanded(
              child: _SecondaryButton(
                label: QuickAddStrings.iGotPaid,
                icon: Icons.savings_rounded,
                onTap: onIncome,
              ),
            ),
            const SizedBox(width: SproutSpacing.md),
            Expanded(
              child: _SecondaryButton(
                label: QuickAddStrings.import,
                icon: Icons.upload_file_rounded,
                onTap: onImport,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AmountStep extends StatelessWidget {
  const _AmountStep({
    required this.accounts,
    required this.category,
    required this.amount,
    required this.controller,
    required this.focusNode,
    required this.customOpen,
    required this.pocket,
    required this.date,
    required this.validation,
    required this.onBack,
    required this.onPreset,
    required this.onCustomTap,
    required this.onPocket,
    required this.onDateTap,
    required this.onConfirm,
  });

  final _QuickCategory category;
  final List<SproutAccount> accounts;
  final int? amount;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool customOpen;
  final SproutAccount pocket;
  final DateTime date;
  final String? validation;
  final VoidCallback onBack;
  final ValueChanged<int> onPreset;
  final VoidCallback onCustomTap;
  final ValueChanged<SproutAccount> onPocket;
  final VoidCallback onDateTap;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final displayAmount = customOpen
        ? controller.text
        : (amount == null ? '' : amount.toString());
    final labelAmount = int.tryParse(displayAmount) ?? amount ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(
          icon: category.icon,
          label: category.label,
          tint: category.tint,
          onBack: onBack,
        ),
        const SizedBox(height: SproutSpacing.sm),
        Text(
          QuickAddStrings.amountHint,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: colors.muted),
        ),
        const SizedBox(height: SproutSpacing.xl),
        SproutButtonPress(
          onTap: onCustomTap,
          semanticLabel: QuickAddStrings.customAmount,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: SproutSpacing.lg,
              vertical: SproutSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: SproutColors.tintMint,
              borderRadius: BorderRadius.circular(SproutRadius.card),
              border:
                  Border.all(color: SproutColors.seed.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: SproutColors.leaf,
                      ),
                ),
                const SizedBox(height: SproutSpacing.xs),
                Text(
                  labelAmount <= 0
                      ? 'Tap to enter'
                      : SproutFormat.currency(labelAmount),
                  style: SproutType.moneyValue(
                    color: colors.ink,
                    size: SproutTypeScale.s37,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (customOpen) ...[
          const SizedBox(height: SproutSpacing.md),
          TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: QuickAddStrings.customAmount,
              prefixText: 'PKR ',
            ),
            onChanged: (_) {
              // The parent reads the controller on confirm; rebuild locally
              // through the text field's own input state.
            },
          ),
        ],
        const SizedBox(height: SproutSpacing.lg),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in category.presets)
              _PresetChip(
                label: SproutFormat.compactCurrency(preset),
                selected: preset == amount && !customOpen,
                onTap: () => onPreset(preset),
              ),
          ],
        ),
        const SizedBox(height: SproutSpacing.lg),
        Text(QuickAddStrings.pocket,
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: SproutSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final account in accounts)
              _PocketChip(
                account: account,
                selected: account.id == pocket.id,
                onTap: () => onPocket(account),
              ),
          ],
        ),
        const SizedBox(height: SproutSpacing.lg),
        _DateAffordance(date: date, onTap: onDateTap),
        const SizedBox(height: SproutSpacing.md),
        _ValidationSlot(text: validation),
        const SizedBox(height: SproutSpacing.md),
        _PrimaryButton(
          label: labelAmount <= 0
              ? 'Log ${category.label}'
              : 'Log ${SproutFormat.compactCurrency(labelAmount)} ${category.label}',
          icon: Icons.check_rounded,
          onTap: onConfirm,
        ),
      ],
    );
  }
}

class _IncomeStep extends StatelessWidget {
  const _IncomeStep({
    required this.accounts,
    required this.controller,
    required this.kind,
    required this.pocket,
    required this.validation,
    required this.onBack,
    required this.onKind,
    required this.onPocket,
    required this.onConfirm,
  });

  final TextEditingController controller;
  final List<SproutAccount> accounts;
  final _IncomeKind kind;
  final SproutAccount pocket;
  final String? validation;
  final VoidCallback onBack;
  final ValueChanged<_IncomeKind> onKind;
  final ValueChanged<SproutAccount> onPocket;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final amount =
        int.tryParse(controller.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlainHeader(
          title: QuickAddStrings.incomeTitle,
          hint: QuickAddStrings.incomeHint,
          onBack: onBack,
        ),
        const SizedBox(height: SproutSpacing.xl),
        TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: 'PKR ',
          ),
        ),
        const SizedBox(height: SproutSpacing.lg),
        Text(QuickAddStrings.incomeType,
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: SproutSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final incomeKind in _IncomeKind.values)
              _IconChoiceChip(
                label: incomeKind.label,
                icon: incomeKind.icon,
                selected: incomeKind == kind,
                onTap: () => onKind(incomeKind),
              ),
          ],
        ),
        const SizedBox(height: SproutSpacing.lg),
        Text('To', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: SproutSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final account in accounts)
              _PocketChip(
                account: account,
                selected: account.id == pocket.id,
                onTap: () => onPocket(account),
              ),
          ],
        ),
        const SizedBox(height: SproutSpacing.md),
        _ValidationSlot(text: validation),
        const SizedBox(height: SproutSpacing.md),
        _PrimaryButton(
          label: amount <= 0
              ? 'Save income'
              : 'Save ${SproutFormat.compactCurrency(amount)} ${kind.label}',
          icon: Icons.check_rounded,
          onTap: onConfirm,
        ),
        const SizedBox(height: SproutSpacing.sm),
        Text(
          'Manual income updates Money right away.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: colors.muted),
        ),
      ],
    );
  }
}

class _MoreStep extends StatelessWidget {
  const _MoreStep({
    required this.controller,
    required this.validation,
    required this.onBack,
    required this.onCategory,
    required this.onCustom,
  });

  final TextEditingController controller;
  final String? validation;
  final VoidCallback onBack;
  final ValueChanged<_QuickCategory> onCategory;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlainHeader(
          title: 'More categories',
          hint: 'Pick one, or name your own.',
          onBack: onBack,
        ),
        const SizedBox(height: SproutSpacing.xl),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final category in _moreCategories)
              AddExpenseChip(
                label: category.label,
                icon: category.icon,
                tint: category.tint,
                onTap: () => onCategory(category),
              ),
          ],
        ),
        const SizedBox(height: SproutSpacing.xl),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Custom category',
            hintText: 'e.g. tailor, parking',
          ),
        ),
        if (validation != null) ...[
          const SizedBox(height: SproutSpacing.md),
          _ValidationLine(text: validation!),
        ],
        const SizedBox(height: SproutSpacing.lg),
        _PrimaryButton(
          label: 'Use custom category',
          icon: Icons.add_rounded,
          onTap: onCustom,
        ),
      ],
    );
  }
}

class _ImportStep extends StatelessWidget {
  const _ImportStep({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlainHeader(
          title: QuickAddStrings.importTitle,
          hint: QuickAddStrings.importHint,
          onBack: onBack,
        ),
        const SizedBox(height: SproutSpacing.xl),
        const ImportStatementCard(),
      ],
    );
  }
}

class _SuccessStep extends StatelessWidget {
  const _SuccessStep({
    required this.accounts,
    required this.transaction,
    required this.onAddAnother,
    required this.onDone,
  });

  final SproutTransaction transaction;
  final List<SproutAccount> accounts;
  final VoidCallback onAddAnother;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final isIncome = transaction.type == TransactionType.income;
    final contextLine = isIncome
        ? '${transaction.category} added to ${_accountName(transaction.accountId, accounts)}.'
        : '${transaction.category} saved from ${_accountName(transaction.accountId, accounts)}.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: SproutColors.tintMint,
                  shape: BoxShape.circle,
                ),
              ),
              const SproutMascot(
                state: SproutMascotState.thumbsUp,
                size: 82,
                enableBlink: false,
              ),
              Positioned(
                right: 2,
                bottom: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: SproutColors.seed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SproutSpacing.lg),
        Text(
          '${QuickAddStrings.logged} ${_categoryEmoji(transaction.category)} '
          '${SproutFormat.currency(transaction.amount)}',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: colors.ink),
        ),
        const SizedBox(height: SproutSpacing.sm),
        Text(
          contextLine,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: colors.muted),
        ),
        const SizedBox(height: SproutSpacing.xs),
        Text(
          QuickAddStrings.savedNote,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SproutColors.leaf,
                fontSize: 12,
              ),
        ),
        const SizedBox(height: SproutSpacing.xl),
        Row(
          children: [
            Expanded(
              child: _SecondaryButton(
                label: QuickAddStrings.addAnother,
                icon: Icons.add_rounded,
                onTap: onAddAnother,
              ),
            ),
            const SizedBox(width: SproutSpacing.md),
            Expanded(
              child: _PrimaryButton(
                label: QuickAddStrings.done,
                icon: Icons.check_rounded,
                onTap: onDone,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.icon,
    required this.label,
    required this.tint,
    required this.onBack,
  });

  final IconData icon;
  final String label;
  final Color tint;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Row(
      children: [
        _BackButton(onTap: onBack),
        const SizedBox(width: SproutSpacing.md),
        CircleAvatar(
          radius: 21,
          backgroundColor: tint,
          child: Icon(icon, color: SproutColors.leaf, size: 20),
        ),
        const SizedBox(width: SproutSpacing.md),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: colors.ink),
          ),
        ),
      ],
    );
  }
}

class _PlainHeader extends StatelessWidget {
  const _PlainHeader({
    required this.title,
    required this.hint,
    required this.onBack,
  });

  final String title;
  final String hint;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BackButton(onTap: onBack),
        const SizedBox(width: SproutSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: SproutSpacing.xs),
              Text(
                hint,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: SproutColors.tintMint,
      checkmarkColor: SproutColors.seed,
    );
  }
}

class _PocketChip extends StatelessWidget {
  const _PocketChip({
    required this.account,
    required this.selected,
    required this.onTap,
  });

  final SproutAccount account;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(account.name),
      selected: selected,
      onSelected: (_) {
        HapticFeedback.lightImpact();
        onTap();
      },
      selectedColor: SproutColors.tintMint,
      checkmarkColor: SproutColors.seed,
    );
  }
}

class _IconChoiceChip extends StatelessWidget {
  const _IconChoiceChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return ChoiceChip(
      avatar: Icon(icon,
          size: 17, color: selected ? SproutColors.leaf : colors.muted),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: SproutColors.tintMint,
      checkmarkColor: SproutColors.seed,
    );
  }
}

class _DateAffordance extends StatelessWidget {
  const _DateAffordance({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final label = _relativeDateLabel(date);
    return SproutButtonPress(
      onTap: onTap,
      semanticLabel: 'Change log date',
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(
          horizontal: SproutSpacing.md,
          vertical: SproutSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(SproutRadius.card),
          border: Border.all(color: colors.line.withValues(alpha: 0.7)),
        ),
        child: Row(
          children: [
            Icon(Icons.today_rounded, color: colors.muted, size: 18),
            const SizedBox(width: SproutSpacing.sm),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colors.muted),
            ),
            const Spacer(),
            Icon(Icons.more_horiz_rounded, color: colors.muted, size: 22),
          ],
        ),
      ),
    );
  }
}

class _DateOptionTile extends StatelessWidget {
  const _DateOptionTile({
    required this.label,
    required this.date,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: selected ? SproutColors.tintMint : colors.background,
        child: Icon(
          selected ? Icons.check_rounded : Icons.today_rounded,
          color: selected ? SproutColors.leaf : colors.muted,
        ),
      ),
      title: Text(label, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        SproutFormat.date(date),
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: colors.muted),
      ),
      onTap: onTap,
    );
  }
}

class _ValidationLine extends StatelessWidget {
  const _ValidationLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: SproutColors.goldInk,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _ValidationSlot extends StatelessWidget {
  const _ValidationSlot({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('quick-add-validation-slot'),
      height: 24,
      child: Align(
        alignment: Alignment.centerLeft,
        child: text == null
            ? const SizedBox.shrink()
            : _ValidationLine(text: text!),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SproutButtonPress(
      onTap: onTap,
      scale: 0.98,
      semanticLabel: label,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: SproutSpacing.lg,
          vertical: SproutSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: SproutColors.seed,
          borderRadius: BorderRadius.circular(SproutRadius.pill),
          boxShadow: [
            const BoxShadow(
              color: SproutColors.leaf,
              blurRadius: 0,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: SproutColors.seed.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: SproutSpacing.sm),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      semanticLabel: 'Back',
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
        padding: const EdgeInsets.symmetric(
          horizontal: SproutSpacing.md,
          vertical: SproutSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: colors.line.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(SproutRadius.tile),
          border: Border.all(color: colors.line.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colors.muted, size: 18),
            const SizedBox(width: SproutSpacing.sm),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.ink,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickCategory {
  const _QuickCategory({
    required this.label,
    required this.icon,
    required this.tint,
    required this.smartDefault,
    required this.presets,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final int? smartDefault;
  final List<int> presets;
}

const _primaryCategories = [
  _QuickCategory(
    label: 'Chai',
    icon: Icons.coffee_rounded,
    tint: SproutColors.tintMint,
    smartDefault: 200,
    presets: [100, 200, 300, 500],
  ),
  _QuickCategory(
    label: 'Groceries',
    icon: Icons.shopping_cart_rounded,
    tint: SproutColors.tintSky,
    smartDefault: 2500,
    presets: [1000, 2500, 5000, 7500],
  ),
  _QuickCategory(
    label: 'Fuel',
    icon: Icons.local_gas_station_rounded,
    tint: SproutColors.tintWarm,
    smartDefault: 5000,
    presets: [2000, 5000, 8500, 12000],
  ),
  _QuickCategory(
    label: 'Ride',
    icon: Icons.local_taxi_rounded,
    tint: SproutColors.tintLilac,
    smartDefault: 450,
    presets: [250, 450, 700, 1000],
  ),
  _QuickCategory(
    label: 'Mobile Load',
    icon: Icons.phone_android_rounded,
    tint: SproutColors.tintGold,
    smartDefault: 1000,
    presets: [500, 1000, 1500, 2000],
  ),
  _QuickCategory(
    label: 'Utility Bill',
    icon: Icons.receipt_long_rounded,
    tint: SproutColors.tintSky,
    smartDefault: 8000,
    presets: [3000, 5000, 8000, 12000],
  ),
  _QuickCategory(
    label: 'School Fee',
    icon: Icons.school_rounded,
    tint: SproutColors.tintMint,
    smartDefault: 15000,
    presets: [10000, 15000, 25000, 40000],
  ),
  _QuickCategory(
    label: 'Medicine',
    icon: Icons.medication_rounded,
    tint: SproutColors.tintWarm,
    smartDefault: 1200,
    presets: [500, 1200, 2500, 5000],
  ),
  _QuickCategory(
    label: 'Shopping',
    icon: Icons.shopping_bag_rounded,
    tint: SproutColors.tintLilac,
    smartDefault: 3000,
    presets: [1500, 3000, 5000, 10000],
  ),
  _QuickCategory(
    label: 'Food',
    icon: Icons.restaurant_rounded,
    tint: SproutColors.tintGold,
    smartDefault: 800,
    presets: [500, 800, 1200, 2000],
  ),
  _QuickCategory(
    label: 'Zakat',
    icon: Icons.volunteer_activism_rounded,
    tint: SproutColors.tintMint,
    smartDefault: null,
    presets: [1000, 2500, 5000, 10000],
  ),
  _QuickCategory(
    label: 'Sadaqah',
    icon: Icons.favorite_rounded,
    tint: SproutColors.tintMint,
    smartDefault: 500,
    presets: [100, 500, 1000, 2500],
  ),
  _QuickCategory(
    label: 'Committee',
    icon: Icons.groups_rounded,
    tint: SproutColors.tintSky,
    smartDefault: 10000,
    presets: [5000, 10000, 20000, 50000],
  ),
];

const _moreCategories = [
  _QuickCategory(
    label: 'Parking',
    icon: Icons.local_parking_rounded,
    tint: SproutColors.tintSky,
    smartDefault: 100,
    presets: [50, 100, 200, 500],
  ),
  _QuickCategory(
    label: 'Home',
    icon: Icons.home_repair_service_rounded,
    tint: SproutColors.tintWarm,
    smartDefault: 1500,
    presets: [500, 1500, 3000, 5000],
  ),
  _QuickCategory(
    label: 'Eidi',
    icon: Icons.celebration_rounded,
    tint: SproutColors.tintGold,
    smartDefault: 1000,
    presets: [500, 1000, 2500, 5000],
  ),
  _QuickCategory(
    label: 'Other',
    icon: Icons.more_horiz_rounded,
    tint: SproutColors.tintMint,
    smartDefault: null,
    presets: [100, 500, 1000, 2500],
  ),
];

String _accountName(String? accountId, List<SproutAccount> accounts) {
  for (final account in accounts) {
    if (account.id == accountId) return account.name;
  }
  return 'Cash';
}

String _categoryEmoji(String category) {
  return switch (category) {
    'Chai' => '☕',
    'Food' => '🍽',
    'Groceries' => '🛒',
    'Fuel' => '⛽',
    'Ride' => '🚕',
    'Salary' => '💼',
    'Freelance' => '💻',
    'Gift' => '🎁',
    _ => '',
  };
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _relativeDateLabel(DateTime date) {
  final today = DateTime.now();
  if (_isSameDay(date, today)) return QuickAddStrings.today;
  if (_isSameDay(date, today.subtract(const Duration(days: 1)))) {
    return 'Yesterday';
  }
  return SproutFormat.date(date);
}
