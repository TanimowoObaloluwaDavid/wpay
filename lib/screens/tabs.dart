import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'auth.dart';
import 'history.dart';
import 'topup_bank.dart';
import 'transfer.dart';

// ---------------------------------------------------------------------------
// Home
// ---------------------------------------------------------------------------

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  Future<void> _open(BuildContext context, Widget page) async {
    final result = await Navigator.push(context, slideRoute<Object?>(page));
    if (result == 'statistic') onOpenTab(1);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final actions = <(IconData, String, Color, Widget Function()?)>[
      (Icons.send_rounded, 'Transfer', WColors.green, () => const TransferWallyScreen()),
      (Icons.account_balance_rounded, 'Bank', WColors.forest, () => const TransferBankScreen()),
      (Icons.add_card_rounded, 'Top Up', WColors.orange, null),
      (Icons.receipt_long_rounded, 'History', WColors.pink, () => const PaymentHistoryScreen()),
    ];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(kPad, 12, kPad, 110),
          children: [
            Row(
              children: [
                const WpayLogo(),
                const Spacer(),
                HeaderIconButton(
                  icon: Icons.settings_outlined,
                  dark: true,
                  tooltip: 'Settings',
                  onTap: () => onOpenTab(3),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello ${app.userName.split(' ').first},',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      const Text('Your available balance', style: TextStyle(color: WColors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                Text(
                  money(app.balance).split('.').first,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 34),
            BalanceCard(balance: app.balance, last4: app.cards.first.last4),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                children: [
                  for (final (icon, label, color, page) in actions)
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => page == null ? showTopUpMethods(context) : _open(context, page()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(icon, color: color),
                              ),
                              const SizedBox(height: 8),
                              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => showTopUpMethods(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: WColors.greenSoft, borderRadius: BorderRadius.circular(16)),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: WColors.green,
                      child: Icon(Icons.percent_rounded, color: Colors.white),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cashback 50%', style: TextStyle(fontWeight: FontWeight.w700)),
                          SizedBox(height: 2),
                          Text(
                            'Get 50% cashback on your next top up',
                            style: TextStyle(color: WColors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Top up now',
                      style: TextStyle(color: WColors.green, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Icon(Icons.chevron_right_rounded, color: WColors.green, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SectionRow(
              'Recent Transactions',
              action: 'See all',
              onAction: () => _open(context, const PaymentHistoryScreen()),
            ),
            const SizedBox(height: 4),
            for (final tx in app.transactions.take(4)) TxTile(tx),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Statistic
// ---------------------------------------------------------------------------

class StatisticTab extends StatefulWidget {
  const StatisticTab({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<StatisticTab> createState() => _StatisticTabState();
}

class _StatisticTabState extends State<StatisticTab> {
  bool _monthly = true;

  // income, expense per bucket (in $k)
  static const _monthlyData = [(1.8, 0.9), (3.6, 2.1), (3.1, 2.4), (4.9, 1.6)];
  static const _weeklyData = [(0.6, 0.4), (0.9, 0.7), (1.4, 0.5), (0.8, 1.1), (1.9, 0.6), (1.2, 0.9), (0.7, 0.3)];

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final data = _monthly ? _monthlyData : _weeklyData;
    final labels = _monthly ? ['Week 1', 'Week 2', 'Week 3', 'Week 4'] : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(kPad, 12, kPad, 110),
          children: [
            SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: HeaderIconButton(
                      icon: Icons.chevron_left_rounded,
                      dark: true,
                      onTap: widget.onBack,
                      tooltip: 'Back',
                    ),
                  ),
                  const Text('Statistic', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: HeaderIconButton(
                      icon: Icons.settings_outlined,
                      dark: true,
                      tooltip: 'Settings',
                      onTap: () => toast(context, 'Statistic settings coming soon'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: WColors.line),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(child: _Stat(money(app.income).split('.').first, 'Income', WColors.green, false)),
                    const VerticalDivider(color: WColors.line, width: 16),
                    Expanded(child: _Stat(money(app.monthExpense).split('.').first, 'Expense', WColors.orange, true)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Statistic Overview', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text('Nov 1, 2020 - Nov 30, 2020', style: TextStyle(color: WColors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                PopupMenuButton<bool>(
                  onSelected: (v) => setState(() => _monthly = v),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: false, child: Text('Weekly')),
                    PopupMenuItem(value: true, child: Text('Monthly')),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: WColors.field, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        Text(_monthly ? 'Monthly' : 'Weekly', style: const TextStyle(fontSize: 12)),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: TweenAnimationBuilder<double>(
                key: ValueKey(_monthly),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, t, _) => CustomPaint(painter: _BarChart(data, labels, t), size: Size.infinite),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_Legend(WColors.green, 'Income'), SizedBox(width: 20), _Legend(WColors.orange, 'Expense')],
            ),
            const SizedBox(height: 28),
            const Text('Category Chart', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Last 7 days expenses', style: TextStyle(color: WColors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CustomPaint(
                    painter: _Donut(const [(0.48, WColors.forest), (0.32, WColors.orange), (0.2, WColors.green)]),
                    child: const Center(child: Icon(Icons.local_cafe_rounded, color: WColors.forest, size: 40)),
                  ),
                ),
                const SizedBox(width: 24),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Legend(WColors.forest, 'Food & Drink  48%'),
                      SizedBox(height: 12),
                      _Legend(WColors.orange, 'Subscriptions  32%'),
                      SizedBox(height: 12),
                      _Legend(WColors.green, 'Shopping  20%'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, this.color, this.up);

  final String value;
  final String label;
  final Color color;
  final bool up;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 18,
        backgroundColor: color,
        child: Icon(up ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded, color: Colors.white, size: 30),
      ),
      const SizedBox(width: 10),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            Text(label, style: const TextStyle(color: WColors.grey, fontSize: 12)),
          ],
        ),
      ),
    ],
  );
}

class _Legend extends StatelessWidget {
  const _Legend(this.color, this.label);

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
      ),
      const SizedBox(width: 8),
      Flexible(child: Text(label, style: const TextStyle(fontSize: 13))),
    ],
  );
}

class _BarChart extends CustomPainter {
  _BarChart(this.data, this.labels, this.t);

  final List<(double, double)> data;
  final List<String> labels;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 34.0, bottom = 24.0, maxV = 5.0;
    final h = size.height - bottom;
    final label = TextPainter(textDirection: TextDirection.ltr);
    final grid = Paint()
      ..color = WColors.line
      ..strokeWidth = 1;
    for (final v in [0, 1, 3, 5]) {
      final y = h - v / maxV * h;
      for (var x = left; x < size.width; x += 8) {
        canvas.drawLine(Offset(x, y), Offset(x + 4, y), grid);
      }
      label.text = TextSpan(
        text: '\$${v}k'.replaceAll('\$0k', '\$0'),
        style: const TextStyle(fontFamily: 'DM Sans', color: WColors.grey, fontSize: 12),
      );
      label.layout();
      label.paint(canvas, Offset(0, y - label.height / 2));
    }
    final slot = (size.width - left) / data.length;
    final barW = math.min(14.0, slot / 4);
    for (var i = 0; i < data.length; i++) {
      final cx = left + slot * (i + 0.5);
      final (inc, exp) = data[i];
      void bar(double x, double v, Color c) {
        final top = h - (v / maxV * h) * t;
        canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            x,
            top,
            x + barW,
            h,
            topLeft: const Radius.circular(4),
            topRight: const Radius.circular(4),
          ),
          Paint()..color = c,
        );
      }

      bar(cx - barW - 2, inc, WColors.green);
      bar(cx + 2, exp, WColors.orange);
      label.text = TextSpan(
        text: labels[i],
        style: const TextStyle(fontFamily: 'DM Sans', color: WColors.grey, fontSize: 12),
      );
      label.layout();
      label.paint(canvas, Offset(cx - label.width / 2, h + 8));
    }
  }

  @override
  bool shouldRepaint(_BarChart old) => old.t != t || old.data != data;
}

