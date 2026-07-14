import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/api/sprout_api_client.dart';
import '../../data/onboarding_store.dart';
import '../../theme/sprout_tokens.dart';
import '../../theme/sprout_theme.dart';
import '../../widgets/sprout_mascot.dart';
import '../../widgets/sprout_mascot_state.dart';

/// A local-first, one-question-per-screen conversation with Sprout.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _store = OnboardingStore();
  int _step = 0;
  String? _goalType;
  String? _goalName;
  String? _error;
  bool _saving = false;

  static const _goals = [
    ('emergency', 'Emergency cushion', Icons.health_and_safety_rounded),
    ('car', 'A car', Icons.directions_car_rounded),
    ('home', 'A home', Icons.home_rounded),
    ('education', 'Learning', Icons.school_rounded),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.lightImpact();
    setState(() => _error = null);
    if (_step == 0) return setState(() => _step = 1);
    if (_step == 1) return setState(() => _step = 2);
    if (_step == 2) {
      if (_goalType == null) {
        return setState(() => _error = 'Pick one, or let me help later.');
      }
      final selected = _goals.where((g) => g.$1 == _goalType);
      _goalName = selected.isEmpty ? null : selected.first.$2;
      return setState(() => _step = 3);
    }
    _finish();
  }

  void _skipName() {
    _nameController.clear();
    _next();
  }

  void _skipGoal() {
    _goalType = null;
    _goalName = null;
    _targetController.clear();
    _finish();
  }

  Future<void> _finish() async {
    if (_step == 3 && _targetController.text.trim().isNotEmpty) {
      final amount = int.tryParse(_targetController.text.trim());
      if (amount == null || amount <= 0) {
        return setState(
            () => _error = 'Add a whole PKR amount when you are ready.');
      }
    }
    setState(() => _saving = true);
    final amount = int.tryParse(_targetController.text.trim());
    final name = _nameController.text.trim();
    await _store.save(
      name: name.isEmpty ? null : name,
      goalName: amount == null ? null : _goalName,
      goalType: amount == null ? null : _goalType,
      targetAmount: amount,
    );

    // The API is opt-in until the app's auth/session surface supplies a token.
    // Local completion remains the source of truth for offline and signed-out use.
    try {
      final client = ref.read(apiClientProvider);
      await client.completeOnboarding(
        name: name.isEmpty ? null : name,
        goalName: amount == null ? null : _goalName,
        goalType: amount == null ? null : _goalType,
        targetAmount: amount,
      );
    } on SproutApiException catch (error) {
      if (error.statusCode != 401 && error.statusCode != 403) {
        // Sync is intentionally non-blocking; the local draft is safe.
        debugPrint('Onboarding saved locally; sync pending: $error');
      }
    } catch (error) {
      debugPrint('Onboarding saved locally; sync pending: $error');
    }

    if (!mounted) return;
    setState(() {
      _saving = false;
      _step = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final isCelebration = _step == 4;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SproutSpacing.pageHorizontal,
            SproutSpacing.pageTop,
            SproutSpacing.pageHorizontal,
            SproutSpacing.pageBottom,
          ),
          child: Column(
            children: [
              if (!isCelebration) _Progress(step: _step, colors: colors),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: _content(colors),
                ),
              ),
              if (!isCelebration) _bottomActions(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(SproutColorScheme colors) {
    switch (_step) {
      case 0:
        return _Welcome(colors: colors, key: const ValueKey('welcome'));
      case 1:
        return _NameStep(
            controller: _nameController,
            colors: colors,
            key: const ValueKey('name'));
      case 2:
        return _GoalStep(
          selected: _goalType,
          colors: colors,
          onSelect: (type) => setState(() => _goalType = type),
          key: const ValueKey('goal'),
        );
      case 3:
        return _TargetStep(
            controller: _targetController,
            goalName: _goalName!,
            colors: colors,
            key: const ValueKey('target'));
      default:
        return _Celebration(
            name: _nameController.text.trim(),
            colors: colors,
            key: const ValueKey('done'));
    }
  }

  Widget _bottomActions(SproutColorScheme colors) {
    final isGoal = _step == 2;
    final isTarget = _step == 3;
    return Column(
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: SproutSpacing.md),
            child: Text(_error!, style: SproutType.body(color: colors.muted)),
          ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving
                ? null
                : (isGoal
                    ? _next
                    : isTarget
                        ? _finish
                        : _next),
            style: FilledButton.styleFrom(
              backgroundColor: SproutColors.seed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: SproutSpacing.lg),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SproutRadius.pill)),
            ),
            child: Text(_saving
                ? 'Saving your little garden…'
                : isTarget
                    ? 'Plant this goal'
                    : 'Continue'),
          ),
        ),
        const SizedBox(height: SproutSpacing.sm),
        TextButton(
          onPressed: _saving
              ? null
              : (isGoal
                  ? _skipGoal
                  : _step == 1
                      ? _skipName
                      : _finish),
          child: Text(
              isGoal
                  ? 'Help me decide later'
                  : _step == 1
                      ? 'Just call me friend'
                      : 'Skip for now',
              style: TextStyle(color: colors.muted)),
        ),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.step, required this.colors});
  final int step;
  final SproutColorScheme colors;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: LinearProgressIndicator(
                value: (step + 1) / 4,
                minHeight: SproutSpacing.sm,
                borderRadius: BorderRadius.circular(SproutRadius.pill),
                backgroundColor: colors.line,
                color: SproutColors.seed)),
        const SizedBox(width: SproutSpacing.md),
        Text('${step + 1} of 4', style: SproutType.body(color: colors.muted)),
      ]);
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.colors, super.key});
  final SproutColorScheme colors;
  @override
  Widget build(BuildContext context) => _CenteredColumn(
      colors: colors,
      mascot: const SproutMascot(
          state: SproutMascotState.happy, size: 128, playOnMount: true),
      title: "Hi, I'm Sprout.",
      body:
          'A calm 20-second money check-in.\nNo bank connection needed — we can start with just you.');
}

