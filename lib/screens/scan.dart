import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'transfer.dart';

/// Scan QR ID. The camera view is simulated; after a moment a Wally contact is "found".
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  late final _line = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat(reverse: true);
  Contact? _found;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() => _found = contacts.first);
    });
  }

  @override
  void dispose() {
    _line.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1F16),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kPad),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: HeaderIconButton(icon: Icons.close_rounded, tooltip: 'Close'),
                    ),
                    Text(
                      'Scan QR ID',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Point your camera at a Wpay QR code',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      children: [
                        Positioned.fill(child: CustomPaint(painter: _Corners(_found != null))),
                        if (_found == null)
                          AnimatedBuilder(
                            animation: _line,
                            builder: (context, _) => Positioned(
                              left: 18,
                              right: 18,
                              top: 20 + _line.value * 216,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: WColors.green,
                                  boxShadow: [BoxShadow(color: WColors.green.withValues(alpha: 0.6), blurRadius: 12)],
                                ),
                              ),
                            ),
                          )
                        else
                          const Center(child: Icon(Icons.check_circle_rounded, color: WColors.green, size: 72)),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _found == null
                    ? const Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Text('Scanning…', style: TextStyle(color: Colors.white54)),
                      )
                    : Container(
                        key: const ValueKey('found'),
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Avatar(_found!, size: 48),
                              title: Text(_found!.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text(_found!.phone),
                            ),
                            const SizedBox(height: 8),
                            GreenButton(
                              label: 'Send Money',
                              onPressed: () => Navigator.of(
                                context,
                              ).pushReplacement(slideRoute(TransferWallyScreen(initial: _found))),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Corners extends CustomPainter {
  _Corners(this.done);

  final bool done;

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = done ? WColors.green : Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const l = 40.0;
    for (final (o, dx, dy) in [
      (Offset.zero, 1.0, 1.0),
      (Offset(s.width, 0), -1.0, 1.0),
      (Offset(0, s.height), 1.0, -1.0),
      (Offset(s.width, s.height), -1.0, -1.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(o.dx, o.dy + dy * l)
          ..lineTo(o.dx, o.dy + dy * 8)
          ..quadraticBezierTo(o.dx, o.dy, o.dx + dx * 8, o.dy)
          ..lineTo(o.dx + dx * l, o.dy),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_Corners old) => old.done != done;
}
