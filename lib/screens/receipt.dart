import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';

/// Ticket-style success receipt ("Top Up Receipt" in the design).
class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({
    super.key,
    required this.title,
    required this.headline,
    required this.message,
    required this.amountLabel,
    required this.amount,
    required this.destinationLabel,
    required this.destination,
    required this.destinationDetail,
    required this.againLabel,
    this.againPage,
  });

  final String title;
  final String headline;
  final String message;
  final String amountLabel;
  final double amount;
  final String destinationLabel;
  final String destination;
  final String destinationDetail;
  final String againLabel;
  final Widget? againPage; // opened by the second button, on top of Home

  @override
  Widget build(BuildContext context) {
    void home() => Navigator.of(context).popUntil((r) => r.isFirst);
    void again() {
      final nav = Navigator.of(context);
      nav.popUntil((r) => r.isFirst);
      if (againPage != null) nav.push(slideRoute(againPage!));
    }

    return Scaffold(
      backgroundColor: WColors.forest,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _Confetti())),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 22),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(kPad, 0, kPad, 24),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      builder: (context, t, child) => Transform.translate(
                        offset: Offset(0, 40 * (1 - t)),
                        child: Opacity(opacity: t.clamp(0, 1), child: child),
                      ),
                      child: _Ticket(
                        top: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(child: _Badge()),
                            const SizedBox(height: 18),
                            Text(
                              headline,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: WColors.grey),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              amountLabel,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: WColors.grey),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                money(amount),
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        bottom: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(destinationLabel, style: const TextStyle(color: WColors.grey)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: WColors.field, borderRadius: BorderRadius.circular(14)),
                              child: Row(
                                children: [
                                  const MiniCard(),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(destination, style: const TextStyle(fontWeight: FontWeight.w700)),
                                        Text(
                                          '$destinationDetail  •  ${TimeOfDay.now().format(context)}',
                                          style: const TextStyle(color: WColors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            GreenButton(label: 'Done', onPressed: home),
                            const SizedBox(height: 6),
                            TextButton(
                              onPressed: again,
                              style: TextButton.styleFrom(foregroundColor: WColors.forest),
                              child: Text(againLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge();

  @override
  Widget build(BuildContext context) => Container(
    width: 84,
    height: 84,
    padding: const EdgeInsets.all(6),
    decoration: const ShapeDecoration(color: WColors.forest, shape: StarBorder.polygon(sides: 10, pointRounding: 0.6)),
    child: Container(
      decoration: const ShapeDecoration(
        color: WColors.orange,
        shape: StarBorder.polygon(sides: 10, pointRounding: 0.6),
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
    ),
  );
}

/// White ticket: top part, dashed divider with side notches, bottom part, scalloped bottom edge.
class _Ticket extends StatelessWidget {
  const _Ticket({required this.top, required this.bottom});

  final Widget top;
  final Widget bottom;

  static const _notch = 11.0;
  static const _scallop = 7.0;

  @override
  Widget build(BuildContext context) {
    Widget hole({double? left, double? right}) => Positioned(
      left: left,
      right: right,
      child: Container(
        width: _notch * 2,
        height: _notch * 2,
        decoration: const BoxDecoration(color: WColors.forest, shape: BoxShape.circle),
      ),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(padding: const EdgeInsets.fromLTRB(20, 28, 20, 18), child: top),
              SizedBox(
                height: _notch * 2,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _Dashes()),
                    hole(left: -_notch),
                    hole(right: -_notch),
                  ],
                ),
              ),
              Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 0), child: bottom),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -_scallop,
          child: LayoutBuilder(
            builder: (context, c) {
              final n = (c.maxWidth / (_scallop * 3)).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  n,
                  (_) => Container(
                    width: _scallop * 2,
                    height: _scallop * 2,
                    decoration: const BoxDecoration(color: WColors.forest, shape: BoxShape.circle),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Dashes extends StatelessWidget {
  const _Dashes();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => Row(
      children: List.generate(
        (c.maxWidth / 10).floor(),
        (_) => Container(width: 5, height: 1.5, margin: const EdgeInsets.only(right: 5), color: WColors.line),
      ),
    ),
  );
}

class _Confetti extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final colors = [WColors.orange, WColors.green, const Color(0xFF45C7C1), Colors.white70];
    for (var i = 0; i < 26; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * 170;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      if (i.isEven) {
        final path = Path()
          ..moveTo(x, y)
          ..relativeQuadraticBezierTo(8, 10, 0, 20)
          ..relativeQuadraticBezierTo(-8, 10, 0, 20);
        canvas.drawPath(path, paint);
      } else {
        canvas.drawCircle(Offset(x, y), 3, paint..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
