import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/goal_store.dart';
import '../../domain/today_models.dart';
import '../../theme/sprout_tokens.dart';
import '../../theme/sprout_theme.dart';

/// The shared goal editor — reached from Settings and from tapping a goal.
/// One component, two entry points. Handles add, edit, contribute, complete,
/// and delete.
///
/// Goals are tracking, not accounts — completing or deleting a goal never
/// implies the user's money changed. Copy makes that clear.
class GoalEditorSheet extends ConsumerStatefulWidget {
  const GoalEditorSheet({this.goal, super.key});

  /// The goal to edit. If null, opens in "add new goal" mode.
  final Goal? goal;

  /// Opens the goal editor as a bottom sheet.
  static void open(BuildContext context, {Goal? goal}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalEditorSheet(goal: goal),
    );
  }

  @override
  ConsumerState<GoalEditorSheet> createState() => _GoalEditorSheetState();
}

class _GoalEditorSheetState extends ConsumerState<GoalEditorSheet> {
  late final _nameController =
      TextEditingController(text: widget.goal?.name ?? '');
  late final _targetController = TextEditingController(
    text: widget.goal != null ? '${widget.goal!.targetAmount}' : '',
  );
  late String _selectedType = widget.goal?.type ?? 'car';
  late bool _isPrimary = widget.goal?.isPrimary ?? false;
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.goal != null;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  static const _goalTypes = [
    ('emergency', Icons.health_and_safety_rounded, 'Emergency'),
    ('car', Icons.directions_car_rounded, 'Car'),
    ('home', Icons.home_rounded, 'Home'),
    ('education', Icons.school_rounded, 'Education'),
    ('travel', Icons.flight_rounded, 'Travel'),
    ('eidi', Icons.card_giftcard_rounded, 'Eidi'),
    ('zakat', Icons.volunteer_activism_rounded, 'Zakat'),
    ('custom', Icons.star_rounded, 'Custom'),
  ];

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();

    final name = _nameController.text.trim();
    final target = int.tryParse(_targetController.text.trim()) ?? 0;
    final store = ref.read(goalStoreProvider.notifier);

    if (_isEditing) {
      final existing = widget.goal!;
      store.update(
          existing.id,
          existing.copyWith(
            name: name,
            type: _selectedType,
            targetAmount: target,
            isPrimary: _isPrimary,
            remainingToTarget:
                (target - existing.currentAmount).clamp(0, 999999999),
            status:
                existing.currentAmount >= target ? 'complete' : existing.status,
          ));
    } else {
      final id = 'goal-${DateTime.now().millisecondsSinceEpoch}';
      store.add(Goal(
        id: id,
        name: name,
        type: _selectedType,
        targetAmount: target,
        currentAmount: 0,
        status: 'active',
        pace: 'on_track',
        nextStep: 'Start saving toward $name',
        remainingToTarget: target,
        paceNote: 'PKR ${_formatCompact(target)} to go.',
        isPrimary: _isPrimary,
      ));
    }

