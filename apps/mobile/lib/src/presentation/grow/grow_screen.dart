import 'package:flutter/material.dart';
import 'package:sprout_motion/sprout_motion.dart';

import '../../theme/sprout_tokens.dart';
import '../../widgets/sprout_page.dart';
import '../today/today_widgets.dart';

class GrowScreen extends StatelessWidget {
  const GrowScreen({super.key});

  static const _mix = [
    _MixSlice(
        'Cash', '34%', SproutColors.seed, Icons.account_balance_wallet_rounded),
    _MixSlice('Emergency', '23%', SproutColors.sky, Icons.savings_rounded),
    _MixSlice('Funds', '31%', SproutColors.lilac, Icons.trending_up_rounded),
    _MixSlice('Wise', '12%', SproutColors.gold, Icons.public_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SproutPage(
      title: 'Grow',
      subtitle: 'Simple wealth building, no scary charts.',
      trailing: _RoundAction(
        icon: Icons.notifications_none_rounded,
        onTap: () => SproutBottomSheet.show(
          context,
          title: 'Grow alerts',
          rows: const [
            SheetInfoRow(
                icon: Icons.trending_up_rounded,
                label: 'NAV',
                value: 'Al Meezan NAV updated yesterday.'),
            SheetInfoRow(
                icon: Icons.savings_rounded,
                label: 'Goal',
                value: 'Emergency fund is 58% complete.'),
          ],
        ),
      ),
      children: const [
        _GrowHero(),
        SizedBox(height: SproutSpacing.md),
        _MixBoard(),
        SizedBox(height: SproutSpacing.md),
        _GoalMountain(),
        SizedBox(height: SproutSpacing.md),
        _GrowQuest(),
      ],
    );
  }
}

class _GrowHero extends StatelessWidget {
  const _GrowHero();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF4C8FF3), Color(0xFF2E67DC)]),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: SproutColors.sky.withValues(alpha: .25),
              blurRadius: 26,
              offset: const Offset(0, 16))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Portfolio Value',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white)),
                    const SizedBox(height: 3),
                    Text('PKR 587K',
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(color: Colors.white, fontSize: 38)),
                    const SizedBox(height: 2),
                    Text('+PKR 3.2K today',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: .86))),
                  ]),
            ),
            const SproutMascot(size: 78, mood: SproutMascotMood.thumbsUp),
          ],
        ),
      ),
    );
  }
}

class _MixBoard extends StatelessWidget {
  const _MixBoard();

  @override
  Widget build(BuildContext context) {
    return _RaisedPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Portfolio mix', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          const SourceStatusPill(label: 'Balanced', connected: true),
        ]),
        const SizedBox(height: SproutSpacing.md),
        Row(children: [
          const SizedBox(
              width: 112,
              height: 112,
              child: CustomPaint(painter: _MixPainter())),
          const SizedBox(width: SproutSpacing.lg),
          Expanded(
            child: Wrap(
              spacing: SproutSpacing.sm,
              runSpacing: SproutSpacing.sm,
              children: [
                for (final slice in GrowScreen._mix) _MixChip(slice: slice),
              ],
            ),
          ),
        ]),
      ]),
    );
  }
}

class _MixChip extends StatelessWidget {
  const _MixChip({required this.slice});

  final _MixSlice slice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
          color: slice.color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(slice.icon, color: slice.color, size: 16),
        const SizedBox(width: 5),
        Text('${slice.label} ${slice.percent}',
            style:
                Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12)),
      ]),
    );
  }
}

class _GoalMountain extends StatelessWidget {
  const _GoalMountain();

  @override
  Widget build(BuildContext context) {
    return _RaisedPanel(
      child: Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Future you is happy',
                style: Theme.of(context).textTheme.titleLarge),
            Text('6-month buffer in',
                style: Theme.of(context).textTheme.bodyMedium),
            Text('11 months',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: SproutColors.sky)),
            const SizedBox(height: SproutSpacing.sm),
            const SproutProgressBar(value: .58, color: SproutColors.sky),
          ]),
        ),
        const SizedBox(width: SproutSpacing.md),
        const Icon(Icons.landscape_rounded, size: 86, color: SproutColors.sky),
      ]),
    );
  }
}

class _GrowQuest extends StatelessWidget {
  const _GrowQuest();

  @override
  Widget build(BuildContext context) {
    return _MiniQuestCard(
      color: SproutColors.sky,
      icon: Icons.savings_rounded,
      label: 'GROW QUEST',
      title: 'Add PKR 20K buffer',
      reward: '+25 XP',
      onTap: () => SproutBottomSheet.show(
        context,
        title: 'Grow quest',
        rows: const [
          SheetInfoRow(
              icon: Icons.lightbulb_rounded,
              label: 'Move',
              value:
                  'Add PKR 20K to emergency savings before taking more risk.'),
          SheetInfoRow(
              icon: Icons.verified_user_rounded,
              label: 'Confidence',
              value: 'Medium. Some transactions may still be pending.'),
        ],
      ),
    );
  }
}

class _MixPainter extends CustomPainter {
  const _MixPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    var start = -1.5708;
    final values = [.34, .23, .31, .12];
    final colors = [
      SproutColors.seed,
      SproutColors.sky,
      SproutColors.lilac,
      SproutColors.gold
    ];
    for (var i = 0; i < values.length; i++) {
      canvas.drawArc(
          rect.deflate(8),
          start,
          values[i] * 6.283,
          false,
          Paint()
            ..color = colors[i]
            ..style = PaintingStyle.stroke
            ..strokeWidth = 18
            ..strokeCap = StrokeCap.round);
      start += values[i] * 6.283;
    }
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 22,
        Paint()..color = SproutColors.mint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MixSlice {
  const _MixSlice(this.label, this.percent, this.color, this.icon);

  final String label;
  final String percent;
  final Color color;
  final IconData icon;
}

class _RaisedPanel extends StatelessWidget {
  const _RaisedPanel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
            color: SproutColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: SproutColors.line),
            boxShadow: [
              BoxShadow(
                  color: SproutColors.ink.withValues(alpha: .08),
                  blurRadius: 26,
                  offset: const Offset(0, 14))
            ]),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      );
}

class _MiniQuestCard extends StatelessWidget {
  const _MiniQuestCard(
      {required this.color,
      required this.icon,
      required this.label,
      required this.title,
      required this.reward,
      required this.onTap});
  final Color color;
  final IconData icon;
  final String label;
  final String title;
  final String reward;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SproutButtonPress(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [color, Color.lerp(color, Colors.black, .16)!]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Color.lerp(color, Colors.black, .18)!,
                    blurRadius: 0,
                    offset: const Offset(0, 5))
              ]),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white.withValues(alpha: .2),
                  child: Icon(icon, color: Colors.white)),
              const SizedBox(width: SproutSpacing.md),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white.withValues(alpha: .9),
                            letterSpacing: .4)),
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Colors.white))
                  ])),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .22),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: .35))),
                  child: Text(reward,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: Colors.white))),
            ]),
          ),
        ),
      );
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SproutButtonPress(
      onTap: onTap,
      child: CircleAvatar(
          radius: 22,
          backgroundColor: SproutColors.surface,
          child: Icon(icon, color: SproutColors.leaf)));
}
