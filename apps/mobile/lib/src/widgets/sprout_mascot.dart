import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' hide Image;
import 'package:sprout_motion/sprout_motion.dart';
import 'package:video_player/video_player.dart';

import 'coin_sprout_mascot.dart';
import 'sprout_mascot_state.dart';

/// Path to the single production Rive file for the Sprout coin mascot.
///
/// All screens render the mascot through [SproutMascot], which loads this file
/// once. When the file is missing or fails to load, the widget falls back to
/// the [CoinSproutMascot] `CustomPaint` illustration so the mascot is always
/// visible — never a blank box.
const _kRiveAssetPath = 'assets/mascot/sprout_coin.riv';
const _kHappyRasterAssetPath = 'assets/mascot/stills/sprout-happy.png';
const _kWaveRasterAssetPath = 'assets/mascot/stills/sprout-wave.png';
const _kConcernedRasterAssetPath = 'assets/mascot/stills/sprout-concerned.png';
const _kThinkingRasterAssetPath = 'assets/mascot/stills/sprout-thinking.png';
const _kIdeaRasterAssetPath = 'assets/mascot/stills/sprout-idea.png';
const _kConfidentRasterAssetPath = 'assets/mascot/stills/sprout-confident.png';
const _kThumbsUpRasterAssetPath = 'assets/mascot/stills/sprout-thumbs-up.png';
const _kHappyHeartsRasterAssetPath =
    'assets/mascot/stills/sprout-happy-hearts.png';
const _kGratefulRasterAssetPath = 'assets/mascot/stills/sprout-grateful.png';
const _kHappyVideoAssetPath = 'assets/mascot/videos/sprout-happy.mp4';
const _kWaveVideoAssetPath = 'assets/mascot/videos/sprout-wave.mp4';
const _kConcernedVideoAssetPath = 'assets/mascot/videos/sprout-concerned.mp4';
const _kThinkingVideoAssetPath = 'assets/mascot/videos/sprout-thinking.mp4';
const _kIdeaVideoAssetPath = 'assets/mascot/videos/sprout-idea.mp4';
const _kConfidentVideoAssetPath = 'assets/mascot/videos/sprout-confident.mp4';
const _kThumbsUpVideoAssetPath = 'assets/mascot/videos/sprout-thumbs-up.mp4';
const _kHappyHeartsVideoAssetPath =
    'assets/mascot/videos/sprout-happy-hearts.mp4';
const _kGratefulVideoAssetPath = 'assets/mascot/videos/sprout-grateful.mp4';

/// The Rive state machine name documented in
/// `apps/mobile/assets/mascot/sprout_coin_motion_guidelines.md`.
const _kRiveStateMachine = 'sprout_mascot';

/// Input names inside the `sprout_mascot` state machine.
const _kInputState = 'state';
const _kInputBlink = 'blink';
const _kInputCelebrate = 'celebrate';
const _kInputWave = 'wave';

/// The production Sprout coin mascot widget.
///
/// Renders the Rive-backed mascot from `assets/mascot/sprout_coin.riv` and
/// drives the `sprout_mascot` state machine from [state]. If the Rive asset is
/// unavailable or fails to load, it renders the [CoinSproutMascot]
/// `CustomPaint` fallback with the matching mood.
///
/// All screens should use this widget instead of [CoinSproutMascot] directly:
///
/// ```dart
/// SproutMascot(state: SproutMascotState.happy, size: 72)
/// ```
///
/// See:
/// - `sprout_coin_character_bible.md` for the design rules.
/// - `sprout_coin_motion_guidelines.md` for the state machine contract.
/// - `SproutMascotState` for the state enum and product-signal helpers.
class SproutMascot extends StatefulWidget {
  const SproutMascot({
    required this.state,
    this.size = 72,
    this.enableBlink = true,
    this.animate = false,
    this.playOnMount = false,
    this.playKey,
    this.loop = false,
    this.onAnimationEnd,
    super.key,
  });

  /// The mascot state to drive. Maps to the Rive `state` number input and to
  /// the fallback [CoinSproutMood].
  final SproutMascotState state;

  /// Rendered edge length in dp.
  final double size;

  /// Whether the idle blink timer should fire. Disable on busy rows where the
  /// blink would be distracting.
  final bool enableBlink;

  /// Play the matching video once instead of rendering the still immediately.
  final bool animate;

  /// Play the matching video once when this widget first mounts.
  final bool playOnMount;

  /// Change this value to replay the matching video once.
  final Object? playKey;

