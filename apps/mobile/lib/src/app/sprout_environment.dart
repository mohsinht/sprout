/// Single build-time environment gate. Mock repositories are available only
/// when explicitly requested for a development build.
const sproutEnvironment = String.fromEnvironment(
  'SPROUT_ENV',
  defaultValue: 'production',
);

const useSproutMocks = sproutEnvironment == 'dev';

/// Internal real-stack sweep mode. It never enables mock repositories.
const useSproutSweepHarness = sproutEnvironment == 'sweep';
const sproutSweepTheme = String.fromEnvironment(
  'SPROUT_SWEEP_THEME',
  defaultValue: 'light',
);
const _sproutSweepTextScale = String.fromEnvironment(
  'SPROUT_SWEEP_TEXT_SCALE',
  defaultValue: '1.0',
);
final sproutSweepTextScale = double.tryParse(_sproutSweepTextScale) ?? 1.0;
const _sproutSweepOfflineBuild = bool.fromEnvironment(
  'SPROUT_SWEEP_OFFLINE',
  defaultValue: false,
);

/// URL controls make the web sweep switchable without rebuilding. They are
/// ignored outside the internal sweep build.
bool get sproutSweepOffline =>
    useSproutSweepHarness &&
    (_sproutSweepOfflineBuild ||
        Uri.base.queryParameters['sweepOffline'] == 'true');

/// Allows the deterministic no-cache fixture to establish only its local test
/// session before every financial endpoint is blocked by the injector.
bool get sproutSweepOfflineAllowsLogin =>
    useSproutSweepHarness &&
    Uri.base.queryParameters['sweepOfflineAllowLogin'] == 'true';
