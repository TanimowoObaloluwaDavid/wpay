import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Ring of thick ticks around a lighter disc. While scanning, ticks turn white one by one.
class TickRingPainter extends CustomPainter {
  const TickRingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas.drawCircle(
      c,
      r - 4,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFF2E8A5C), WColors.forest.withValues(alpha: 0.9)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    const ticks = 72;
    for (var i = 0; i < ticks; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / ticks;
      final scanned = progress > 0 && i / ticks < progress;
      final p = Paint()
        ..color = scanned ? Colors.white : WColors.green
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.butt;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + dir * (r - 22), c + dir * (r - 2), p);
    }
  }

  @override
  bool shouldRepaint(TickRingPainter old) => old.progress != progress;
}

/// Face-ID glyph: four rounded corners, two eyes and a smile.
class FaceScanPainter extends CustomPainter {
  const FaceScanPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = WColors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.075
      ..strokeCap = StrokeCap.round;
    final l = s.width * 0.28, k = s.width * 0.12, w = s.width, h = s.height;
    for (final (x, y, dx, dy) in [(0.0, 0.0, 1.0, 1.0), (w, 0.0, -1.0, 1.0), (0.0, h, 1.0, -1.0), (w, h, -1.0, -1.0)]) {
      canvas.drawPath(
        Path()
          ..moveTo(x, y + dy * l)
          ..lineTo(x, y + dy * k)
          ..quadraticBezierTo(x, y, x + dx * k, y)
          ..lineTo(x + dx * l, y),
        p,
      );
    }
    final dot = Paint()..color = WColors.green;
    canvas.drawCircle(Offset(w * 0.36, h * 0.4), w * 0.045, dot);
    canvas.drawCircle(Offset(w * 0.64, h * 0.4), w * 0.045, dot);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w / 2, h * 0.55), width: w * 0.32, height: h * 0.22),
      0.2,
      math.pi - 0.4,
      false,
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