  /// Whether video-backed mascot states should loop. Defaults to false because
  /// Sprout should mostly stay still and animate only for meaningful moments.
  final bool loop;

  /// Called after a one-shot video finishes.
  final VoidCallback? onAnimationEnd;

  @override
  State<SproutMascot> createState() => _SproutMascotState();
}

class _SproutMascotState extends State<SproutMascot> {
  /// `null` until we know the asset is missing/broken, in which case we render
  /// the `CustomPaint` fallback for the rest of this widget's life.
  bool? _riveAvailable;
  Set<String> _availableAssets = const {};
  late bool _playVideo;

  // Rive wiring.
  StateMachineController? _controller;
  SMINumber? _stateInput;
  SMITrigger? _blinkInput;
  SMITrigger? _celebrateInput;
  SMITrigger? _waveInput;

  Timer? _blinkTimer;

  /// Whether the platform requested reduced motion. Populated in
  /// [didChangeDependencies] (MediaQuery is not available in [initState]) and
  /// used to gate the blink timer and Rive idle animation.
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    _playVideo = widget.playOnMount || widget.animate;
    _checkRiveAsset();
    // Blink timer is started in didChangeDependencies once we know whether
    // reduced motion is requested.
  }

  @override
  void didUpdateWidget(covariant SproutMascot old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) {
      _stateInput?.value = widget.state.riveInput.toDouble();
    }
    if ((old.playKey != widget.playKey && widget.animate) ||
        (!old.animate && widget.animate)) {
      _restartVideo();
    }
    if (old.enableBlink != widget.enableBlink) {
      if (widget.enableBlink && !_reducedMotion) {
        _startBlinkTimer();
      } else {
        _blinkTimer?.cancel();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    if (_reducedMotion != reducedMotion) {
      _reducedMotion = reducedMotion;
      if (widget.enableBlink && !reducedMotion) {
        _startBlinkTimer();
      } else {
        _blinkTimer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _startBlinkTimer() {
    _blinkTimer?.cancel();
    if (!widget.enableBlink || _reducedMotion) return;
    // Slow, gentle blink cadence — see motion guidelines.
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      _blinkInput?.fire();
    });
  }

  void _restartVideo() {
    if (!mounted) return;
    setState(() => _playVideo = true);
  }

  void _finishVideo() {
    if (!mounted) return;
    setState(() => _playVideo = false);
    widget.onAnimationEnd?.call();
  }

  Future<void> _checkRiveAsset() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final availableAssets = manifest.listAssets().toSet();
      if (!availableAssets.contains(_kRiveAssetPath)) {
        if (mounted) {
          setState(() {
            _availableAssets = availableAssets;
            _riveAvailable = false;
          });
        }
        return;
      }
      await rootBundle.load(_kRiveAssetPath);
      if (mounted) {
        setState(() {
          _availableAssets = availableAssets;
          _riveAvailable = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _riveAvailable = false);
    }
  }

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      _kRiveStateMachine,
    );
    if (controller == null) {
      // State machine missing — fall back to static art.
      if (mounted) setState(() => _riveAvailable = false);
      return;
    }
    artboard.addController(controller);
    _controller = controller;
    _stateInput = controller.findSMI<double>(_kInputState) as SMINumber?;
    _blinkInput = controller.findSMI<bool>(_kInputBlink) as SMITrigger?;
    _celebrateInput = controller.findSMI<bool>(_kInputCelebrate) as SMITrigger?;
    _waveInput = controller.findSMI<bool>(_kInputWave) as SMITrigger?;

    // Push the current state immediately.
    _stateInput?.value = widget.state.riveInput.toDouble();
  }

  /// Fire a one-shot celebration burst. No-op if the Rive asset is unavailable.
  void celebrate() => _celebrateInput?.fire();

  /// Fire a one-shot wave. No-op if the Rive asset is unavailable.
  void wave() => _waveInput?.fire();

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    final rasterAssetPath =
        _rasterAssetForState(widget.state, _availableAssets);
    final videoAssetPath = _videoAssetForState(widget.state, _availableAssets);
    final shouldPlayVideo =
        _playVideo && !reducedMotion && videoAssetPath != null;

    if (rasterAssetPath != null || videoAssetPath != null) {
      return _FallbackMascot(
        state: widget.state,
        size: widget.size,
        reducedMotion: reducedMotion,
        loop: widget.loop,
        playVideo: shouldPlayVideo,
        videoAssetPath: videoAssetPath,
        rasterAssetPath: rasterAssetPath,
        onVideoFinished: _finishVideo,
      );
    }

    // Until the optional Rive file is confirmed, render the fallback.
    if (_riveAvailable != true) {
      return _FallbackMascot(
        state: widget.state,
        size: widget.size,
        reducedMotion: reducedMotion,
        loop: widget.loop,
        playVideo: false,
      );
    }

    return ExcludeSemantics(
      child: TickerMode(
        enabled: !reducedMotion,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: RiveAnimation.asset(
            _kRiveAssetPath,
            artboard: 'sprout_coin',
            stateMachines: const [_kRiveStateMachine],
            fit: BoxFit.contain,
            antialiasing: true,
            onInit: _onRiveInit,
            placeHolder: _FallbackMascot(
              state: widget.state,
              size: widget.size,
              reducedMotion: true,
              loop: widget.loop,
              playVideo: false,
              rasterAssetPath: rasterAssetPath,
            ),
            // If the asset fails to load at runtime, Rive will leave the
            // placeholder in place; we additionally mark ourselves unavailable on
            // state-machine init failure so future rebuilds skip the load.
          ),
        ),
      ),
    );
  }
}

