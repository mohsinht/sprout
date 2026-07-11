import 'package:shared_preferences/shared_preferences.dart';

/// Local-first onboarding state.
///
/// Completion is durable before any network request is attempted. A later
/// retry can replay the same payload without blocking the user from Today.
class OnboardingStore {
  static const _completeKey = 'onboarding.complete';
  static const _nameKey = 'onboarding.name';
  static const _goalNameKey = 'onboarding.goalName';
  static const _goalTypeKey = 'onboarding.goalType';
  static const _targetKey = 'onboarding.targetAmount';

  Future<void> save({
    required String? name,
    required String? goalName,
    required String? goalType,
    required int? targetAmount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completeKey, true);
    await _setOrRemove(prefs, _nameKey, name);
    await _setOrRemove(prefs, _goalNameKey, goalName);
    await _setOrRemove(prefs, _goalTypeKey, goalType);
    if (targetAmount != null) {
      await prefs.setInt(_targetKey, targetAmount);
    } else {
      await prefs.remove(_targetKey);
    }
  }

  Future<OnboardingDraft> read() async {
    final prefs = await SharedPreferences.getInstance();
    return OnboardingDraft(
      completed: prefs.getBool(_completeKey) ?? false,
      name: prefs.getString(_nameKey),
      goalName: prefs.getString(_goalNameKey),
      goalType: prefs.getString(_goalTypeKey),
      targetAmount: prefs.getInt(_targetKey),
    );
  }

  Future<void> _setOrRemove(
    SharedPreferences prefs,
    String key,
    String? value,
  ) async {
    if (value == null || value.trim().isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value.trim());
    }
  }
}

class OnboardingDraft {
  const OnboardingDraft({
    required this.completed,
    this.name,
    this.goalName,
    this.goalType,
    this.targetAmount,
  });

  final bool completed;
  final String? name;
  final String? goalName;
  final String? goalType;
  final int? targetAmount;
}
