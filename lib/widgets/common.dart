import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state.dart';
import '../theme.dart';

const double kPad = 24;

Route<T> slideRoute<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 320),
  pageBuilder: (_, _, _) => page,
  transitionsBuilder: (_, anim, _, child) {
    final c = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: c,
      child: SlideTransition(
        position: Tween(begin: const Offset(0.08, 0), end: Offset.zero).animate(c),
        child: child,
      ),
    );
  },
);

void toast(BuildContext context, String msg) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

/// Faint diagonal stripes drawn over the dark green headers.
class StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.035);
    final w = size.width;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.55, size.height)
        ..lineTo(w * 0.95, 0)
        ..lineTo(w * 1.15, 0)
        ..lineTo(w * 0.75, size.height)
        ..close(),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.82, size.height)
        ..lineTo(w * 1.2, 0)
        ..lineTo(w * 1.3, 0)
        ..lineTo(w * 0.92, size.height)
        ..close(),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Square outlined icon button used in the green headers.
class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({super.key, required this.icon, this.onTap, this.dark = false, this.tooltip});

  final IconData icon;
  final VoidCallback? onTap;
  final bool dark; // dark icon on a white page
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final color = dark ? WColors.ink : Colors.white;
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: dark ? WColors.line : Colors.white.withValues(alpha: 0.18)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ?? () => Navigator.of(context).maybePop(),
          child: SizedBox(width: 42, height: 42, child: Icon(icon, color: color, size: 20)),
        ),
      ),
    );
  }
}

/// Dark green header + white body, the main Wpay page layout.
///
/// Default: the body sits on a white sheet with rounded top corners and a handle.
/// [roundedHeader]: the green header itself has rounded bottom corners and the
/// body is plain white underneath (Top Up with Credit Card, Top Up with Bank).
class GreenPage extends StatelessWidget {
  const GreenPage({
    super.key,
    required this.title,
    required this.body,
    this.headerExtra,
    this.action,
    this.showBack = true,
    this.onBack,
    this.titleCentered = true,
    this.bottom,
    this.roundedHeader = false,
  });

  final String title;
  final Widget body;
  final Widget? headerExtra; // content under the title, still on green
  final Widget? action;
  final bool showBack;
  final VoidCallback? onBack;
  final bool titleCentered;
  final Widget? bottom; // pinned at the bottom of the page
  final bool roundedHeader;

  Widget _titleBar() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showBack)
            Align(
              alignment: Alignment.centerLeft,
              child: HeaderIconButton(icon: Icons.chevron_left_rounded, tooltip: 'Back', onTap: onBack),
            ),
          Align(
            alignment: titleCentered ? Alignment.center : Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: titleCentered ? 52 : (showBack ? 58 : 4), right: 52),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          if (action != null) Align(alignment: Alignment.centerRight, child: action),
        ],
      ),
    ),
  );

  Widget _body() => SingleChildScrollView(padding: const EdgeInsets.fromLTRB(kPad, 12, kPad, 24), child: body);

  Widget? _bottom() => bottom == null
      ? null
      : SafeArea(
          top: false,
          child: Padding(padding: const EdgeInsets.fromLTRB(kPad, 8, kPad, 16), child: bottom),
        );

  @override
  Widget build(BuildContext context) {
    if (roundedHeader) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [_titleBar(), ?headerExtra],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: _body()),
              ?_bottom(),
            ],
          ),
        ),
      );
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: WColors.forest,
        body: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: StripePainter())),
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _titleBar(),
                  ?headerExtra,
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SheetHandle(),
                          Expanded(child: _body()),
                          ?_bottom(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      width: 44,
      height: 4,
      decoration: BoxDecoration(color: WColors.line, borderRadius: BorderRadius.circular(2)),
    ),
  );
}

class GreenButton extends StatelessWidget {
  const GreenButton({super.key, required this.label, this.onPressed, this.color = WColors.green, this.textColor});

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor ?? Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: 'DM Sans', fontSize: 16, fontWeight: FontWeight.w500),
        ),
        child: Text(label),
      ),
    );
  }
}