/// Renders the `CustomPaint` mascot with the idle bob when motion is allowed.
class _FallbackMascot extends StatelessWidget {
  const _FallbackMascot({
    required this.state,
    required this.size,
    required this.reducedMotion,
    required this.loop,
    required this.playVideo,
    this.videoAssetPath,
    this.rasterAssetPath,
    this.onVideoFinished,
  });

  final SproutMascotState state;
  final double size;
  final bool reducedMotion;
  final bool loop;
  final bool playVideo;
  final String? videoAssetPath;
  final String? rasterAssetPath;
  final VoidCallback? onVideoFinished;

  @override
  Widget build(BuildContext context) {
    final assetPath = rasterAssetPath;
    final videoPath = videoAssetPath;
    final mascot = playVideo && videoPath != null
        ? _VideoMascot(
            key: ValueKey(videoPath),
            assetPath: videoPath,
            fallbackAssetPath: assetPath,
            fallbackMood: state.fallbackMood,
            loop: loop,
            size: size,
            onFinished: onVideoFinished,
          )
        : assetPath == null
            ? CoinSproutMascot(size: size, mood: state.fallbackMood)
            : _RasterMascot(
                assetPath: assetPath,
                size: size,
                fallbackMood: state.fallbackMood,
              );
    if (reducedMotion || videoPath != null) return mascot;
    return mascot.sproutMascotIdle();
  }
}

class _VideoMascot extends StatefulWidget {
  const _VideoMascot({
    required this.assetPath,
    required this.fallbackMood,
    required this.loop,
    required this.size,
    this.fallbackAssetPath,
    this.onFinished,
    super.key,
  });

  final String assetPath;
  final String? fallbackAssetPath;
  final CoinSproutMood fallbackMood;
  final bool loop;
  final double size;
  final VoidCallback? onFinished;

  @override
  State<_VideoMascot> createState() => _VideoMascotState();
}

class _VideoMascotState extends State<_VideoMascot> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _VideoMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath ||
        oldWidget.loop != widget.loop) {
      _controller?.removeListener(_handleVideoTick);
      _controller?.dispose();
      _controller = null;
      _ready = false;
      _failed = false;
      _finished = false;
      _load();
    } else {
      _controller?.setLooping(widget.loop);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPlayback();
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleVideoTick);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final controller = VideoPlayerController.asset(widget.assetPath);
      _controller = controller;
      await controller.setLooping(widget.loop);
      await controller.setVolume(0);
      await controller.initialize();
      if (!mounted || _controller != controller) {
        await controller.dispose();
        return;
      }
      controller.addListener(_handleVideoTick);
      setState(() => _ready = true);
      _syncPlayback();
    } catch (_) {
      if (mounted) {
        setState(() => _failed = true);
        widget.onFinished?.call();
      }
    }
  }

  void _handleVideoTick() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || widget.loop) {
      return;
    }
    final duration = controller.value.duration;
    if (duration == Duration.zero) return;
    final isAtEnd = controller.value.position >= duration;
    if (isAtEnd && !_finished) {
      _finished = true;
      widget.onFinished?.call();
    }
  }

  void _syncPlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final shouldPlay = TickerMode.getValuesNotifier(context).value.enabled;
    if (shouldPlay) {
      unawaited(controller.play());
    } else {
      unawaited(controller.pause());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || !_ready) {
      return _MascotFallbackArt(
        fallbackAssetPath: widget.fallbackAssetPath,
        fallbackMood: widget.fallbackMood,
        size: widget.size,
      );
    }

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: widget.size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.size * 0.18),
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
      ),
    );
  }
}

