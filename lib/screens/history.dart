import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  String _category = 'All';
  Set<TxKind> _types = {}; // empty = all payment types

  static const _spendings = [
    (Icons.local_cafe_rounded, 'Starbucks', WColors.forest),
    (Icons.sports_basketball_rounded, 'Dribbble', WColors.pink),
    (Icons.movie_rounded, 'Netflix', Colors.black),
    (Icons.shopping_bag_rounded, 'Shopping', WColors.orange),
  ];

  Future<void> _filter() async {
    final result = await showModalBottomSheet<(String, Set<TxKind>)>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _FilterSheet(category: _category, types: _types),
    );
    if (result != null) {
      setState(() {
        _category = result.$1;
        _types = result.$2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final list = app.transactions.where((t) {
      if (_types.isNotEmpty && !_types.contains(t.kind)) return false;
      if (_category == 'All') return true;
      if (_category == 'Food & Drink') return t.icon == Icons.local_cafe_rounded;
      if (_category == 'Subscriptions') return t.title.contains('Subscription');
      if (_category == 'Transfers') return t.kind != TxKind.expense;
      return true;
    }).toList();
    return GreenPage(
      title: 'Payment History',
      action: HeaderIconButton(icon: Icons.tune_rounded, tooltip: 'Filter', onTap: _filter),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Spendings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _spendings.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final (icon, label, color) = _spendings[i];
                return Container(
                  width: 140,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 30),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: WColors.orangeSoft, borderRadius: BorderRadius.circular(14)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: WColors.orange,
                  child: Icon(Icons.arrow_drop_up_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You've spent ${money(app.twoMonthSpent).split('.').first} on expenses over the past 2 months",
                        style: const TextStyle(color: WColors.grey, height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop('statistic'),
                        child: const Text(
                          'View statistic  >',
                          style: TextStyle(color: WColors.orange, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text('Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              if (_category != 'All' || _types.isNotEmpty)
                ActionChip(
                  label: const Text('Clear filter'),
                  onPressed: () => setState(() {
                    _category = 'All';
                    _types = {};
                  }),
                  backgroundColor: WColors.greenSoft,
                  side: BorderSide.none,
                ),
            ],
          ),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'No payments match this filter',
                textAlign: TextAlign.center,
                style: TextStyle(color: WColors.grey),
              ),
            ),
          for (var i = 0; i < list.length; i++) ...[TxTile(list[i]), if (i < list.length - 1) const Divider(height: 1)],
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.category, required this.types});

  final String category;
  final Set<TxKind> types;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _category = widget.category;
  late final Set<TxKind> _types = {...widget.types};

  static const _typeLabels = {TxKind.transfer: 'Wally', TxKind.topUp: 'Bank Transfer', TxKind.expense: 'Credit Card'};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(kPad, 0, kPad, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            const SizedBox(height: 12),
            const Text('Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _category,
              isExpanded: true,
              underline: const Divider(height: 1, color: WColors.line),
              icon: const Icon(Icons.arrow_drop_down_rounded, color: WColors.grey),
              items: [
                for (final c in ['All', 'Food & Drink', 'Subscriptions', 'Transfers'])
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 20),
            const Text('Payment Type', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final k in [TxKind.transfer, TxKind.topUp, TxKind.expense])
                  FilterChip(
                    label: Text(_typeLabels[k]!),
                    selected: _types.contains(k),
                    showCheckmark: false,
                    selectedColor: WColors.greenSoft,
                    backgroundColor: const Color(0xFFF0F0F0),
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    labelStyle: TextStyle(color: _types.contains(k) ? WColors.green : WColors.grey),
                    onSelected: (on) => setState(() => on ? _types.add(k) : _types.remove(k)),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            GreenButton(label: 'Apply Filter', onPressed: () => Navigator.pop(context, (_category, _types))),
          ],
        ),
      ),
    );
  }
}
