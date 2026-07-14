import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_lock_store.dart';
import '../theme/sprout_theme.dart';
import '../theme/sprout_tokens.dart';

class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      ref.read(appLockProvider.notifier).lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lock = ref.watch(appLockProvider);
    if (!lock.enabled || !lock.locked) return widget.child;
    final colors = SproutColorScheme.of(context);
    return ColoredBox(
      color: colors.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_rounded,
                    color: SproutColors.seed, size: 48),
                const SizedBox(height: 16),
                Text('Sprout is locked',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Unlock to see your private money picture.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: colors.muted),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: lock.busy
                      ? null
                      : () => ref.read(appLockProvider.notifier).unlock(),
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: Text(lock.busy ? 'Unlocking…' : 'Unlock Sprout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
