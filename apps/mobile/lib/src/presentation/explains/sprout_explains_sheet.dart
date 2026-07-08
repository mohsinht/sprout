import 'package:flutter/material.dart';

import '../../theme/sprout_tokens.dart';
import '../../theme/sprout_theme.dart';
import '../../widgets/sprout_mascot.dart';
import '../../widgets/sprout_mascot_state.dart';

/// Sprout Explains — a modal sheet that explains any score, tile, finding,
/// transaction confidence, market move, or goal pace in plain language.
///
/// Per spec (navigation_ia.md):
/// - Opens from Today or Money.
/// - Keeps context of the originating element.
/// - Offers a next action only when useful.
/// - Returns to the prior screen without losing scroll/context.
///
/// This is a placeholder implementation: it renders the title, a calm
/// explanation body, and an optional next-action button. Real content will
/// be wired from the originating tile/finding.
class SproutExplainsSheet extends StatelessWidget {
  const SproutExplainsSheet({
    required this.title,
    required this.explanation,
    this.nextActionLabel,
    this.onNextAction,
    super.key,
  });

  final String title;
  final String explanation;
  final String? nextActionLabel;
  final VoidCallback? onNextAction;

  /// Opens the sheet above the current screen, preserving prior context.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String explanation,
    String? nextActionLabel,
    VoidCallback? onNextAction,
  }) {
    final colors = SproutColorScheme.of(context);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      showDragHandle: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SproutExplainsSheet(
        title: title,
        explanation: explanation,
        nextActionLabel: nextActionLabel,
        onNextAction: onNextAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = SproutColorScheme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mascot keeps the explanation warm and on-brand.
            const Center(
              child: SproutMascot(
                state: SproutMascotState.thinking,
                size: 80,
                enableBlink: false,
              ),
            ),
            const SizedBox(height: SproutSpacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: SproutSpacing.md),
            Text(
              explanation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.ink,
                    height: 1.5,
                  ),
            ),
            if (nextActionLabel != null && onNextAction != null) ...[
              const SizedBox(height: SproutSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onNextAction!();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: SproutColors.seed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(SproutRadius.pill),
                    ),
                  ),
                  child: Text(nextActionLabel!),
                ),
              ),
            ],
            const SizedBox(height: SproutSpacing.lg),
            // Return path: close returns to prior screen with context intact.
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: TextStyle(color: colors.muted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}