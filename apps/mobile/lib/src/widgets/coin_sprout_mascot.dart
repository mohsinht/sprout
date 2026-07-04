import 'package:flutter/material.dart';

import '../theme/sprout_tokens.dart';

class CoinSproutMascot extends StatelessWidget {
  const CoinSproutMascot({this.size = 92, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _CoinSproutMascotPainter(),
    );
  }
}

class _CoinSproutMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.57);
    final radius = size.width * 0.34;
    final coinPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFD874), SproutColors.gold],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    final outline = Paint()
      ..color = const Color(0xFFB97818)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035;
    final leafPaint = Paint()..color = SproutColors.seed;
    final stemPaint = Paint()
      ..color = SproutColors.leaf
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, coinPaint);
    canvas.drawCircle(center, radius, outline);
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.31),
      Offset(size.width * 0.5, size.height * 0.16),
      stemPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.39, size.height * 0.17),
        width: size.width * 0.27,
        height: size.height * 0.16,
      ),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.61, size.height * 0.17),
        width: size.width * 0.27,
        height: size.height * 0.16,
      ),
      Paint()..color = SproutColors.leaf,
    );

    final eyePaint = Paint()..color = SproutColors.ink;
    canvas.drawCircle(Offset(size.width * 0.39, size.height * 0.54), 3.6, eyePaint);
    canvas.drawCircle(Offset(size.width * 0.61, size.height * 0.54), 3.6, eyePaint);

    final smile = Path()
      ..moveTo(size.width * 0.42, size.height * 0.66)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.72,
        size.width * 0.58,
        size.height * 0.66,
      );
    canvas.drawPath(
      smile,
      Paint()
        ..color = SproutColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.025
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
