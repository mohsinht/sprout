import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../data/mock_learn_repository.dart';
import '../../domain/learn_models.dart';
import '../../theme/sprout_strings.dart';
import '../../widgets/sprout_states.dart';
import 'learn_controller.dart';
import 'learn_widgets.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learn = ref.watch(learnControllerProvider);

    return learn.when(
      data: (data) => _LearnContentHost(data: data),
      loading: () => const SproutLoadingView(label: SproutStrings.loadingLearn),
      error: (error, stackTrace) => SproutErrorView(
        message: SproutStrings.couldNotLoadLearn,
        onRetry: () => ref.invalidate(learnControllerProvider),
      ),
    );
  }
}

class _LearnContentHost extends ConsumerStatefulWidget {
  const _LearnContentHost({required this.data});

  final LearnData data;

  @override
  ConsumerState<_LearnContentHost> createState() => _LearnContentHostState();
}

class _LearnContentHostState extends ConsumerState<_LearnContentHost> {
  late LearnData _data = widget.data;
  LessonNode? _activeNode;
  LessonCompletionResult? _result;
  var _showReward = false;

  @override
  void didUpdateWidget(covariant _LearnContentHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data && _activeNode == null) {
      _data = widget.data;
    }
  }

  Future<void> _answerLesson(int selectedIndex) async {
    final node = _activeNode;
    if (node == null) return;
    final result = await ref.read(learnRepositoryProvider).completeLesson(
          lessonId: node.id,
          selectedIndex: selectedIndex,
        );
    if (!mounted) return;

    if (result.correct && result.awardedXp > 0) {
      HapticFeedback.lightImpact();
      SystemSound.play(SystemSoundType.click);
    }

    setState(() {
      _data = result.data;
      _result = result;
      _showReward = result.correct && result.awardedXp > 0;
    });

    if (_showReward && !MediaQuery.of(context).disableAnimations) {
      Future<void>.delayed(SproutDurations.mascotReaction, () {
        if (!mounted) return;
        setState(() => _showReward = false);
      });
    }
  }

  void _closePlayer() {
    setState(() {
      _activeNode = null;
      _result = null;
      _showReward = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final node = _activeNode;
    final lesson = node == null ? null : _data.path.lessonFor(node.id);

    return Stack(
      children: [
        if (node != null && lesson != null)
          LearnLessonPlayer(
            node: node,
            lesson: lesson,
            result: _result,
            onAnswer: _answerLesson,
            onClose: _closePlayer,
          )
        else
          LearnContent(
            data: _data,
            onStartLesson: (selectedNode) {
              setState(() => _activeNode = selectedNode);
            },
          ),
        if (_showReward && !MediaQuery.of(context).disableAnimations)
          Positioned.fill(
            child: LearnRewardOverlay(text: '+${_result?.awardedXp ?? 0} XP'),
          ),
      ],
    );
  }
}