class _Donut extends CustomPainter {
  _Donut(this.parts);

  final List<(double, Color)> parts;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    var start = -math.pi / 2;
    for (final (share, color) in parts) {
      final sweep = share * 2 * math.pi;
      canvas.drawArc(
        rect.deflate(12),
        start + 0.04,
        sweep - 0.08,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 22
          ..strokeCap = StrokeCap.butt,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Notifications
// ---------------------------------------------------------------------------

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final notices = AppScope.of(context).notices;
    final sections = <String>[];
    for (final n in notices) {
      if (!sections.contains(n.section)) sections.add(n.section);
    }
    return GreenPage(
      title: 'Notification',
      onBack: onBack,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final s in sections) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Text(s, style: const TextStyle(color: WColors.grey, fontSize: 12, letterSpacing: 0.6)),
              ),
              for (final n in notices.where((n) => n.section == s)) _NoticeTile(n),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile(this.n);

  final Notice n;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(n.highlight ? 14 : 6),
      decoration: BoxDecoration(
        color: n.highlight ? WColors.greenSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: n.color, borderRadius: BorderRadius.circular(12)),
                child: Icon(n.icon, color: Colors.white, size: 22),
              ),
              if (n.highlight)
                const Positioned(right: -2, top: -2, child: CircleAvatar(radius: 5, backgroundColor: WColors.orange)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                Text(n.highlight ? n.subtitle : n.time, style: const TextStyle(color: WColors.grey, fontSize: 12)),
                if (n.highlight) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => showTopUpMethods(context),
                    child: const Text(
                      'Top up now  >',
                      style: TextStyle(color: WColors.green, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile
// ---------------------------------------------------------------------------

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final items = [
      (Icons.person_rounded, 'Personal'),
      (Icons.lock_rounded, 'Privacy & Security'),
      (Icons.card_giftcard_rounded, 'Offers & Rewards'),
      (Icons.help_rounded, 'Help'),
    ];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 110),
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
            child: ColoredBox(
              color: WColors.forest,
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: StripePainter())),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(kPad, 12, kPad, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'My Profile',
                                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                                ),
                              ),
                              HeaderIconButton(
                                icon: Icons.qr_code_2_rounded,
                                tooltip: 'My QR code',
                                onTap: () => _showQr(context, app),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              ClipOval(child: Image.asset('assets/images/av_bianca.png', width: 88, height: 88)),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      app.userName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(app.phone, style: const TextStyle(color: Colors.white, fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text(app.email, style: const TextStyle(color: Colors.white, fontSize: 15)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          CutBottom(
                            visible: 132,
                            child: BalanceCard(balance: app.balance, last4: app.cards.first.last4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final (icon, label) in items)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: kPad),
              leading: Icon(icon, color: WColors.green),
              title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              trailing: const Icon(Icons.chevron_right_rounded, color: WColors.grey),
              onTap: () => toast(context, '$label settings coming soon'),
            ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: kPad),
            leading: const Icon(Icons.logout_rounded, color: WColors.green),
            title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            trailing: const Icon(Icons.chevron_right_rounded, color: WColors.grey),
            onTap: () => Navigator.of(
              context,
              rootNavigator: true,
            ).pushAndRemoveUntil(slideRoute(const LoginScreen()), (_) => false),
          ),
        ],
      ),
    );
  }

  void _showQr(BuildContext context, AppState app) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('My Wpay QR', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 180, height: 180, child: CustomPaint(painter: _FakeQr(app.phone.hashCode))),
            const SizedBox(height: 12),
            Text(app.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(app.phone, style: const TextStyle(color: WColors.grey)),
          ],
        ),
      ),
    );
  }
}

/// Decorative QR-style pattern (not a scannable code).
class _FakeQr extends CustomPainter {
  _FakeQr(this.seed);

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    const n = 25;
    final cell = size.width / n;
    final rnd = math.Random(seed);
    final p = Paint()..color = WColors.ink;
    bool finder(int x, int y) => (x < 7 && y < 7) || (x >= n - 7 && y < 7) || (x < 7 && y >= n - 7);
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (finder(x, y)) continue;
        if (rnd.nextBool()) canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), p);
      }
    }
    for (final o in [const Offset(0, 0), Offset((n - 7) * cell, 0), Offset(0, (n - 7) * cell)]) {
      canvas.drawRect(o & Size(cell * 7, cell * 7), p);
      canvas.drawRect((o + Offset(cell, cell)) & Size(cell * 5, cell * 5), Paint()..color = Colors.white);
      canvas.drawRect((o + Offset(cell * 2, cell * 2)) & Size(cell * 3, cell * 3), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
