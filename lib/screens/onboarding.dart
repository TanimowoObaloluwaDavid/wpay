import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/face_scan.dart';
import 'auth.dart';

class _Slide {
  const _Slide(this.title, this.body, this.art);

  final String title;
  final String body;
  final Widget art;
}

final _slides = [
  const _Slide(
    'Your money,\nin one wallet',
    'Keep cards, balance and payments together. Pay anyone in seconds with Wpay.',
    _CardsArt(),
  ),
  const _Slide(
    'Send & receive\ninstantly',
    'Transfer to friends with Wally or to any bank account, with no hidden fees.',
    _TransferArt(),
  ),
  const _Slide(
    'Safe with\nFace ID',
    'Every payment is protected with face verification and bank-grade security.',
    _FaceArt(),
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _pc.nextPage(duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic);
    } else {
      Navigator.of(context).pushReplacement(slideRoute(const SignUpScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _slides.length - 1;
    return Scaffold(
      backgroundColor: WColors.forest,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: StripePainter())),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(kPad, 8, 8, 0),
                  child: Row(
                    children: [
                      const _Logo(),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacement(slideRoute(const LoginScreen())),
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pc,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.all(20),
                      child: FittedBox(fit: BoxFit.scaleDown, child: _slides[i].art),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(kPad, 28, kPad, 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Column(
                            key: ValueKey(_page),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _slides[_page].title,
                                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, height: 1.2),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _slides[_page].body,
                                style: const TextStyle(color: WColors.grey, fontSize: 15, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            for (var i = 0; i < _slides.length; i++)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.only(right: 6),
                                width: i == _page ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: i == _page ? WColors.green : WColors.line,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        GreenButton(label: last ? 'Get Started' : 'Next', onPressed: _next),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pushReplacement(slideRoute(const LoginScreen())),
                            style: TextButton.styleFrom(foregroundColor: WColors.grey),
                            child: const Text.rich(
                              TextSpan(
                                text: 'Already have an account? ',
                                children: [
                                  TextSpan(
                                    text: 'Log in',
                                    style: TextStyle(color: WColors.green, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const WpayLogo(),
      const SizedBox(width: 10),
      const Text(
        'Wpay',
        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
      ),
    ],
  );
}

/// White rounded label floating over the artwork ("+$250.00 Top up").
class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.color, required this.title, required this.sub});

  final IconData icon;
  final Color color;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 8))],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: WColors.ink),
            ),
            Text(sub, style: const TextStyle(color: WColors.grey, fontSize: 11)),
          ],
        ),
      ],
    ),
  );
}

/// Slide 1: tilted balance card over an orange card, with a top-up label.
class _CardsArt extends StatelessWidget {
  const _CardsArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 300,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.3,
            child: Container(
              width: 250,
              height: 150,
              decoration: BoxDecoration(color: WColors.orange, borderRadius: BorderRadius.circular(18)),
            ),
          ),
          Transform.rotate(
            angle: 0.08,
            child: const SizedBox(width: 280, child: BalanceCard(balance: 26968, last4: '3765', stacked: false)),
          ),
          const Positioned(
            right: 4,
            top: 34,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Icon(Icons.check_rounded, color: WColors.green, size: 28),
            ),
          ),
          const Positioned(
            left: 0,
            bottom: 12,
            child: _Pill(icon: Icons.add_rounded, color: WColors.green, title: '+\$250.00', sub: 'Top up successful'),
          ),
        ],
      ),
    );
  }
}

/// Slide 2: you in the middle, friends around you, a "sent" label.
class _TransferArt extends StatelessWidget {
  const _TransferArt();

  @override
  Widget build(BuildContext context) {
    Widget friend(Contact c, double size) => Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Avatar(c, size: size),
    );
    const orbit = 115.0;
    final spots = [
      (-0.35, contacts[0], 58.0),
      (0.85, contacts[2], 50.0),
      (3.95, contacts[1], 46.0),
      (2.9, contacts[3], 54.0),
    ];
    return SizedBox(
      width: 320,
      height: 300,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          CustomPaint(size: const Size(orbit * 2, orbit * 2), painter: _DashedCircle()),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: WColors.green, shape: BoxShape.circle),
            child: ClipOval(child: Image.asset('assets/images/av_bianca.png', width: 88, height: 88)),
          ),
          for (final (angle, c, size) in spots)
            Transform.translate(
              offset: Offset(math.cos(angle) * orbit, math.sin(angle) * orbit),
              child: friend(c, size),
            ),
          Transform.translate(
            offset: const Offset(62, -62),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: WColors.orange, shape: BoxShape.circle),
              child: const Icon(Icons.north_east_rounded, color: Colors.white, size: 20),
            ),
          ),
          const Positioned(
            bottom: 0,
            child: _Pill(
              icon: Icons.check_rounded,
              color: WColors.green,
              title: '\$132.00 sent',
              sub: 'to Dianna Russell',
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedCircle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final r = size.width / 2;
    const n = 48;
    for (var i = 0; i < n; i += 1) {
      final a = i * 2 * math.pi / n;
      canvas.drawArc(Rect.fromCircle(center: size.center(Offset.zero), radius: r), a, math.pi / n, false, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Slide 3: the Face ID ring from the verification screen, plus a secured label.
class _FaceArt extends StatelessWidget {
  const _FaceArt();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 320,
      height: 300,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 240,
            height: 240,
            child: CustomPaint(
              painter: TickRingPainter(0),
              child: Center(
                child: SizedBox(width: 86, height: 86, child: CustomPaint(painter: FaceScanPainter())),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 24,
            child: CircleAvatar(
              radius: 26,
              backgroundColor: WColors.orange,
              child: Icon(Icons.lock_rounded, color: Colors.white, size: 24),
            ),
          ),
          Positioned(
            bottom: 0,
            child: _Pill(
              icon: Icons.verified_user_rounded,
              color: WColors.green,
              title: 'Face verified',
              sub: 'Payment secured',
            ),
          ),
        ],
      ),
    );
  }
}