    Navigator.pop(context);
  }

  void _contribute(int amount) {
    if (widget.goal == null) return;
    HapticFeedback.lightImpact();
    ref.read(goalStoreProvider.notifier).contribute(widget.goal!.id, amount);
    Navigator.pop(context);
  }

  void _complete() {
    if (widget.goal == null) return;
    HapticFeedback.mediumImpact();
    ref.read(goalStoreProvider.notifier).complete(widget.goal!.id);
    Navigator.pop(context);
  }

  void _delete() {
    if (widget.goal == null) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this goal?'),
        content: Text(
          'Your money isn\'t affected — this just stops tracking '
          '${widget.goal!.name}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep goal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(goalStoreProvider.notifier).delete(widget.goal!.id);
              Navigator.pop(context); // Close the sheet too.
            },
            style: TextButton.styleFrom(foregroundColor: SproutColors.tomato),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      color: colors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colors.line,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Title
                  Text(
                    _isEditing ? 'Edit goal' : 'New goal',
                    style: SproutType.playfulLabel(
                      color: colors.ink,
                      size: SproutTypeScale.s18,
                      weight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: SproutSpacing.lg),

                  // Type chips
                  Text(
                    'What are you saving for?',
                    style: SproutType.body(
                      color: colors.muted,
                      size: SproutTypeScale.s14,
                      weight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: SproutSpacing.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _goalTypes.map((t) {
                      final selected = _selectedType == t.$1;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedType = t.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? SproutColors.seed.withValues(alpha: 0.12)
                                : colors.line.withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(SproutRadius.pill),
                            border: selected
                                ? Border.all(
                                    color: SproutColors.seed, width: 1.5)
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(t.$2,
                                  size: 16,
                                  color: selected
                                      ? SproutColors.seed
                                      : colors.muted),
                              const SizedBox(width: 6),
                              Text(
                                t.$3,
                                style: SproutType.body(
                                  color:
                                      selected ? SproutColors.seed : colors.ink,
                                  size: SproutTypeScale.s14,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: SproutSpacing.lg),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Goal name',
                      labelStyle: SproutType.body(
                        color: colors.muted,
                        size: SproutTypeScale.s14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: SproutType.body(
                      color: colors.ink,
                      size: SproutTypeScale.s14,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Give your goal a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: SproutSpacing.md),

                  // Target amount field
                  TextFormField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Target amount (PKR)',
                      labelStyle: SproutType.body(
                        color: colors.muted,
                        size: SproutTypeScale.s14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: SproutType.body(
                      color: colors.ink,
                      size: SproutTypeScale.s14,
                    ),
                    validator: (value) {
                      final parsed = int.tryParse(value ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a target amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: SproutSpacing.md),

                  // Primary goal toggle
                  if (_isEditing || ref.watch(goalStoreProvider).isEmpty)
                    CheckboxListTile(
                      value: _isPrimary,
                      onChanged: (v) => setState(() => _isPrimary = v ?? false),
                      title: Text(
                        'Make this the goal Today references',
                        style: SproutType.body(
                          color: colors.ink,
                          size: SproutTypeScale.s14,
                          weight: FontWeight.w500,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                      activeColor: SproutColors.seed,
                    ),

                  // Editing-only actions
                  if (_isEditing) ...[
                    const SizedBox(height: SproutSpacing.md),
                    // Contribute
                    OutlinedButton.icon(
                      onPressed: () => _showContributeDialog(),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add to this goal'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SproutColors.seed,
                        side: BorderSide(
                            color: SproutColors.seed.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: SproutSpacing.sm),
                    // Complete
                    if (widget.goal!.status != 'complete')
                      TextButton.icon(
                        onPressed: _complete,
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: const Text('Mark as complete'),
                        style: TextButton.styleFrom(
                          foregroundColor: SproutColors.seed,
                        ),
                      ),
                    const SizedBox(height: SproutSpacing.sm),
                    // Delete
                    TextButton.icon(
                      onPressed: _delete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Remove this goal'),
                      style: TextButton.styleFrom(
                        foregroundColor: SproutColors.tomato,
                      ),
                    ),
                  ],

                  const SizedBox(height: SproutSpacing.lg),
                  // Save button
                  FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: SproutColors.seed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'Save changes' : 'Add goal',
                      style: SproutType.body(
                        color: Colors.white,
                        size: SproutTypeScale.s14,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showContributeDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to ${widget.goal!.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (PKR)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = int.tryParse(controller.text.trim()) ?? 0;
              if (amount > 0) {
                Navigator.pop(context);
                _contribute(amount);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _formatCompact(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 100000) {
      return '${(value / 100000).round()} lakh';
    } else if (value >= 1000) {
      return '${(value / 1000).round()}k';
    }
    return value.toString();
  }
}
