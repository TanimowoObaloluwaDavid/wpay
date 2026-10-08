import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'receipt.dart';

class TransferWallyScreen extends StatefulWidget {
  const TransferWallyScreen({super.key, this.initial});

  final Contact? initial;

  @override
  State<TransferWallyScreen> createState() => _TransferWallyScreenState();
}

class _TransferWallyScreenState extends State<TransferWallyScreen> {
  final _phone = TextEditingController();
  final _amount = TextEditingController(text: '132.00');
  late Contact? _to = widget.initial;

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phone.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _addNumber() {
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) return toast(context, 'Enter a valid phone number');
    setState(() => _to = Contact(_phone.text.trim(), _phone.text.trim(), color: WColors.orange));
    FocusScope.of(context).unfocus();
  }

  Future<void> _allContacts() async {
    final c = await showModalBottomSheet<Contact>(
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
              child: Text('All Contacts', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ),
            for (final c in contacts)
              ListTile(
                leading: Avatar(c, size: 44),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(c.phone),
                onTap: () => Navigator.pop(context, c),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (c != null) setState(() => _to = c);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final amount = parseAmount(_amount);
    final ok = _to != null && amount > 0 && amount <= app.balance;
    return GreenPage(
      title: 'Transfer with Wally',
      action: HeaderIconButton(icon: Icons.search_rounded, tooltip: 'Search contacts', onTap: _allContacts),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Contact', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: LineField(
                  label: 'Enter phone number',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+() -]'))],
                ),
              ),
              const SizedBox(width: 16),
              Material(
                color: WColors.orange,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _addNumber,
                  child: const SizedBox(width: 48, height: 48, child: Icon(Icons.add_rounded, color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: WColors.field, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SectionRow('Recent', action: 'See all contact', onAction: _allContacts),
                const SizedBox(height: 14),
                Row(
                  children: [
                    for (final c in contacts.take(4))
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _to = c),
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _to == c ? WColors.green : Colors.transparent, width: 2.5),
                                ),
                                child: Avatar(c, size: 56),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                c.firstName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: _to == c ? FontWeight.w700 : FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (_to != null && !contacts.contains(_to)) ...[
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Avatar(_to!, size: 44),
              title: Text(_to!.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('New recipient'),
              trailing: const Icon(Icons.check_circle, color: WColors.green),
            ),
          ],
          const SizedBox(height: 24),
          AmountPicker(controller: _amount),
          if (amount > app.balance)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Amount is more than your balance',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      bottom: GreenButton(
        label: _to == null ? 'Choose a contact' : 'Continue',
        onPressed: ok
            ? () => Navigator.push(
                context,
                slideRoute(ConfirmTransferScreen(to: _to!, subtitle: _to!.phone, amount: amount, viaBank: false)),
              )
            : null,
      ),
    );
  }
}

class TransferBankScreen extends StatefulWidget {
  const TransferBankScreen({super.key});

  @override
  State<TransferBankScreen> createState() => _TransferBankScreenState();
}

class _TransferBankScreenState extends State<TransferBankScreen> {
  final _account = TextEditingController();
  final _amount = TextEditingController(text: '132.00');
  String? _bank;

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
    _account.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _account.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickBank() async {
    final b = await showModalBottomSheet<String>(
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
              child: Text('Select bank', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ),
            for (final b in banks)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: WColors.greenSoft,
                  child: Text(
                    b[0],
                    style: const TextStyle(color: WColors.forest, fontWeight: FontWeight.w700),
                  ),
                ),
                title: Text(b),
                trailing: b == _bank ? const Icon(Icons.check_circle, color: WColors.green) : null,
                onTap: () => Navigator.pop(context, b),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (b != null) setState(() => _bank = b);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final amount = parseAmount(_amount);
    final acct = _account.text;
    final ok = _bank != null && acct.length >= 6 && amount > 0 && amount <= app.balance;
    return GreenPage(
      title: 'Transfer with Bank',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Bank Account', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickBank,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: WColors.line)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _bank ?? 'Select bank',
                      style: TextStyle(fontSize: 16, color: _bank == null ? WColors.grey : WColors.ink),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: WColors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          LineField(
            label: 'Account number',
            controller: _account,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)],
          ),
          const SizedBox(height: 28),
          AmountPicker(controller: _amount),
        ],
      ),
      bottom: GreenButton(
        label: 'Continue',
        onPressed: ok
            ? () {
                final masked = acct.length > 4 ? '•••• ${acct.substring(acct.length - 4)}' : acct;
                Navigator.push(
                  context,
                  slideRoute(
                    ConfirmTransferScreen(
                      to: Contact(_bank!, masked, color: WColors.forest),
                      subtitle: '$_bank  $masked',
                      amount: amount,
                      viaBank: true,
                    ),
                  ),
                );
              }
            : null,
      ),
    );
  }
}

class ConfirmTransferScreen extends StatefulWidget {
  const ConfirmTransferScreen({
    super.key,
    required this.to,
    required this.subtitle,
    required this.amount,
    required this.viaBank,
  });

  final Contact to;
  final String subtitle;
  final double amount;
  final bool viaBank;

  @override
  State<ConfirmTransferScreen> createState() => _ConfirmTransferScreenState();
}

class _ConfirmTransferScreenState extends State<ConfirmTransferScreen> {
  PayCard? _card;
  bool _sending = false;

  Future<void> _send() async {
    setState(() => _sending = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final app = AppScope.of(context);
    app.transfer(widget.to.name, widget.amount);
    Navigator.of(context).pushAndRemoveUntil(
      slideRoute(
        ReceiptScreen(
          title: 'Transfer Receipt',
          headline: 'Transfer Success',
          message: 'Your money has been sent to ${widget.to.firstName}.',
          amountLabel: 'Total Transfer',
          amount: widget.amount,
          destinationLabel: 'Transfer destination',
          destination: widget.to.name,
          destinationDetail: widget.subtitle,
          againLabel: 'Send more money',
          againPage: widget.viaBank ? const TransferBankScreen() : const TransferWallyScreen(),
        ),
      ),
      (r) => r.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final card = _card ?? app.cards.first;
    final now = DateTime.now();
    return Scaffold(
      backgroundColor: WColors.forest,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: StripePainter())),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: SizedBox(
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: HeaderIconButton(icon: Icons.chevron_left_rounded, tooltip: 'Back'),
                        ),
                        Text(
                          'Confirm Transfer',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: kPad),
                    child: Column(
                      children: [
                        const SizedBox(height: 28),
                        widget.viaBank
                            ? const CircleAvatar(
                                radius: 40,
                                backgroundColor: WColors.green,
                                child: Icon(Icons.account_balance_rounded, color: Colors.white, size: 34),
                              )
                            : Avatar(widget.to, size: 80),
                        const SizedBox(height: 16),
                        Text(
                          widget.to.name,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(widget.subtitle, style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Transfer on ${monthDay(now)}', style: const TextStyle(color: WColors.orange)),
                        const SizedBox(height: 28),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            money(widget.amount),
                            style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 28),
                        InfoNote(
                          widget.viaBank
                              ? 'Transfer made to bank account could take a few minutes.'
                              : 'Transfers to Wally users arrive instantly.',
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(kPad, 0, kPad, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SheetHandle(),
                        const SizedBox(height: 12),
                        const Text('Choose Cards', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        CardSelector(card: card, onChanged: (c) => setState(() => _card = c)),
                        const SizedBox(height: 20),
                        GreenButton(
                          label: _sending ? 'Sending…' : 'Transfer Money',
                          onPressed: _sending ? null : _send,
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
