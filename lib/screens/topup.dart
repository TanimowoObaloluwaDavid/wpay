import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'receipt.dart';

class TopUpCardScreen extends StatefulWidget {
  const TopUpCardScreen({super.key});

  @override
  State<TopUpCardScreen> createState() => _TopUpCardScreenState();
}

class _TopUpCardScreenState extends State<TopUpCardScreen> {
  final _amount = TextEditingController(text: '130.00');
  final _pc = PageController(viewportFraction: 0.9);
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    _pc.dispose();
    super.dispose();
  }

  void _topUp(PayCard card) {
    final amount = parseAmount(_amount);
    AppScope.of(context).topUp(card, amount);
    Navigator.of(context).pushReplacement(
      slideRoute(
        ReceiptScreen(
          title: 'Top Up Receipt',
          headline: 'Top Up Success',
          message: 'Your top up has been successfully done.',
          amountLabel: 'Total Top Up',
          amount: amount,
          destinationLabel: 'Top up destination',
          destination: 'Wally Virtual Card',
          destinationDetail: '0318-1608-2105',
          againLabel: 'Top up more money',
          againPage: const TopUpCardScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final cards = app.cards;
    final card = cards[_index.clamp(0, cards.length - 1)];
    final amount = parseAmount(_amount);
    return GreenPage(
      title: 'Top Up with Credit Card',
      titleCentered: false,
      roundedHeader: true,
      headerExtra: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(kPad, 24, kPad, 20),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Credit Card',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      Text('Choose your credit card', style: TextStyle(color: Colors.white, fontSize: 15)),
                    ],
                  ),
                ),
                Material(
                  color: WColors.orange,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.push(context, slideRoute(const AddCardScreen())),
                    child: const SizedBox(width: 48, height: 48, child: Icon(Icons.add_rounded, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          // Card sits flush with the bottom of the header, cut off like the design.
          SizedBox(
            height: 150,
            child: PageView.builder(
              controller: _pc,
              itemCount: cards.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.fromLTRB(6, 18, 6, 0),
                child: CutBottom(
                  visible: 132,
                  child: BalanceCard(balance: cards[i].balance, last4: cards[i].last4, orangeBehind: false),
                ),
              ),
            ),
          ),
        ],
      ),
      body: AmountPicker(controller: _amount, question: 'How much would you like to top up?'),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GreenButton(label: 'Top Up Now', onPressed: amount > 0 ? () => _topUp(card) : null),
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            style: TextButton.styleFrom(foregroundColor: WColors.grey),
            child: const Text('Back to home'),
          ),
        ],
      ),
    );
  }
}

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _name = TextEditingController();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  bool _scanned = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_name, _number, _expiry, _cvv]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _number, _expiry, _cvv]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _digits => _number.text.replaceAll(' ', '');
  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      _digits.length == 16 &&
      RegExp(r'^(0[1-9]|1[0-2])/\d{2}$').hasMatch(_expiry.text) &&
      _cvv.text.length == 3;

  Future<void> _scan() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            CircularProgressIndicator(color: WColors.green),
            SizedBox(height: 20),
            Text('Scanning your cardâ€¦'),
          ],
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    Navigator.pop(context);
    setState(() {
      _scanned = true;
      _name.text = 'Bianca Cooper';
      _number.text = '1956 7561 3716 2356';
      _expiry.text = '11/24';
      _cvv.text = '531';
    });
  }

  void _save() {
    final app = AppScope.of(context);
    app.addCard(
      PayCard(
        _digits.startsWith('4') ? 'Visa' : 'Mastercard',
        _digits,
        _name.text.trim().toUpperCase(),
        _expiry.text,
        0,
      ),
    );
    toast(context, 'Card ending ${_digits.substring(12)} added');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final showPreview = _scanned || _digits.isNotEmpty;
    return GreenPage(
      title: 'Add New Card',
      headerExtra: Padding(
        padding: const EdgeInsets.fromLTRB(kPad, 20, kPad, 0),
        child: Text(
          _scanned
              ? 'Scan completed, now verify your data'
              : 'Fill in the fields below or use camera phone to scan card',
          style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.45),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: showPreview
                ? _CardPreview(name: _name.text, digits: _digits, expiry: _expiry.text)
                : const SizedBox(),
          ),
          LineField(label: 'Cardholder Name', controller: _name, keyboardType: TextInputType.name),
          const SizedBox(height: 12),
          LineField(
            label: 'Card Number',
            controller: _number,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, _GroupFormatter(4, ' ', 16)],
            suffix: _digits.length >= 4 ? const _McLogo() : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LineField(
                  label: 'Expiry Date',
                  hint: 'MM/YY',
                  controller: _expiry,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, _GroupFormatter(2, '/', 4)],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: LineField(
                  label: '3-digit CVV',
                  controller: _cvv,
                  obscure: false,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          if (!_scanned)
            Material(
              color: WColors.greenSoft,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _scan,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: WColors.green, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.document_scanner_outlined, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text('Scan your card', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottom: showPreview || _name.text.isNotEmpty
          ? GreenButton(label: 'Continue', onPressed: _valid ? _save : null)
          : null,
    );
  }
}

class _CardPreview extends StatelessWidget {
  const _CardPreview({required this.name, required this.digits, required this.expiry});

  final String name;
  final String digits;
  final String expiry;

  @override
  Widget build(BuildContext context) {
    final padded = digits.padRight(16, 'â€¢');
    final groups = [for (var i = 0; i < 16; i += 4) padded.substring(i, i + 4)].join('  ');
    final grey = mono(size: 13, color: const Color(0xFF8A8D99));
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      height: 150,
      decoration: BoxDecoration(color: const Color(0xFFF1F1F3), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(Icons.contactless_outlined, color: Colors.grey.shade400),
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                width: 36,
                height: 26,
                decoration: BoxDecoration(color: const Color(0xFFDADCE2), borderRadius: BorderRadius.circular(5)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(groups, style: grey.copyWith(fontSize: 15)),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  name.isEmpty ? 'CARDHOLDER' : name.toUpperCase(),
                  style: grey,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(expiry.isEmpty ? 'MM/YY' : expiry, style: grey),
            ],
          ),
        ],
      ),
    );
  }
}

class _McLogo extends StatelessWidget {
  const _McLogo();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 44,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(left: 4, child: CircleAvatar(radius: 11, backgroundColor: Color(0xFFEB001B))),
        Positioned(left: 18, child: CircleAvatar(radius: 11, backgroundColor: Color(0xDDF79E1B))),
      ],
    ),
  );
}

/// Inserts [sep] every [every] digits, up to [max] digits (card number, MM/YY).
class _GroupFormatter extends TextInputFormatter {
  _GroupFormatter(this.every, this.sep, this.max);

  final int every;
  final String sep;
  final int max;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > max ? digits.substring(0, max) : digits;
    final b = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i > 0 && i % every == 0) b.write(sep);
      b.write(capped[i]);
    }
    final text = b.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
