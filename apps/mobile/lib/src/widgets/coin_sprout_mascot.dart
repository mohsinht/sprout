import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/sprout_tokens.dart';

/// Mood expressions the Sprout mascot can show.
///
/// These drive the eye/mouth/leaf configuration in the painter so the mascot
/// reads as a character, not an icon with a badge glued on.
enum CoinSproutMood {
  happy,
  thumbsUp,
  thinking,
  supportive,
  celebrating,
  peek,
  reading,
  worried,
  pointing,
}

/// The Sprout coin mascot — a round golden coin character with sprout leaves,
/// expressive eyes, small hands and feet.
///
/// This is a fully self-contained [CustomPaint] illustration with soft
/// gradients, glossy highlights and mood-driven facial expressions. No overlay
/// badges are used; the expression lives in the art itself.
class CoinSproutMascot extends StatelessWidget {
  const CoinSproutMascot({
    this.size = 92,
    this.mood = CoinSproutMood.happy,
    super.key,
  });

  final double size;
  final CoinSproutMood mood;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _CoinSproutMascotPainter(mood: mood),
    );
  }
}

class _CoinSproutMascotPainter extends CustomPainter {
  _CoinSproutMascotPainter({required this.mood});

  final CoinSproutMood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final center = Offset(s / 2, s * 0.56);
    final r = s * 0.32;

