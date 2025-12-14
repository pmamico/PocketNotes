import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PocketNotesLogo extends StatelessWidget {
  const PocketNotesLogo({super.key, this.size = 48, this.primaryColor, this.showShadow = true});

  final double size;
  final Color? primaryColor;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final accent = primaryColor ?? Theme.of(context).colorScheme.secondary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PocketNotesLogoPainter(accent: accent, showShadow: showShadow),
      ),
    );
  }
}

class _PocketNotesLogoPainter extends CustomPainter {
  _PocketNotesLogoPainter({required this.accent, required this.showShadow});

  final Color accent;
  final bool showShadow;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = shortest / 2;

    if (showShadow) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(center + Offset(0, shortest * 0.08), shortest * 0.32, shadowPaint);
    }

    final rimRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: shortest, height: shortest),
      Radius.circular(shortest * 0.32),
    );
    final rimPaint = Paint()
      ..shader = ui.Gradient.linear(
        center - Offset(shortest * 0.4, shortest * 0.4),
        center + Offset(shortest * 0.4, shortest * 0.4),
        [const Color(0xFF022216), const Color(0xFF09442D)],
      );
    canvas.drawRRect(rimRect, rimPaint);

    final feltPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius * 0.85,
        [const Color(0xFF0E8C5B), const Color(0xFF053D27)],
      );
    canvas.drawCircle(center, radius * 0.78, feltPaint);

    final pocketPaint = Paint()
      ..color = Colors.black.withOpacity(0.8);
    canvas.drawCircle(center + Offset(shortest * 0.15, radius * 0.05), radius * 0.28, pocketPaint);

    final cuePaint = Paint()
      ..strokeWidth = shortest * 0.08
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    cuePaint.color = Colors.brown.shade200;
    canvas.drawLine(
      center + Offset(-shortest * 0.35, -shortest * 0.3),
      center + Offset(shortest * 0.15, shortest * 0.25),
      cuePaint,
    );

    cuePaint
      ..color = accent.withOpacity(0.85)
      ..strokeWidth = shortest * 0.05;
    canvas.drawLine(
      center + Offset(-shortest * 0.3, shortest * 0.35),
      center + Offset(shortest * 0.3, -shortest * 0.1),
      cuePaint,
    );

    final cueBallCenter = center + Offset(-shortest * 0.12, shortest * 0.08);
    final cueBallPaint = Paint()..color = Colors.white;
    canvas.drawCircle(cueBallCenter, shortest * 0.16, cueBallPaint);

    final cheekPaint = Paint()..color = accent.withOpacity(0.4);
    canvas.drawCircle(cueBallCenter + Offset(-shortest * 0.07, shortest * 0.04), shortest * 0.025, cheekPaint);
    canvas.drawCircle(cueBallCenter + Offset(shortest * 0.05, shortest * 0.05), shortest * 0.025, cheekPaint);

    final eyePaint = Paint()..color = Colors.black.withOpacity(0.75);
    canvas.drawCircle(cueBallCenter + Offset(-shortest * 0.05, -shortest * 0.01), shortest * 0.015, eyePaint);
    canvas.drawCircle(cueBallCenter + Offset(shortest * 0.035, -shortest * 0.015), shortest * 0.015, eyePaint);

    final smilePath = Path()
      ..moveTo(cueBallCenter.dx - shortest * 0.05, cueBallCenter.dy + shortest * 0.04)
      ..quadraticBezierTo(
        cueBallCenter.dx,
        cueBallCenter.dy + shortest * 0.085,
        cueBallCenter.dx + shortest * 0.05,
        cueBallCenter.dy + shortest * 0.04,
      );
    final smilePaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..strokeWidth = shortest * 0.01
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(smilePath, smilePaint);

    final eightBallCenter = center + Offset(shortest * 0.22, -shortest * 0.12);
    final eightBallPaint = Paint()..color = Colors.black.withOpacity(0.85);
    canvas.drawCircle(eightBallCenter, shortest * 0.13, eightBallPaint);
    canvas.drawCircle(
      eightBallCenter - Offset(shortest * 0.03, shortest * 0.03),
      shortest * 0.05,
      Paint()..color = Colors.black.withOpacity(0.35),
    );
    final badgePaint = Paint()..color = Colors.white;
    canvas.drawCircle(eightBallCenter, shortest * 0.055, badgePaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '8',
        style: TextStyle(
          color: Colors.black,
          fontSize: shortest * 0.07,
          fontWeight: FontWeight.w800,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    final textOffset = eightBallCenter - Offset(textPainter.width / 2, textPainter.height / 2);
    textPainter.paint(canvas, textOffset);

    final sparklePaint = Paint()..color = Colors.white.withOpacity(0.8);
    final sparkleCenter = center + Offset(-shortest * 0.25, -shortest * 0.18);
    canvas.drawCircle(sparkleCenter, shortest * 0.01, sparklePaint);
    canvas.drawCircle(sparkleCenter + Offset(shortest * 0.03, shortest * 0.04), shortest * 0.015, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
