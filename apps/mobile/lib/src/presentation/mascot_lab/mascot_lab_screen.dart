import 'package:flutter/material.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../theme/sprout_tokens.dart';
import '../../theme/sprout_theme.dart';
import '../../widgets/sprout_mascot.dart';
import '../../widgets/sprout_mascot_state.dart';

class MascotLabScreen extends StatefulWidget {
  const MascotLabScreen({super.key});

  @override
  State<MascotLabScreen> createState() => _MascotLabScreenState();
}

class _MascotLabScreenState extends State<MascotLabScreen> {
  SproutMascotState _selected = SproutMascotState.happy;
  var _playKey = 0;

  static const _states = SproutMascotState.values;

  void _play() => setState(() => _playKey++);

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Mascot Lab'),
        backgroundColor: colors.background,
        foregroundColor: colors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _HeroFitCheck(
              state: _selected,
              playKey: _playKey,
              onPlay: _play,
            ),
            const SizedBox(height: 24),
            Text(
              'Still states',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _StateGrid(
              selected: _selected,
              states: _states,
              onSelected: (state) {
                setState(() => _selected = state);
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Size and background checks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const _StressRows(),
          ],
        ),
      ),
    );
  }
}

class _HeroFitCheck extends StatelessWidget {
  const _HeroFitCheck({
    required this.state,
    required this.playKey,
    required this.onPlay,
  });

  final SproutMascotState state;
  final int playKey;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);

    return Container(
      key: const ValueKey('mascot-lab-hero-fit'),
      clipBehavior: Clip.none,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(SproutRadius.hero),
        boxShadow: [
          BoxShadow(
            color: colors.ink.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mascotSize = constraints.maxWidth < 340 ? 112.0 : 136.0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hero fit check',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Speech, card edge, and mascot should never collide.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _BoundedMascotFrame(
                    size: mascotSize,
                    state: state,
                    animate: true,
                    playKey: playKey,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SpeechBubble(
                      text: _copyForState(state),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SproutButtonPress(
                    onTap: onPlay,
                    child: Container(
                      key: const ValueKey('mascot-lab-play'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: SproutColors.seed,
                        borderRadius: BorderRadius.circular(SproutRadius.pill),
                        border: const Border(
                          bottom: BorderSide(
                            color: Color(0xFF2F7E12),
                            width: 4,
                          ),
                        ),
                      ),
                      child: Text(
                        'Play once',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StateGrid extends StatelessWidget {
  const _StateGrid({
    required this.selected,
    required this.states,
    required this.onSelected,
  });

  final SproutMascotState selected;
  final List<SproutMascotState> states;
  final ValueChanged<SproutMascotState> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: const ValueKey('mascot-lab-state-grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: states.length,
      itemBuilder: (context, index) {
        final state = states[index];
        final isSelected = state == selected;
        return SproutButtonPress(
          onTap: () => onSelected(state),
          child: _StateTile(
            state: state,
            selected: isSelected,
          ),
        );
      },
    );
  }
}

class _StateTile extends StatelessWidget {
  const _StateTile({
    required this.state,
    required this.selected,
  });

  final SproutMascotState state;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Container(
      key: ValueKey('mascot-state-${state.name}'),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: selected ? colors.mint : colors.surface,
        borderRadius: BorderRadius.circular(SproutRadius.tile),
        border: Border.all(
          color: selected ? SproutColors.seed : colors.line,
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _BoundedMascotFrame(
            size: 62,
            state: state,
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              state.name,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StressRows extends StatelessWidget {
  const _StressRows();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _StressRow(
          label: 'Tiny status',
          size: 34,
          states: [
            SproutMascotState.happy,
            SproutMascotState.worried,
            SproutMascotState.thumbsUp,
          ],
        ),
        SizedBox(height: 10),
        _StressRow(
          label: 'Card hero',
          size: 108,
          states: [
            SproutMascotState.idea,
            SproutMascotState.confident,
            SproutMascotState.happyHearts,
          ],
        ),
        SizedBox(height: 10),
        _StressRow(
          label: 'Sheet/modal',
          size: 82,
          states: [
            SproutMascotState.thinking,
            SproutMascotState.grateful,
            SproutMascotState.celebrate,
          ],
        ),
      ],
    );
  }
}

class _StressRow extends StatelessWidget {
  const _StressRow({
    required this.label,
    required this.size,
    required this.states,
  });

  final String label;
  final double size;
  final List<SproutMascotState> states;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(SproutRadius.tile),
        border: Border.all(color: colors.line),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final state in states)
                  _BoundedMascotFrame(
                    size: size,
                    state: state,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BoundedMascotFrame extends StatelessWidget {
  const _BoundedMascotFrame({
    required this.size,
    required this.state,
    this.animate = false,
    this.playKey,
  });

  final double size;
  final SproutMascotState state;
  final bool animate;
  final Object? playKey;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: SproutMascot(
            state: state,
            size: size,
            animate: animate,
            playKey: playKey,
            enableBlink: false,
          ),
        ),
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(SproutRadius.hero),
        border: Border.all(color: colors.line),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

String _copyForState(SproutMascotState state) {
  return switch (state) {
    SproutMascotState.worried => 'Small warning. Calm next step.',
    SproutMascotState.thinking => 'Checking the garden...',
    SproutMascotState.idea ||
    SproutMascotState.pointing =>
      'Try this tiny move.',
    SproutMascotState.confident => 'Your money garden looks steady.',
    SproutMascotState.thumbsUp => 'Done. Nice and simple.',
    SproutMascotState.happyHearts => 'That was a lovely win.',
    SproutMascotState.grateful => 'Future you says thanks.',
    _ => 'Tiny move. Big future.',
  };
}
