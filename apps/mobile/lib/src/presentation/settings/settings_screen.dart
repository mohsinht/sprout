import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../app/theme_mode_controller.dart';
import '../../data/mock_sprout_data.dart';
import '../../theme/sprout_strings.dart';
import '../../theme/sprout_tokens.dart';
import '../../theme/sprout_theme.dart';
import '../../widgets/sprout_page.dart';
import '../../widgets/sprout_panel.dart';
import '../../widgets/trust_badge.dart';
import '../today/today_widgets.dart';
import 'settings_widgets.dart';

/// User-facing copy for Settings. Kept local so the Strings owner can edit
/// `sprout_strings.dart` without merge conflicts.
class _SettingsStrings {
  const _SettingsStrings._();

  static const title = 'Settings';
  static const subtitle = 'Trust, privacy, and control.';
  static const youAreInControl = 'You’re in control.';

  // Profile
  static const profile = 'Profile';
  static const monthlyIncome = 'Monthly income';
  static const salaryDate = 'Salary date';
  static const freelanceIncome = 'Freelance income';
  static const freelanceHint = 'Show a separate freelance income line.';
  static const viewProfile = 'View profile';

  // Data sources
  static const dataSources = 'Data sources';
  static const notConnected = 'Not connected';
  static const on = 'On';
  static const connect = 'Connect';
  static const soon = 'Soon';
  static const disconnect = 'Disconnect';
  static const disconnectConfirmTitle = 'Disconnect this source?';
  static String disconnectConfirmBody(String label) =>
      'Sprout will stop importing from $label. Manual entries stay.';
  static const disconnectCancel = 'Keep connected';
  static const disconnectConfirm = 'Disconnect';
  static String disconnectedSnack(String label) =>
      '$label disconnected. You can reconnect anytime.';
  static const cannotDisconnectManual = 'Manual entries are always on.';
  static const emptySourcesTitle = 'Connect only what you trust.';
  static const emptySourcesSubtitle =
      'Sprout works fully with manual entries. Add a source only if you want to.';
  static const manageSources = 'Manage sources';
  static const sourceDetailDisconnect = 'Disconnect this source';
  static const sourceDetailDelete = 'Delete imported data';
  static const sourceDetailAlwaysOn = 'Manual entries are always on and cannot be disconnected.';
  static const sourceDetailSoon = 'This source is coming soon. You will be able to enable it here.';

  // Privacy
  static const privacy = 'Privacy';
  static const privacyIntro =
      'Sprout is built to be calm and on your side. Here is how we handle your data.';

  // Notifications
  static const notifications = 'Notifications';
  static const dailyReminder = 'Daily check-in reminder';
  static const billReminder = 'Bill reminder';
  static const weeklySummary = 'Weekly summary';

  // Currency
  static const currency = 'Display currency';
  static const currencySubtitle =
      'Show your wealth and amounts in this currency.';
  static const pkr = 'PKR';
  static const pkrLabel = 'Pakistani Rupee';
  static const usd = 'USD';
  static const usdLabel = 'US Dollar';
  static const eur = 'EUR';
  static const eurLabel = 'Euro';

  // App preferences
  static const appPreferences = 'App preferences';
  static const reducedMotion = 'Reduced motion';
  static const soundEffects = 'Sound effects';
  static const haptics = 'Haptics';
  static const darkMode = 'Dark mode';

  // Delete data
  static const deleteData = 'Delete data';
  static const deleteIntro = 'Removes imported data. Manual entries stay.';
  static const deleteMyData = 'Delete my data';
  static const deleteDialogTitle = 'Delete your data?';
  static const deleteDialogBody =
      'Imported data is removed. Your manual entries stay safe.';
  static const deleteCancel = 'Cancel';
  static const deleteConfirm = 'Delete data';
  static const deleteDoneSnack =
      'Imported data removed. Your manual entries are safe.';
}