class _NameStep extends StatelessWidget {
  const _NameStep({required this.controller, required this.colors, super.key});
  final TextEditingController controller;
  final SproutColorScheme colors;
  @override
  Widget build(BuildContext context) => _QuestionColumn(
      colors: colors,
      title: 'What should I call you?',
      why: 'So the check-in feels like it is for you.',
      child: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
              hintText: 'A nickname is fine',
              prefixIcon: Icon(Icons.edit_rounded))));
}

class _GoalStep extends StatelessWidget {
  const _GoalStep(
      {required this.selected,
      required this.colors,
      required this.onSelect,
      super.key});
  final String? selected;
  final SproutColorScheme colors;
  final ValueChanged<String> onSelect;
  @override
  Widget build(BuildContext context) => _QuestionColumn(
      colors: colors,
      title: 'What should your money protect?',
      why: 'One goal gives today’s check-in a gentle direction.',
      child: Column(
          children: _OnboardingScreenState._goals
              .map((goal) => Padding(
                  padding: const EdgeInsets.only(bottom: SproutSpacing.md),
                  child: _Choice(
                      label: goal.$2,
                      icon: goal.$3,
                      selected: selected == goal.$1,
                      onTap: () => onSelect(goal.$1),
                      colors: colors)))
              .toList()));
}

class _TargetStep extends StatelessWidget {
  const _TargetStep(
      {required this.controller,
      required this.goalName,
      required this.colors,
      super.key});
  final TextEditingController controller;
  final String goalName;
  final SproutColorScheme colors;
  @override
  Widget build(BuildContext context) => _QuestionColumn(
      colors: colors,
      title: 'What would feel useful for $goalName?',
      why:
          'A target helps me show the next small step. You can change it later.',
      child: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
              prefixText: 'PKR ', hintText: 'Target amount')));
}

class _Celebration extends StatelessWidget {
  const _Celebration({required this.name, required this.colors, super.key});
  final String name;
  final SproutColorScheme colors;
  @override
  Widget build(BuildContext context) => _CenteredColumn(
      colors: colors,
      mascot: const SproutMascot(
          state: SproutMascotState.happy, size: 140, playOnMount: true),
      title: 'Your garden is planted${name.isEmpty ? '' : ', $name'} 🌱',
      body:
          'You can add money manually, connect something later, or simply look around. Sprout is ready.',
      button: FilledButton(
          onPressed: () => context.go('/today'),
          child: const Text('See my Today')));
}

class _CenteredColumn extends StatelessWidget {
  const _CenteredColumn(
      {required this.colors,
      required this.mascot,
      required this.title,
      required this.body,
      this.button});
  final SproutColorScheme colors;
  final Widget mascot;
  final String title;
  final String body;
  final Widget? button;
  @override
  Widget build(BuildContext context) => Center(
          child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
            mascot,
            const SizedBox(height: SproutSpacing.xl),
            Text(title,
                textAlign: TextAlign.center,
                style: SproutType.playfulTitle(
                    color: colors.ink, size: SproutTypeScale.s29)),
            const SizedBox(height: SproutSpacing.md),
            Text(body,
                textAlign: TextAlign.center,
                style: SproutType.body(
                    color: colors.muted, size: SproutTypeScale.s18)),
            if (button != null) ...[
              const SizedBox(height: SproutSpacing.xl),
              button!
            ]
          ])));
}

class _QuestionColumn extends StatelessWidget {
  const _QuestionColumn(
      {required this.colors,
      required this.title,
      required this.why,
      required this.child});
  final SproutColorScheme colors;
  final String title;
  final String why;
  final Widget child;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: SproutSpacing.xxl),
        const SproutMascot(state: SproutMascotState.thinking, size: 84),
        const SizedBox(height: SproutSpacing.xl),
        Text(title,
            style: SproutType.playfulTitle(
                color: colors.ink, size: SproutTypeScale.s29)),
        const SizedBox(height: SproutSpacing.sm),
        Text(why,
            style: SproutType.body(
                color: colors.muted, size: SproutTypeScale.s18)),
        const SizedBox(height: SproutSpacing.xl),
        child
      ]));
}

class _Choice extends StatelessWidget {
  const _Choice(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap,
      required this.colors});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final SproutColorScheme colors;
  @override
  Widget build(BuildContext context) => Material(
      color: selected ? colors.mint : colors.surface,
      borderRadius: BorderRadius.circular(SproutRadius.tile),
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SproutRadius.tile),
          child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SproutSpacing.lg),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SproutRadius.tile),
                  border: Border.all(
                      color: selected ? SproutColors.seed : colors.line,
                      width: selected ? 2 : 1)),
              child: Row(children: [
                Icon(icon, color: selected ? SproutColors.leaf : colors.muted),
                const SizedBox(width: SproutSpacing.lg),
                Expanded(
                    child: Text(label,
                        style: SproutType.body(
                            color: colors.ink,
                            size: SproutTypeScale.s18,
                            weight: FontWeight.w700))),
                if (selected)
                  const Icon(Icons.check_circle_rounded,
                      color: SproutColors.seed)
              ]))));
}
