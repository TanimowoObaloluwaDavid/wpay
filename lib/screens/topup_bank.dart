import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import '../widgets/common.dart';
import 'topup.dart';

/// "Top Up Method": pick credit card or bank transfer.
Future<void> showTopUpMethods(BuildContext context) async {
  final page = await showModalBottomSheet<Widget>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) {
      Widget option(IconData icon, String title, String sub, Widget page) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: WColors.field,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.pop(context, page),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: WColors.green, borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        Text(sub, style: const TextStyle(color: WColors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        ),
      );
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(kPad, 0, kPad, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHandle(),
              const SizedBox(height: 12),
              const Text('Top Up Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              option(
                Icons.credit_card_rounded,
                'Credit Card',
                'Instant, from your saved cards',
                const TopUpCardScreen(),
              ),
              option(
                Icons.account_balance_rounded,
                'Bank Transfer',
                'ATM, m-Banking or Internet Banking',
                const TopUpBankScreen(),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (page != null && context.mounted) await Navigator.push(context, slideRoute(page));
}

class TopUpBankScreen extends StatefulWidget {
  const TopUpBankScreen({super.key});

  @override
  State<TopUpBankScreen> createState() => _TopUpBankScreenState();
}

class _TopUpBankScreenState extends State<TopUpBankScreen> {
  static const _banks = [
    ('BRI', Icons.account_balance_rounded, Color(0xFF00529C)),
    ('DBS', Icons.close_rounded, Color(0xFFE2231A)),
    ('Citibank', Icons.language_rounded, Color(0xFF003B70)),
    ('HSBC', Icons.change_history_rounded, Color(0xFFDB0011)),
    ('Barclays', Icons.shield_outlined, Color(0xFF00AEEF)),
  ];
  static const _va = '8808 0318 1608 2105';

  int _bank = 0;
  int _open = 0;

  List<(String, List<String>)> _guides(String bank) => [
    (
      'Top up via ATM',
      [
        'Insert your ATM card and enter your PIN.',
        'Select Other Transactions > Transfer > $bank Virtual Account.',
        'Enter top up amount.',
        'Follow the next instructions to complete top-up.',
      ],
    ),
    (
      'Top up via m-Banking',
      [
        'Log in to the $bank mobile app.',
        'Choose Transfer > Virtual Account.',
        'Enter your Wpay virtual account number and the amount.',
        'Confirm with your PIN to complete top-up.',
      ],
    ),
    (
      'Top up via Internet Banking',
      [
        'Log in to $bank Internet Banking.',
        'Open Transfer > Virtual Account.',
        'Enter your Wpay virtual account number and the amount.',
        'Confirm with the token code to complete top-up.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bank = _banks[_bank].$1;
    final guides = _guides(bank);
    return GreenPage(
      title: 'Top Up with Bank',
      headerExtra: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(kPad, 24, kPad, 14),
            child: Text(
              'Select bank',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: kPad),
              scrollDirection: Axis.horizontal,
              itemCount: _banks.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final (name, icon, color) = _banks[i];
                final sel = i == _bank;
                return GestureDetector(
                  onTap: () => setState(() => _bank = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 92,
                    decoration: BoxDecoration(
                      color: sel ? WColors.green : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
                          ),
                          child: Icon(icon, color: color),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          name,
                          style: TextStyle(color: sel ? Colors.white : WColors.ink, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: WColors.greenSoft, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$bank Virtual Account', style: const TextStyle(color: WColors.grey, fontSize: 13)),
                      const SizedBox(height: 4),
                      const Text(_va, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: _va));
                    toast(context, 'Virtual account number copied');
                  },
                  style: TextButton.styleFrom(foregroundColor: WColors.green),
                  child: const Text('Copy', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Read instruction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text(
            'A step by step guide on how to top up with bank transfer',
            style: TextStyle(color: WColors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          for (final (i, (title, steps)) in guides.indexed) ...[
            InkWell(
              onTap: () => setState(() => _open = _open == i ? -1 : i),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                    AnimatedRotation(
                      turns: _open == i ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down_rounded, color: WColors.green),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              alignment: Alignment.topCenter,
              child: _open == i
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          for (final (n, step) in steps.indexed)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 11,
                                    backgroundColor: WColors.green,
                                    child: Text(
                                      '${n + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(step, style: const TextStyle(color: WColors.grey, height: 1.4)),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            if (i < guides.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}
