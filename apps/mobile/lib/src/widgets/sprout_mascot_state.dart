import '../widgets/coin_sprout_mascot.dart';

/// Production mascot states for the Sprout coin character.
///
/// This is the single enum every screen should use to drive the mascot. It maps
/// 1:1 to the Rive state machine inputs documented in
/// `apps/mobile/assets/mascot/sprout_coin_motion_guidelines.md` and also maps to
/// the legacy [CoinSproutMood] used by the `CustomPaint` fallback.
///
/// Use [SproutMascot] to render the mascot:
///
/// ```dart
/// SproutMascot(state: SproutMascotState.happy, size: 72)
/// ```
///
/// Prefer the helpers below ([SproutMascotState.fromHealthScore],
/// [SproutMascotState.fromPaydayDays], [SproutMascotState.fromConnectionError])
/// over hard-coding states so the mascot always reflects product truth.
enum SproutMascotState {
  idle,
  happy,
  excited,
  celebrate,
  thinking,
  worried,
  reading,
  pointing,
  peek,
  thumbsUp,
  idea,
  confident,
  happyHearts,
  grateful;

  /// Index sent to the Rive `state` number input. Keep this stable — the Rive
  /// file depends on these ordinals.
  int get riveInput => index;

  /// Maps to the [CoinSproutMood] used by the `CustomPaint` fallback when the
  /// Rive asset is unavailable.
  CoinSproutMood get fallbackMood => switch (this) {
        SproutMascotState.idle => CoinSproutMood.happy,
        SproutMascotState.happy => CoinSproutMood.happy,
        SproutMascotState.excited => CoinSproutMood.celebrating,
        SproutMascotState.celebrate => CoinSproutMood.celebrating,
        SproutMascotState.thinking => CoinSproutMood.thinking,
        SproutMascotState.worried => CoinSproutMood.worried,
        SproutMascotState.reading => CoinSproutMood.reading,
        SproutMascotState.pointing => CoinSproutMood.pointing,
        SproutMascotState.peek => CoinSproutMood.peek,
        SproutMascotState.thumbsUp => CoinSproutMood.thumbsUp,
        SproutMascotState.idea => CoinSproutMood.pointing,
        SproutMascotState.confident => CoinSproutMood.celebrating,
        SproutMascotState.happyHearts => CoinSproutMood.celebrating,
        SproutMascotState.grateful => CoinSproutMood.thumbsUp,
      };

  /// Pick a mascot state from a 0–100 financial health score.
  ///
  /// Mirrors the bands in `packages/domain/src/financial-health-score.ts`:
  /// `strong`/`healthy` (≥75) → happy, `watch` (50–74) → thinking,
  /// `urgent` (<50) → worried.
  factory SproutMascotState.fromHealthScore(int score) {
    if (score >= 80) return SproutMascotState.confident;
    if (score >= 75) return SproutMascotState.happy;
    if (score >= 50) return SproutMascotState.thinking;
    return SproutMascotState.worried;
  }

  /// Pick a mascot state based on days until salary.
  ///
  /// Payday ≤ 3 days → excited, otherwise [idle].
  factory SproutMascotState.fromPaydayDays(int daysUntilSalary) {
    if (daysUntilSalary <= 3) return SproutMascotState.excited;
    return SproutMascotState.idle;
  }

  /// Mascot state for connection / data-source errors. The mascot stays
  /// supportive, never alarming.
  factory SproutMascotState.fromConnectionError(bool hasError) {
    return hasError ? SproutMascotState.worried : SproutMascotState.idle;
  }

  /// Resolve the most relevant mascot state from a product context snapshot.
  ///
  /// Priority: error > quest completed > payday > health score. This keeps the
  /// mascot reactive to the most actionable signal first.
  factory SproutMascotState.fromContext({
    required int healthScore,
    required int daysUntilSalary,
    bool hasConnectionError = false,
    bool questCompleted = false,
  }) {
    if (hasConnectionError) return SproutMascotState.worried;
    if (questCompleted) return SproutMascotState.thumbsUp;
    if (daysUntilSalary <= 3) return SproutMascotState.excited;
    return SproutMascotState.fromHealthScore(healthScore);
  }
}