    _drawFeet(canvas, s, center, r);
    _drawHands(canvas, s, center, r);
    _drawCoinBody(canvas, s, center, r);
    _drawHighlight(canvas, s, center, r);
    _drawLeaves(canvas, s);
    _drawFace(canvas, s, center, r);
  }

  void _drawCoinBody(Canvas canvas, double s, Offset center, double r) {
    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.4),
        radius: 1.1,
        colors: [
          Color(0xFFFFE9A8),
          Color(0xFFF5C25B),
          Color(0xFFE8A82E),
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, bodyPaint);

    final rim = Paint()
      ..color = const Color(0xFFC8881A).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.012;
    canvas.drawCircle(center, r * 0.92, rim);

    final outline = Paint()
      ..color = const Color(0xFFB97818)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.022;
    canvas.drawCircle(center, r, outline);
  }

  void _drawHighlight(Canvas canvas, double s, Offset center, double r) {
    final hl = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [
          Colors.white.withValues(alpha: 0.55),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(center.dx - r * 0.35, center.dy - r * 0.45),
        radius: r * 0.5,
      ));
    canvas.drawCircle(
      Offset(center.dx - r * 0.35, center.dy - r * 0.45),
      r * 0.45,
      hl,
    );
  }

  void _drawLeaves(Canvas canvas, double s) {
    final stemTop = Offset(s * 0.5, s * 0.14);
    final stemBase = Offset(s * 0.5, s * 0.30);
    final stem = Paint()
      ..color = SproutColors.leaf
      ..strokeWidth = s * 0.035
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(stemBase, stemTop, stem);

    _drawLeaf(canvas, s, center: Offset(s * 0.38, s * 0.16), angle: -0.6);
    _drawLeaf(canvas, s,
        center: Offset(s * 0.62, s * 0.16), angle: 0.6, flip: true);
  }

  void _drawLeaf(Canvas canvas, double s,
      {required Offset center, required double angle, bool flip = false}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle * (flip ? -1 : 1));

    final w = s * 0.26;
    final h = s * 0.15;
    final leafPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(w * 0.5, -h * 1.1, w, 0)
      ..quadraticBezierTo(w * 0.5, h * 0.5, 0, 0)
      ..close();

    final leafPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [SproutColors.seed, SproutColors.leaf],
      ).createShader(Offset.zero & Size(w, h * 1.2));
    canvas.drawPath(leafPath, leafPaint);

    final vein = Paint()
      ..color = SproutColors.leaf.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.008
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(w * 0.85, 0), vein);

    final outline = Paint()
      ..color = SproutColors.leaf.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.01;
    canvas.drawPath(leafPath, outline);

    canvas.restore();
  }

  void _drawFace(Canvas canvas, double s, Offset center, double r) {
    final eyeY = center.dy - r * 0.12;
    final eyeOffset = r * 0.32;
    final eyeR = r * 0.13;

    switch (mood) {
      case CoinSproutMood.celebrating:
        _drawHappyEyes(canvas, center, eyeY, eyeOffset, eyeR, s, closed: true);
        _drawBigSmile(canvas, center, r, s);
        break;
      case CoinSproutMood.thinking:
        _drawEye(canvas, Offset(center.dx - eyeOffset, eyeY), eyeR, s,
            lookUp: true);
        _drawEye(canvas, Offset(center.dx + eyeOffset, eyeY), eyeR, s,
            lookUp: true);
        _drawSmirk(canvas, center, r, s);
        break;
      case CoinSproutMood.worried:
        _drawWorriedEyes(canvas, center, eyeY, eyeOffset, eyeR, s);
        _drawFrown(canvas, center, r, s);
        break;
      case CoinSproutMood.peek:
        _drawEye(canvas, Offset(center.dx - eyeOffset, eyeY), eyeR, s,
            open: false);
        _drawEye(canvas, Offset(center.dx + eyeOffset, eyeY), eyeR, s);
        _drawSmile(canvas, center, r, s, small: true);
        break;
      case CoinSproutMood.reading:
        _drawEye(canvas, Offset(center.dx - eyeOffset, eyeY), eyeR, s,
            lookDown: true);
        _drawEye(canvas, Offset(center.dx + eyeOffset, eyeY), eyeR, s,
            lookDown: true);
        _drawSmile(canvas, center, r, s, small: true);
        break;
      case CoinSproutMood.supportive:
        _drawHappyEyes(canvas, center, eyeY, eyeOffset, eyeR, s);
        _drawSmile(canvas, center, r, s);
        break;
      case CoinSproutMood.thumbsUp:
      case CoinSproutMood.pointing:
      case CoinSproutMood.happy:
        _drawHappyEyes(canvas, center, eyeY, eyeOffset, eyeR, s);
        _drawSmile(canvas, center, r, s);
        break;
    }
  }

  void _drawEye(Canvas canvas, Offset pos, double r, double s,
      {bool open = true, bool lookUp = false, bool lookDown = false}) {
    if (!open) {
      final arc = Paint()
        ..color = SproutColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.018
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(center: pos, width: r * 1.4, height: r * 0.8),
        math.pi,
        math.pi,
        false,
        arc,
      );
      return;
    }
    canvas.drawCircle(pos, r, Paint()..color = Colors.white);
    final pupilOffset = lookUp
        ? Offset(0, -r * 0.3)
        : lookDown
            ? Offset(0, r * 0.3)
            : Offset.zero;
    canvas.drawCircle(
      pos + pupilOffset,
      r * 0.55,
      Paint()..color = SproutColors.ink,
    );
    canvas.drawCircle(
      pos + pupilOffset + Offset(-r * 0.2, -r * 0.2),
      r * 0.18,
      Paint()..color = Colors.white,
    );
  }

  void _drawHappyEyes(Canvas canvas, Offset center, double eyeY,
      double eyeOffset, double eyeR, double s,
      {bool closed = false}) {
    if (closed) {
      for (final dx in [-eyeOffset, eyeOffset]) {
        final path = Path()
          ..moveTo(center.dx + dx - eyeR * 0.7, eyeY + eyeR * 0.2)
          ..quadraticBezierTo(
            center.dx + dx,
            eyeY - eyeR * 0.6,
            center.dx + dx + eyeR * 0.7,
            eyeY + eyeR * 0.2,
          );
        canvas.drawPath(
          path,
          Paint()
            ..color = SproutColors.ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * 0.02
            ..strokeCap = StrokeCap.round,
        );
      }
      return;
    }
    _drawEye(canvas, Offset(center.dx - eyeOffset, eyeY), eyeR, s);
    _drawEye(canvas, Offset(center.dx + eyeOffset, eyeY), eyeR, s);
  }

  void _drawWorriedEyes(Canvas canvas, Offset center, double eyeY,
      double eyeOffset, double eyeR, double s) {
    for (final dx in [-eyeOffset, eyeOffset]) {
      final brow = Paint()
        ..color = SproutColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.02
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(center.dx + dx - eyeR * 0.6, eyeY - eyeR * 0.9),
        Offset(center.dx + dx + eyeR * 0.6, eyeY - eyeR * 0.5),
        brow,
      );
      _drawEye(canvas, Offset(center.dx + dx, eyeY), eyeR, s);
    }
  }

  void _drawSmile(Canvas canvas, Offset center, double r, double s,
      {bool small = false}) {
    final w = r * (small ? 0.5 : 0.7);
    final path = Path()
      ..moveTo(center.dx - w / 2, center.dy + r * 0.18)
      ..quadraticBezierTo(
        center.dx,
        center.dy + r * (small ? 0.32 : 0.42),
        center.dx + w / 2,
        center.dy + r * 0.18,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = SproutColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.022
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawBigSmile(Canvas canvas, Offset center, double r, double s) {
    final w = r * 0.8;
    final rect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + r * 0.28),
      width: w,
      height: r * 0.5,
    );
    canvas.drawArc(
      rect,
      0,
      math.pi,
      true,
      Paint()..color = const Color(0xFF8B3A1A),
    );
    canvas.drawArc(
      rect.deflate(r * 0.08),
      0.2,
      math.pi - 0.4,
      true,
      Paint()..color = SproutColors.tomato.withValues(alpha: 0.5),
    );
  }

  void _drawSmirk(Canvas canvas, Offset center, double r, double s) {
    final path = Path()
      ..moveTo(center.dx - r * 0.3, center.dy + r * 0.22)
      ..quadraticBezierTo(
        center.dx + r * 0.1,
        center.dy + r * 0.35,
        center.dx + r * 0.4,
        center.dy + r * 0.12,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = SproutColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.022
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawFrown(Canvas canvas, Offset center, double r, double s) {
    final path = Path()
      ..moveTo(center.dx - r * 0.35, center.dy + r * 0.35)
      ..quadraticBezierTo(
        center.dx,
        center.dy + r * 0.15,
        center.dx + r * 0.35,
        center.dy + r * 0.35,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = SproutColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.022
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawHands(Canvas canvas, double s, Offset center, double r) {
    final handY = center.dy + r * 0.35;
    final handR = s * 0.05;
    final leftHand = Offset(center.dx - r * 1.02, handY);
    final rightHand = Offset(center.dx + r * 1.02, handY);

    if (mood == CoinSproutMood.thumbsUp) {
      canvas.drawCircle(leftHand, handR, _handPaint(s));
      _drawThumb(canvas, s, rightHand + Offset(0, -r * 0.4), handR);
    } else if (mood == CoinSproutMood.celebrating) {
      canvas.drawCircle(
        Offset(leftHand.dx, handY - r * 0.5),
        handR,
        _handPaint(s),
      );
      canvas.drawCircle(
        Offset(rightHand.dx, handY - r * 0.5),
        handR,
        _handPaint(s),
      );
    } else {
      canvas.drawCircle(leftHand, handR, _handPaint(s));
      canvas.drawCircle(rightHand, handR, _handPaint(s));
    }
  }

  Paint _handPaint(double s) => Paint()
    ..shader = const RadialGradient(
      center: Alignment(-0.3, -0.4),
      colors: [Color(0xFFFFE9A8), Color(0xFFF5C25B)],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: s * 0.05));

  void _drawThumb(Canvas canvas, double s, Offset pos, double r) {
    canvas.drawCircle(pos, r, _handPaint(s));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: pos + Offset(0, -r * 1.4),
          width: r * 0.7,
          height: r * 1.6,
        ),
        Radius.circular(r * 0.4),
      ),
      _handPaint(s),
    );
  }

  void _drawFeet(Canvas canvas, double s, Offset center, double r) {
    final footY = center.dy + r * 0.95;
    final footW = s * 0.10;
    final footH = s * 0.045;
    final footPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.4),
        colors: [Color(0xFFFFE9A8), Color(0xFFE8A82E)],
      ).createShader(
          Rect.fromCenter(center: Offset.zero, width: footW, height: footH));

    for (final dx in [-r * 0.4, r * 0.4]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx + dx, footY),
          width: footW,
          height: footH,
        ),
        footPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CoinSproutMascotPainter oldDelegate) =>
      oldDelegate.mood != mood;
}