class _MascotFallbackArt extends StatelessWidget {
  const _MascotFallbackArt({
    required this.fallbackMood,
    required this.size,
    this.fallbackAssetPath,
  });

  final String? fallbackAssetPath;
  final CoinSproutMood fallbackMood;
  final double size;

  @override
  Widget build(BuildContext context) {
    final assetPath = fallbackAssetPath;
    if (assetPath != null) {
      return _RasterMascot(
        assetPath: assetPath,
        size: size,
        fallbackMood: fallbackMood,
      );
    }
    return CoinSproutMascot(size: size, mood: fallbackMood);
  }
}

class _RasterMascot extends StatelessWidget {
  const _RasterMascot({
    required this.assetPath,
    required this.size,
    required this.fallbackMood,
  });

  final String assetPath;
  final double size;
  final CoinSproutMood fallbackMood;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_mascotCornerRadius(size)),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
          semanticLabel: 'Sprout mascot',
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) return child;
            return CoinSproutMascot(size: size, mood: fallbackMood);
          },
          errorBuilder: (context, error, stackTrace) {
            return CoinSproutMascot(size: size, mood: fallbackMood);
          },
        ),
      ),
    );
  }
}

double _mascotCornerRadius(double size) {
  if (size <= 112) return size / 2;
  return size * 0.2;
}

String? _rasterAssetForState(
  SproutMascotState state,
  Set<String> availableAssets,
) {
  final assetPath = switch (state) {
    SproutMascotState.worried => _kConcernedRasterAssetPath,
    SproutMascotState.thinking ||
    SproutMascotState.reading =>
      _kThinkingRasterAssetPath,
    SproutMascotState.pointing ||
    SproutMascotState.idea =>
      _kIdeaRasterAssetPath,
    SproutMascotState.peek => _kWaveRasterAssetPath,
    SproutMascotState.thumbsUp => _kThumbsUpRasterAssetPath,
    SproutMascotState.grateful => _kGratefulRasterAssetPath,
    SproutMascotState.idle || SproutMascotState.happy => _kHappyRasterAssetPath,
    SproutMascotState.excited ||
    SproutMascotState.confident =>
      _kConfidentRasterAssetPath,
    SproutMascotState.celebrate ||
    SproutMascotState.happyHearts =>
      _kHappyHeartsRasterAssetPath,
  };
  return availableAssets.contains(assetPath) ? assetPath : null;
}

String? _videoAssetForState(
  SproutMascotState state,
  Set<String> availableAssets,
) {
  final assetPath = switch (state) {
    SproutMascotState.worried => _kConcernedVideoAssetPath,
    SproutMascotState.thinking ||
    SproutMascotState.reading =>
      _kThinkingVideoAssetPath,
    SproutMascotState.pointing => _kIdeaVideoAssetPath,
    SproutMascotState.idea => _kIdeaVideoAssetPath,
    SproutMascotState.peek => _kWaveVideoAssetPath,
    SproutMascotState.thumbsUp => _kThumbsUpVideoAssetPath,
    SproutMascotState.grateful => _kGratefulVideoAssetPath,
    SproutMascotState.excited => _kConfidentVideoAssetPath,
    SproutMascotState.confident => _kConfidentVideoAssetPath,
    SproutMascotState.celebrate => _kHappyHeartsVideoAssetPath,
    SproutMascotState.happyHearts => _kHappyHeartsVideoAssetPath,
    SproutMascotState.idle => _kWaveVideoAssetPath,
    SproutMascotState.happy => _kHappyVideoAssetPath,
  };
  return availableAssets.contains(assetPath) ? assetPath : null;
}

/// Helper extensions for screens that previously used the legacy
/// [SproutMascotMood] (defined in `today_widgets.dart`). These make migration
/// to [SproutMascotState] mechanical.
@Deprecated(
    'Use SproutMascotState directly. This bridge is for migration only.')
extension DeprecatedSproutMascotMoodBridge on SproutMascotState {
  // Intentionally empty: the [fallbackMood] getter on [SproutMascotState]
  // already provides the legacy [CoinSproutMood]. This extension exists only as
  // a search anchor for screens being migrated off `SproutMascotMood`.
}