/// Grey label above, value below, thin underline — the Wpay form style.
class LineField extends StatefulWidget {
  const LineField({
    super.key,
    required this.label,
    this.controller,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.suffix,
    this.hint,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;
  final String? hint;
  final ValueChanged<String>? onChanged;

  @override
  State<LineField> createState() => _LineFieldState();
}

class _LineFieldState extends State<LineField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _hidden,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      cursorColor: WColors.green,
      style: const TextStyle(fontSize: 16, color: WColors.ink),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        hintStyle: const TextStyle(color: WColors.grey),
        labelStyle: const TextStyle(color: WColors.grey, fontSize: 15),
        floatingLabelStyle: const TextStyle(color: WColors.grey, fontSize: 15),
        contentPadding: const EdgeInsets.only(top: 6, bottom: 10),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: WColors.line)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: WColors.green, width: 1.5)),
        suffixIcon: widget.obscure
            ? IconButton(
                onPressed: () => setState(() => _hidden = !_hidden),
                icon: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: WColors.grey),
              )
            : widget.suffix,
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar(this.contact, {super.key, this.size = 48});

  final Contact contact;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (contact.avatar != null) {
      return ClipOval(
        child: Image.asset(contact.avatar!, width: size, height: size, fit: BoxFit.cover),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: contact.color, shape: BoxShape.circle),
      child: Text(
        contact.initials,
        style: TextStyle(color: Colors.white, fontSize: size * 0.34, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Green balance card with the orange and dark cards peeking out behind it.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.last4,
    this.label = 'Balance',
    this.stacked = true,
    this.orangeBehind = true,
  });

  final double balance;
  final String last4;
  final String label;
  final bool stacked; // show the cards peeking out behind
  final bool orangeBehind; // false: only the dark card behind (Top Up screen)

  @override
  Widget build(BuildContext context) {
    final card = Container(
      height: 150,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: WColors.green,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: mono(size: 13, color: Colors.white.withValues(alpha: 0.85))),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(money(balance), style: mono(size: 26, weight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const _BrandCircles(),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              const _Chip(),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '••••  ••••  ••••',
                  style: mono(size: 16, color: Colors.white),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.clip,
                ),
              ),
              Text(last4, style: mono(size: 14)),
            ],
          ),
        ],
      ),
    );
    if (!stacked) return card;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: orangeBehind ? 34 : 24,
          right: orangeBehind ? 34 : 24,
          top: orangeBehind ? -22 : -16,
          height: 40,
          child: DecoratedBox(
            decoration: BoxDecoration(color: WColors.forestDark, borderRadius: BorderRadius.circular(16)),
          ),
        ),
        if (orangeBehind)
          Positioned(
            left: 16,
            right: 16,
            top: -11,
            height: 40,
            child: DecoratedBox(
              decoration: BoxDecoration(color: WColors.orange, borderRadius: BorderRadius.circular(16)),
            ),
          ),
        card,
      ],
    );
  }
}

class _BrandCircles extends StatelessWidget {
  const _BrandCircles();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 46,
    height: 28,
    child: Stack(
      children: [
        Positioned(left: 0, child: CircleAvatar(radius: 14, backgroundColor: Colors.white.withValues(alpha: 0.85))),
        Positioned(right: 0, child: CircleAvatar(radius: 14, backgroundColor: Colors.white.withValues(alpha: 0.55))),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip();

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 28,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
    ),
    child: CustomPaint(painter: _ChipLines()),
  );
}

