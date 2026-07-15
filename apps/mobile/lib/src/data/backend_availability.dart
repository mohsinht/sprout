import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/sprout_environment.dart';
import 'api/sprout_api_client.dart';

enum BackendAvailability { checking, ready, warming, unavailable }

abstract interface class BackendReadinessProbe {
  Future<bool> isReady();
}

class ApiBackendReadinessProbe implements BackendReadinessProbe {
  ApiBackendReadinessProbe(this.client);
  final SproutApiClient client;

  @override
  Future<bool> isReady() => client.isBackendReady();
}

final backendReadinessProbeProvider = Provider<BackendReadinessProbe>(
  (ref) => ApiBackendReadinessProbe(ref.read(apiClientProvider)),
);

final backendAvailabilityProvider =
    StateNotifierProvider<BackendAvailabilityController, BackendAvailability>(
  (ref) => BackendAvailabilityController(
    ref.read(backendReadinessProbeProvider),
    disabled: useSproutMocks || (useSproutSweepHarness && sproutSweepOffline),
  ),
);

class BackendAvailabilityController extends StateNotifier<BackendAvailability> {
  BackendAvailabilityController(
    this._probe, {
    this.warmingWindow = const Duration(seconds: 60),
    this.retryDelay = const Duration(seconds: 4),
    bool disabled = false,
  })  : _disabled = disabled,
        super(disabled
            ? BackendAvailability.ready
            : BackendAvailability.checking) {
    if (!disabled) checkNow();
  }

  final BackendReadinessProbe _probe;
  final Duration warmingWindow;
  final Duration retryDelay;
  final bool _disabled;
  final Stopwatch _elapsed = Stopwatch();
  Timer? _timer;
  bool _checking = false;

  Future<void> checkNow() async {
    if (_disabled || _checking) return;
    _checking = true;
    _elapsed.start();
    final ready = await _probe.isReady();
    _checking = false;
    if (!mounted) return;
    if (ready) {
      _timer?.cancel();
      state = BackendAvailability.ready;
      return;
    }
    state = _elapsed.elapsed < warmingWindow
        ? BackendAvailability.warming
        : BackendAvailability.unavailable;
    _timer?.cancel();
    _timer = Timer(retryDelay, checkNow);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
