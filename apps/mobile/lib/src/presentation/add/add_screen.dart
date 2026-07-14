import 'package:flutter/material.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../data/mock_sprout_data.dart';
import '../../domain/sprout_models.dart';
import '../../theme/sprout_tokens.dart';
import '../../theme/sprout_theme.dart';
import '../../widgets/sprout_mascot.dart';
import '../../widgets/sprout_mascot_state.dart';
import '../../widgets/sprout_panel.dart';
import '../../widgets/sprout_states.dart';
import '../../widgets/transaction_row.dart';
import 'add_widgets.dart';

/// The fastest way to log or import money activity in Sprout.
///
/// Everything here works with zero connected accounts — the manual Cash
/// account is always available. The screen stays calm: no scary red, no
/// guilt copy, just small doable actions.
class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _scrollController = ScrollController();
  final _chipsKey = GlobalKey();
  late final List<SproutTransaction> _recent = [...mockTransactions];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    // Brief calm load so the loading state is a real path, not a flash.
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToChips() {
    final ctx = _chipsKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.0,
      duration: const Duration(milliseconds: 350),
      curve: SproutCurves.standard,
    );
  }

  Future<void> _onChipTap(String category) async {
    final txn = await showExpenseSheet(context, category: category);
    if (txn != null) _addTransaction(txn);
  }

  void _onIncomeSaved(SproutTransaction txn) => _addTransaction(txn);

  void _addTransaction(SproutTransaction txn) {
    setState(() => _recent.insert(0, txn));
    _showSuccess();
  }

  void _showSuccess() {
    final reduced = MediaQuery.of(context).disableAnimations;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
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
                  AddStrings.saved,
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
    if (_loading) {
      return const SproutLoadingView(label: AddStrings.loading);
    }
    if (_error) {
      return SproutErrorView(
        message: AddStrings.error,
        onRetry: () => setState(() => _error = false),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            SproutSpacing.pageHorizontal,
            SproutSpacing.pageTop,
            SproutSpacing.pageHorizontal,
            SproutSpacing.pageBottom,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                _Header(onQuickAdd: _scrollToChips),
                const SizedBox(height: SproutSpacing.lg),
                _QuickExpenseSection(
                  key: _chipsKey,
                  onChipTap: _onChipTap,
                ),
                const SizedBox(height: SproutSpacing.xl),
                _IncomeSection(onSaved: _onIncomeSaved),
                const SizedBox(height: SproutSpacing.xl),
                const ImportStatementCard(),
                const SizedBox(height: SproutSpacing.xl),
                _RecentSection(recent: _recent, onQuickAdd: _scrollToChips),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onQuickAdd});

  final VoidCallback onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: SproutSpacing.xs),
              Text(
                'Log something in 10 seconds.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colors.muted),
              ),
            ],
          ),
        ),
        SproutButtonPress(
          onTap: onQuickAdd,
          semanticLabel: 'Quick add',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: SproutColors.mint,
              borderRadius: BorderRadius.circular(SproutRadius.pill),
              border:
                  Border.all(color: SproutColors.seed.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded,
                    color: SproutColors.seed, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Quick add',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: SproutColors.leaf,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickExpenseSection extends StatelessWidget {
  const _QuickExpenseSection({required this.onChipTap, super.key});

  final Future<void> Function(String category) onChipTap;

  @override
  Widget build(BuildContext context) {
    return SproutRaisedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AddSectionHeader(
            title: AddStrings.sectionQuickExpense,
            hint: AddStrings.sectionQuickExpenseHint,
          ),
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
            ],
          ),
        ],
      ),
    );
  }
}

/// Quick add income section, wrapped in a raised panel.
class _IncomeSection extends StatelessWidget {
  const _IncomeSection({required this.onSaved});

  final ValueChanged<SproutTransaction> onSaved;

  @override
  Widget build(BuildContext context) {
    return SproutRaisedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AddSectionHeader(
            title: AddStrings.sectionIncome,
            hint: AddStrings.sectionIncomeHint,
          ),
          IncomeForm(onSaved: onSaved),
        ],
      ),
    );
  }
}

class _RecentSection extends StatelessWidget {
  const _RecentSection({
    required this.recent,
    required this.onQuickAdd,
  });

  final List<SproutTransaction> recent;
  final VoidCallback onQuickAdd;

  @override
  Widget build(BuildContext context) {
    return SproutRaisedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AddSectionHeader(
            title: AddStrings.recentTitle,
            hint: AddStrings.recentHint,
          ),
          if (recent.isEmpty)
            SproutEmptyView(
              title: AddStrings.emptyTitle,
              subtitle: AddStrings.emptySubtitle,
              actionLabel: AddStrings.emptyAction,
              onAction: onQuickAdd,
            )
          else
            for (final txn in recent) TransactionRow(transaction: txn),
        ],
      ),
    );
  }
}