class _ChipLines extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, s.height / 3), Offset(s.width, s.height / 3), p);
    canvas.drawLine(Offset(0, s.height * 2 / 3), Offset(s.width, s.height * 2 / 3), p);
    canvas.drawLine(Offset(s.width / 2, 0), Offset(s.width / 2, s.height), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Big centred amount with quick-pick chips ($100 / $250 / $500).
class AmountPicker extends StatelessWidget {
  const AmountPicker({super.key, required this.controller, this.question = 'How much would you like to transfer?'});

  final TextEditingController controller;
  final String question;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Set amount', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(question, style: const TextStyle(color: WColors.grey, fontSize: 14)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.only(bottom: 6),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: WColors.line)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('\$', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              IntrinsicWidth(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                  cursorColor: WColors.green,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              for (final v in [100, 250, 500])
                ActionChip(
                  label: Text(money(v.toDouble())),
                  onPressed: () => controller.text = v.toStringAsFixed(2),
                  backgroundColor: WColors.greenSoft,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  labelStyle: const TextStyle(color: WColors.green, fontSize: 13),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

double parseAmount(TextEditingController c) => double.tryParse(c.text) ?? 0;

/// "Mastercard  1956 •••• •••• 2356  v" card selector.
class CardSelector extends StatelessWidget {
  const CardSelector({super.key, required this.card, required this.onChanged});

  final PayCard card;
  final ValueChanged<PayCard> onChanged;

  @override
  Widget build(BuildContext context) {
    final cards = AppScope.of(context).cards;
    return Material(
      color: WColors.field,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final picked = await showModalBottomSheet<PayCard>(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SheetHandle(),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Choose Cards', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                  for (final c in cards)
                    ListTile(
                      leading: const MiniCard(),
                      title: Text(c.brand, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(c.masked),
                      trailing: c == card ? const Icon(Icons.check_circle, color: WColors.green) : null,
                      onTap: () => Navigator.pop(context, c),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
          if (picked != null) onChanged(picked);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const MiniCard(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.brand, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(card.masked, style: const TextStyle(color: WColors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class MiniCard extends StatelessWidget {
  const MiniCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 40,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
    child: Container(
      width: 34,
      height: 22,
      decoration: BoxDecoration(color: WColors.orange, borderRadius: BorderRadius.circular(4)),
      child: const Align(
        alignment: Alignment(-0.6, 0.2),
        child: SizedBox(width: 8, height: 6, child: ColoredBox(color: Color(0xFFFFD9A8))),
      ),
    ),
  );
}

class InfoNote extends StatelessWidget {
  const InfoNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
        ),
      ],
    ),
  );
}

class SectionRow extends StatelessWidget {
  const SectionRow(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action!, style: const TextStyle(color: WColors.green, fontSize: 13)),
        ),
    ],
  );
}

/// Row in a transaction list.
class TxTile extends StatelessWidget {
  const TxTile(this.tx, {super.key});

  final Tx tx;

  @override
  Widget build(BuildContext context) {
    final positive = tx.amount > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: tx.color, borderRadius: BorderRadius.circular(14)),
            child: Icon(tx.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 3),
                Text(
                  '${shortDate(tx.date)}  •  ${clock(tx.date)}',
                  style: const TextStyle(color: WColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${positive ? '+' : ''}${money(tx.amount)}',
            style: TextStyle(fontWeight: FontWeight.w600, color: positive ? WColors.green : WColors.ink),
          ),
        ],
      ),
    );
  }
}

/// Shows only the top [visible] pixels of [child] — used to cut the balance
/// card off at the bottom edge of a rounded green header, like the design.
class CutBottom extends StatelessWidget {
  const CutBottom({super.key, required this.visible, required this.child});

  final double visible;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: visible,
    child: ClipRect(
      clipper: _TopOnly(),
      child: OverflowBox(alignment: Alignment.topCenter, maxHeight: double.infinity, child: child),
    ),
  );
}

/// Clips only the bottom edge, so shadows and the cards behind can still show above.
class _TopOnly extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => Rect.fromLTRB(-100, -100, size.width + 100, size.height);

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

/// Wpay logo: green card in front of an orange one, tilted.
class WpayLogo extends StatelessWidget {
  const WpayLogo({super.key, this.scale = 1});

  final double scale;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 46 * scale,
    height: 34 * scale,
    child: Stack(
      children: [
        Positioned(
          left: 6 * scale,
          top: 2 * scale,
          child: Transform.rotate(
            angle: -0.22,
            child: Container(
              width: 36 * scale,
              height: 22 * scale,
              decoration: BoxDecoration(color: WColors.orange, borderRadius: BorderRadius.circular(4 * scale)),
            ),
          ),
        ),
        Positioned(
          left: 2 * scale,
          top: 9 * scale,
          child: Transform.rotate(
            angle: -0.22,
            child: Container(
              width: 36 * scale,
              height: 22 * scale,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: WColors.green, borderRadius: BorderRadius.circular(4 * scale)),
              child: Text(
                'Wpay',
                style: TextStyle(color: Colors.white, fontSize: 8 * scale, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