/// Settings — a calm trust center for privacy, data sources, and control.
///
/// Dark mode is wired to [themeModeProvider]. All other toggles hold local
/// state so the screen responds immediately without a backend.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _dataSourcesKey = GlobalKey();

  late bool _freelanceIncome = mockProfile.hasFreelanceIncome;
  late List<SproutDataSource> _sources = List.of(mockDataSources);

  late final Map<String, bool> _notifications = {
    _SettingsStrings.dailyReminder: true,
    _SettingsStrings.billReminder: true,
    _SettingsStrings.weeklySummary: true,
  };

  String _currency = _SettingsStrings.pkr;

  late final Map<String, bool> _prefs = {
    _SettingsStrings.reducedMotion: false,
    _SettingsStrings.soundEffects: true,
    _SettingsStrings.haptics: true,
    // Dark mode is driven by themeModeProvider; this entry is a placeholder
    // so the toggle renders in-order. The value is resolved in build.
    _SettingsStrings.darkMode: false,
  };

  bool get _hasExternalConnection =>
      _sources.any((s) => s.id != 'manual' && s.connected);

  Future<void> _openProfileSheet() async {
    await SproutBottomSheet.show(
      context,
      title: mockProfile.name,
      rows: [
        SheetInfoRow(
          icon: Icons.person_rounded,
          label: _SettingsStrings.profile,
          value: mockProfile.name,
        ),
        SheetInfoRow(
          icon: Icons.savings_rounded,
          label: _SettingsStrings.monthlyIncome,
          value: SproutFormat.currency(mockProfile.monthlyIncome),
        ),
        SheetInfoRow(
          icon: Icons.event_rounded,
          label: _SettingsStrings.salaryDate,
          value: mockProfile.salaryDate,
        ),
        SheetInfoRow(
          icon: Icons.work_outline_rounded,
          label: _SettingsStrings.freelanceIncome,
          value: _freelanceIncome ? 'On' : 'Off',
        ),
      ],
    );
  }

  Future<void> _confirmDisconnect(SproutDataSource source) async {
    if (source.id == 'manual') {
      _showSnack(_SettingsStrings.cannotDisconnectManual);
      return;
    }
    final shouldDisconnect = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(_SettingsStrings.disconnectConfirmTitle),
            content: Text(_SettingsStrings.disconnectConfirmBody(source.label)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(_SettingsStrings.disconnectCancel),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: SproutColors.tomato,
                  side: BorderSide(
                    color: SproutColors.tomato.withValues(alpha: 0.4),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(_SettingsStrings.disconnectConfirm),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted || !shouldDisconnect) return;

    setState(() {
      _sources = _sources
          .map((s) => s.id == source.id
              ? SproutDataSource(
                  id: s.id,
                  label: s.label,
                  detail: _SettingsStrings.notConnected,
                  connected: false,
                  comingSoon: s.comingSoon,
                )
              : s)
          .toList();
    });
    _showSnack(_SettingsStrings.disconnectedSnack(source.label));
  }

  Future<void> _openSourceSheet(SproutDataSource source) async {
    final isManual = source.id == 'manual';
    await SproutBottomSheet.show(
      context,
      title: source.label,
      rows: [
        SheetInfoRow(
          icon: Icons.info_outline_rounded,
          label: 'Status',
          value: source.detail,
        ),
        if (isManual)
          SheetInfoRow(
            icon: Icons.lock_rounded,
            label: 'Always on',
            value: _SettingsStrings.sourceDetailAlwaysOn,
          )
        else if (source.comingSoon)
          SheetInfoRow(
            icon: Icons.hourglass_top_rounded,
            label: 'Coming soon',
            value: _SettingsStrings.sourceDetailSoon,
          )
        else if (source.connected)
          SheetInfoRow(
            icon: Icons.link_off_rounded,
            label: _SettingsStrings.sourceDetailDisconnect,
            value: 'Tap below to disconnect. Manual entries stay.',
          )
        else
          SheetInfoRow(
            icon: Icons.link_rounded,
            label: 'Connect',
            value: 'Tap below to connect this source.',
          ),
      ],
    );
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(_SettingsStrings.deleteDialogTitle),
            content: const Text(_SettingsStrings.deleteDialogBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(_SettingsStrings.deleteCancel),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: SproutColors.tomato,
                  side: BorderSide(
                    color: SproutColors.tomato.withValues(alpha: 0.4),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(_SettingsStrings.deleteConfirm),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted || !shouldDelete) return;
    _showSnack(_SettingsStrings.deleteDoneSnack);
  }

  void _scrollToSources() {
    final ctx = _dataSourcesKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        alignment: 0.0,
      );
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return SproutPage(
      title: _SettingsStrings.title,
      subtitle: _SettingsStrings.subtitle,
      children: [
        if (!_hasExternalConnection)
          _EmptySourcesCard(onManage: _scrollToSources),
        _profileSection(colors),
        _dataSourcesSection(colors),
        _privacySection(colors),
        _notificationsSection(colors),
        _currencySection(colors),
        _preferencesSection(colors, isDark: isDark),
        _deleteSection(colors),
      ],
    );
  }

  Widget _profileSection(SproutColorScheme colors) {
    return SettingsSection(
      header: _SettingsStrings.profile,
      child: SproutButtonPress(
        onTap: _openProfileSheet,
        semanticLabel: _SettingsStrings.viewProfile,
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: colors.mint,
              child: const Icon(Icons.person_rounded,
                  color: SproutColors.leaf, size: 22),
            ),
            const SizedBox(width: SproutSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mockProfile.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: colors.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${SproutFormat.currency(mockProfile.monthlyIncome)} / month',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colors.muted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: colors.muted, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _dataSourcesSection(SproutColorScheme colors) {
    return SettingsSection(
      key: _dataSourcesKey,
      header: _SettingsStrings.dataSources,
      child: Column(
        children: [
          for (final source in _sources) ...[
            _DataSourceRow(
              source: source,
              onTap: () => _openSourceSheet(source),
            ),
            if (source.id != _sources.last.id) ...[
              const SizedBox(height: SproutSpacing.sm),
              const Divider(height: 1),
              const SizedBox(height: SproutSpacing.sm),
            ],
          ],
        ],
      ),
    );
  }

  Widget _privacySection(SproutColorScheme colors) {
    const icons = <IconData>[
      Icons.lock_rounded,
      Icons.link_rounded,
      Icons.delete_outline_rounded,
      Icons.verified_user_rounded,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(label: _SettingsStrings.privacy),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.mint.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(SproutRadius.card),
            border: Border.all(
              color: SproutColors.seed.withValues(alpha: 0.16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(SproutSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _SettingsStrings.youAreInControl,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: SproutColors.leaf,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: SproutSpacing.sm),
                Text(
                  _SettingsStrings.privacyIntro,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colors.muted),
                ),
                const SizedBox(height: SproutSpacing.md),
                for (var i = 0; i < mockPrivacyStatements.length; i++) ...[
                  TrustBadge(
                    label: mockPrivacyStatements[i],
                    icon: icons[i % icons.length],
                  ),
                  if (i != mockPrivacyStatements.length - 1)
                    const SizedBox(height: SproutSpacing.md),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _notificationsSection(SproutColorScheme colors) {
    final labels = [
      _SettingsStrings.dailyReminder,
      _SettingsStrings.billReminder,
      _SettingsStrings.weeklySummary,
    ];
    return SettingsSection(
      header: _SettingsStrings.notifications,
      child: Column(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            PreferenceToggle(
              label: labels[i],
              value: _notifications[labels[i]] ?? false,
              icon: i == 0
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              onChanged: (v) =>
                  setState(() => _notifications[labels[i]] = v),
            ),
            if (i != labels.length - 1) ...[
              const SizedBox(height: SproutSpacing.sm),
              const Divider(height: 1),
              const SizedBox(height: SproutSpacing.sm),
            ],
          ],
        ],
      ),
    );
  }

  Widget _currencySection(SproutColorScheme colors) {
    return SettingsSection(
      header: _SettingsStrings.currency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _SettingsStrings.currencySubtitle,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: colors.muted),
          ),
          const SizedBox(height: SproutSpacing.md),
          Row(
            children: [
              CurrencyChip(
                code: _SettingsStrings.pkr,
                label: _SettingsStrings.pkrLabel,
                selected: _currency == _SettingsStrings.pkr,
                onTap: () => setState(() => _currency = _SettingsStrings.pkr),
              ),
              const SizedBox(width: SproutSpacing.sm),
              CurrencyChip(
                code: _SettingsStrings.usd,
                label: _SettingsStrings.usdLabel,
                selected: _currency == _SettingsStrings.usd,
                enabled: false,
                onTap: () => setState(() => _currency = _SettingsStrings.usd),
              ),
              const SizedBox(width: SproutSpacing.sm),
              CurrencyChip(
                code: _SettingsStrings.eur,
                label: _SettingsStrings.eurLabel,
                selected: _currency == _SettingsStrings.eur,
                enabled: false,
                onTap: () => setState(() => _currency = _SettingsStrings.eur),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _preferencesSection(SproutColorScheme colors,
      {required bool isDark}) {
    return SettingsSection(
      header: _SettingsStrings.appPreferences,
      child: Column(
        children: [
          PreferenceToggle(
            label: _SettingsStrings.reducedMotion,
            value: _prefs[_SettingsStrings.reducedMotion] ?? false,
            icon: Icons.animation_rounded,
            onChanged: (v) =>
                setState(() => _prefs[_SettingsStrings.reducedMotion] = v),
          ),
          const SizedBox(height: SproutSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: SproutSpacing.sm),
          const PreferenceToggle(
            label: _SettingsStrings.soundEffects,
            value: false,
            icon: Icons.volume_up_rounded,
            comingSoon: true,
          ),
          const SizedBox(height: SproutSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: SproutSpacing.sm),
          const PreferenceToggle(
            label: _SettingsStrings.haptics,
            value: false,
            icon: Icons.vibration_rounded,
            comingSoon: true,
          ),
          const SizedBox(height: SproutSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: SproutSpacing.sm),
          PreferenceToggle(
            label: _SettingsStrings.darkMode,
            value: isDark,
            icon: Icons.dark_mode_rounded,
            onChanged: (v) => ref
                .read(themeModeProvider.notifier)
                .state = v ? ThemeMode.dark : ThemeMode.light,
          ),
        ],
      ),
    );
  }

  Widget _deleteSection(SproutColorScheme colors) {
    return SettingsSection(
      header: _SettingsStrings.deleteData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.delete_outline_rounded,
                  color: SproutColors.tomato, size: 20),
              const SizedBox(width: SproutSpacing.sm),
              Expanded(
                child: Text(
                  _SettingsStrings.deleteIntro,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.ink,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SproutSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: SproutColors.tomato,
                side: BorderSide(
                  color: SproutColors.tomato.withValues(alpha: 0.4),
                ),
              ),
              onPressed: _confirmDelete,
              child: const Text(_SettingsStrings.deleteMyData),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataSourceRow extends StatelessWidget {
  const _DataSourceRow({required this.source, required this.onTap});

  final SproutDataSource source;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final isManual = source.id == 'manual';
    final isActive = source.connected || isManual;

    return SproutButtonPress(
      onTap: source.comingSoon ? null : onTap,
      semanticLabel: source.label,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.ink,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  source.detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.muted,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SproutSpacing.md),
          _SourceControl(
            isActive: isActive,
            comingSoon: source.comingSoon,
          ),
          if (!source.comingSoon) ...[
            const SizedBox(width: SproutSpacing.sm),
            Icon(Icons.chevron_right_rounded,
                color: colors.muted, size: 24),
          ],
        ],
      ),
    );
  }
}

/// Consistent right-side control for a data source row.
///
/// - Active sources (connected or always-on manual): green "On" pill.
/// - Available but not connected: "Connect" label.
/// - Coming soon: calm "Soon" pill.
class _SourceControl extends StatelessWidget {
  const _SourceControl({
    required this.isActive,
    required this.comingSoon,
  });

  final bool isActive;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);

    if (comingSoon) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: SproutColors.gold.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(SproutRadius.pill),
        ),
        child: Text(
          _SettingsStrings.soon,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: SproutColors.goldInk,
                fontWeight: FontWeight.w800,
              ),
        ),
      );
    }

    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: colors.mint,
          borderRadius: BorderRadius.circular(SproutRadius.pill),
          border: Border.all(
            color: SproutColors.seed.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: SproutColors.leaf, size: 13),
            const SizedBox(width: 5),
            Text(
              _SettingsStrings.on,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: SproutColors.leaf,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      );
    }

    return Text(
      _SettingsStrings.connect,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: SproutColors.leaf,
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _EmptySourcesCard extends StatelessWidget {
  const _EmptySourcesCard({required this.onManage});

  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    return SproutRaisedPanel(
      child: Row(
        children: [
          const Icon(Icons.shield_rounded, color: SproutColors.leaf, size: 22),
          const SizedBox(width: SproutSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _SettingsStrings.emptySourcesTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  _SettingsStrings.emptySourcesSubtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: colors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: SproutSpacing.sm),
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
            onPressed: onManage,
            child: const Text(_SettingsStrings.manageSources),
          ),
        ],
      ),
    );
  }
}