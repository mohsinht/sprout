/// English and Urdu-ready display copy for every Learn text field.
class LocalizedText {
  const LocalizedText({required this.en, this.ur});

  final String en;
  final String? ur;

  String resolve() => en;
}

/// User progress displayed by Learn and kept in sync with Today's XP economy.
class LearnUser {
  const LearnUser({
    required this.level,
    required this.xp,
    required this.dayStreak,
  });

  final int level;
  final int xp;
  final int dayStreak;

  LearnUser copyWith({int? xp}) {
    return LearnUser(level: level, xp: xp ?? this.xp, dayStreak: dayStreak);
  }
}

/// A single node in the ordered lesson path.
class LessonNode {
  const LessonNode({
    required this.id,
    required this.title,
    required this.status,
    required this.xp,
  });

  final String id;
  final LocalizedText title;
  final LessonNodeStatus status;
  final int xp;

  LessonNode copyWith({LessonNodeStatus? status}) {
    return LessonNode(
      id: id,
      title: title,
      status: status ?? this.status,
      xp: xp,
    );
  }
}

/// Available progression states for a Learn path node.
enum LessonNodeStatus { locked, available, done }

/// A short lesson card designed for a 30-60 second learning session.
class LessonCard {
  const LessonCard({required this.title, required this.body});

  final LocalizedText title;
  final LocalizedText body;
}

/// One gentle comprehension check at the end of a micro-lesson.
class CheckQuestion {
  const CheckQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final LocalizedText prompt;
  final List<LocalizedText> options;
  final int correctIndex;
  final LocalizedText explanation;
}

/// Full playable lesson content for a Learn path node.
class Lesson {
  const Lesson({
    required this.id,
    required this.cards,
    required this.checkQuestion,
  });

  final String id;
  final List<LessonCard> cards;
  final CheckQuestion checkQuestion;
}

/// Ordered Learn path plus lesson bodies needed by the player.
class LessonPath {
  const LessonPath({
    required this.id,
    required this.title,
    required this.levelLabel,
    required this.nodes,
    required this.lessons,
  });

  final String id;
  final LocalizedText title;
  final String levelLabel;
  final List<LessonNode> nodes;
  final List<Lesson> lessons;

  Lesson? lessonFor(String nodeId) {
    for (final lesson in lessons) {
      if (lesson.id == nodeId) return lesson;
    }
    return null;
  }

  LessonPath copyWith({List<LessonNode>? nodes}) {
    return LessonPath(
      id: id,
      title: title,
      levelLabel: levelLabel,
      nodes: nodes ?? this.nodes,
      lessons: lessons,
    );
  }
}

/// Complete Learn response mirrored 1:1 with `LearnResponseSchema`.
class LearnData {
  const LearnData({required this.user, required this.path});

  final LearnUser user;
  final LessonPath path;

  bool get isComplete {
    return path.nodes.every((node) => node.status == LessonNodeStatus.done);
  }

  int get earnedXp {
    return path.nodes
        .where((node) => node.status == LessonNodeStatus.done)
        .fold(0, (total, node) => total + node.xp);
  }

  LessonNode? get currentNode {
    for (final node in path.nodes) {
      if (node.status == LessonNodeStatus.available) return node;
    }
    return null;
  }

  LearnData copyWith({LearnUser? user, LessonPath? path}) {
    return LearnData(user: user ?? this.user, path: path ?? this.path);
  }
}

/// Result returned after a lesson check is answered.
class LessonCompletionResult {
  const LessonCompletionResult({
    required this.correct,
    required this.awardedXp,
    required this.explanation,
    required this.data,
  });

  final bool correct;
  final int awardedXp;
  final String explanation;
  final LearnData data;
}
