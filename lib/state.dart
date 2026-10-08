import 'package:flutter/material.dart';

import 'theme.dart';

class Contact {
  const Contact(this.name, this.phone, {this.avatar, this.color = WColors.green});

  final String name;
  final String phone;
  final String? avatar; // asset path, or initials are shown
  final Color color;

  String get firstName => name.split(' ').first;
  String get initials => name.split(' ').map((p) => p[0]).take(2).join();
}

class PayCard {
  const PayCard(this.brand, this.number, this.holder, this.expiry, this.balance);

  final String brand;
  final String number; // 16 digits, no spaces
  final String holder;
  final String expiry;
  final double balance;

  String get last4 => number.substring(number.length - 4);
  String get masked => '${number.substring(0, 4)} •••• •••• $last4';
  String get spaced => [for (var i = 0; i < 16; i += 4) number.substring(i, i + 4)].join(' ');
}

enum TxKind { expense, transfer, topUp }

class Tx {
  const Tx(this.title, this.amount, this.date, this.icon, this.color, {this.kind = TxKind.expense});

  final String title;
  final double amount; // negative = money out
  final DateTime date;
  final IconData icon;
  final Color color;
  final TxKind kind;
}

class Notice {
  const Notice(this.title, this.subtitle, this.time, this.icon, this.color, this.section, {this.highlight = false});

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  final String section;
  final bool highlight;
}

const contacts = [
  Contact('Dianna Russell', '(480) 555-0103', avatar: 'assets/images/av_dianna.png'),
  Contact('Cody Banks', '(406) 555-0120'),
  Contact('Theresa Webb', '(219) 555-0114', avatar: 'assets/images/av_theresa.png'),
  Contact('Ben Fisher', '(307) 555-0133', avatar: 'assets/images/av_ben.png'),
  Contact('Jenny Wilson', '(505) 555-0125', color: WColors.orange),
];

const banks = ['BRI', 'DBS', 'Citibank', 'HSBC', 'Standard Chartered', 'Barclays'];

/// Simple in-memory app state shared through [AppScope].
class AppState extends ChangeNotifier {
  String userName = 'Bianca Cooper';
  String phone = '(480) 555-0103';
  String email = 'bianca@example.com';
  double balance = 26968.00;

  final List<PayCard> cards = [
    const PayCard('Mastercard', '1956756137162356', 'BIANCA COOPER', '11/24', 26968),
    const PayCard('Visa', '4539148803436765', 'BIANCA COOPER', '08/26', 4210.5),
  ];

  final List<Tx> transactions = [
    Tx('Starbucks Coffee', -156, DateTime(2020, 12, 2, 15, 9), Icons.local_cafe_rounded, WColors.forest),
    Tx('December Subscription', -60, DateTime(2020, 12, 1, 22), Icons.sports_basketball_rounded, WColors.pink),
    Tx(
      'Top up from Mastercard',
      250,
      DateTime(2020, 11, 28, 9, 30),
      Icons.add_card_rounded,
      WColors.green,
      kind: TxKind.topUp,
    ),
    Tx('Netflix Subscription', -87, DateTime(2020, 11, 11, 10, 2), Icons.movie_rounded, Colors.black),
    Tx('Starbucks Coffee', -156, DateTime(2020, 11, 2, 15, 9), Icons.local_cafe_rounded, WColors.forest),
  ];

  final List<Notice> notices = const [
    Notice(
      'Cashback 50%',
      'Get 50% cashback for the next top up',
      '9:00 AM',
      Icons.percent_rounded,
      WColors.green,
      'TODAY',
      highlight: true,
    ),
    Notice(
      'Daily Cashback',
      'Your daily cashback is ready',
      '8:00 AM',
      Icons.savings_outlined,
      WColors.orange,
      'YESTERDAY',
    ),
    Notice(
      'Use BLCK10 Promo',
      'Save 10% on your next transfer',
      '3:40 PM',
      Icons.local_offer_outlined,
      WColors.forest,
      'YESTERDAY',
    ),
    Notice('Cyber Monday Deal', 'Up to 30% off with Wpay', '10:39 AM', Icons.bolt_rounded, WColors.orange, 'YESTERDAY'),
    Notice(
      '\$250 top up successfully added',
      'Mastercard •••• 2356',
      '6:14 PM',
      Icons.account_balance_wallet_outlined,
      WColors.forest,
      'YESTERDAY',
    ),
    Notice(
      'Use NOV10 Promo Code',
      '10% off all payments',
      '3:40 PM',
      Icons.confirmation_number_outlined,
      WColors.orange,
      'LAST 7 DAY',
    ),
    Notice('30% Black Friday Deal', 'Only this weekend', '1:20 PM', Icons.sell_outlined, WColors.green, 'LAST 7 DAY'),
  ];

  /// Expense total shown on Statistic (earlier this month + what's in the list).
  double get monthExpense => spent + 1750;

  /// "You've spent ... over the past 2 months" on Payment History.
  double get twoMonthSpent => spent + 1088;

  double get spent => transactions.where((t) => t.amount < 0).fold(0.0, (s, t) => s - t.amount);
  double get income => transactions.where((t) => t.amount > 0).fold(0.0, (s, t) => s + t.amount) + 5190;

  void transfer(String to, double amount) {
    balance -= amount;
    transactions.insert(
      0,
      Tx('Transfer to $to', -amount, DateTime.now(), Icons.north_east_rounded, WColors.orange, kind: TxKind.transfer),
    );
    notifyListeners();
  }

  void topUp(PayCard from, double amount) {
    balance += amount;
    transactions.insert(
      0,
      Tx(
        'Top up from ${from.brand}',
        amount,
        DateTime.now(),
        Icons.add_card_rounded,
        WColors.green,
        kind: TxKind.topUp,
      ),
    );
    notifyListeners();
  }

  void addCard(PayCard card) {
    cards.add(card);
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// "Dec 2, 2020"
String monthDay(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

String shortDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

String clock(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '$h:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'AM' : 'PM'}';
}
