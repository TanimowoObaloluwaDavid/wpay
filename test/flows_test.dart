// End-to-end flows: taps through the app like a user and checks the result of each journey.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wpay/main.dart';
import 'package:wpay/screens/auth.dart';
import 'package:wpay/screens/shell.dart';
import 'package:wpay/state.dart';
import 'package:wpay/theme.dart';

Future<AppState> start(WidgetTester tester, [Widget? home]) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final state = AppState();
  await tester.pumpWidget(WpayApp(state: state, home: home));
  await tester.pumpAndSettle();
  return state;
}

Future<void> tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Finder field(int i) => find.byType(TextFormField).at(i);

void main() {
  testWidgets('Onboarding → Sign up → Email code → Face ID → Home', (tester) async {
    await start(tester);
    await tap(tester, find.text('Next'));
    await tap(tester, find.text('Next'));
    await tap(tester, find.text('Get Started'));
    expect(find.text('Full Name'), findsOneWidget);

    // Empty form is rejected.
    await tap(tester, find.widgetWithText(FilledButton, 'Sign up'));
    expect(find.text('Enter your name'), findsOneWidget);
    expect(find.text('Enter a valid email'), findsOneWidget);

    await tester.enterText(field(0), 'Bianca Cooper');
    await tester.enterText(field(1), 'bianca@example.com');
    await tester.enterText(field(2), 'weak');
    await tap(tester, find.widgetWithText(FilledButton, 'Sign up'));
    expect(find.textContaining('At least 8 characters'), findsOneWidget);

    await tester.enterText(field(2), 'Password1');
    await tap(tester, find.byType(Checkbox));
    await tap(tester, find.widgetWithText(FilledButton, 'Sign up'));
    expect(find.text('Email Verification'), findsOneWidget);
    expect(find.textContaining('bianca@example.com'), findsOneWidget);

    FilledButton verify() => tester.widget(find.widgetWithText(FilledButton, 'Verify'));
    expect(verify().onPressed, isNull);
    await tester.enterText(find.byType(TextField).first, '1368');
    await tester.pump();
    expect(find.text('8'), findsOneWidget);
    expect(verify().onPressed, isNotNull);
    await tap(tester, find.text('Verify'));

    expect(find.text('Face ID Verification'), findsOneWidget);
    await tester.tap(find.text('Scan My Face'));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(MainShell), findsOneWidget);
    expect(find.text('Hello Bianca,'), findsOneWidget);
  });

  testWidgets('Log in, and Forgot password → code → new password', (tester) async {
    await start(tester, const LoginScreen());
    await tap(tester, find.widgetWithText(FilledButton, 'Log in'));
    expect(find.text('Enter a valid email'), findsOneWidget);

    await tap(tester, find.text('Forgot password?'));
    await tester.enterText(field(0), 'bianca@example.com');
    await tap(tester, find.text('Send Code'));
    await tester.enterText(find.byType(TextField).first, '4321');
    await tester.pump();
    await tap(tester, find.text('Verify'));
    expect(find.text('New Password'), findsWidgets);
    await tester.enterText(field(0), 'NewPass123');
    await tester.enterText(field(1), 'Different1');
    await tap(tester, find.text('Save Password'));
    expect(find.text('Passwords do not match'), findsOneWidget);
    await tester.enterText(field(1), 'NewPass123');
    await tap(tester, find.text('Save Password'));

    // Back on Log in, now sign in for real.
    await tester.enterText(field(0), 'bianca@example.com');
    await tester.enterText(field(1), 'NewPass123');
    await tap(tester, find.widgetWithText(FilledButton, 'Log in'));
    expect(find.byType(MainShell), findsOneWidget);
  });

  testWidgets('Top up with credit card adds to the balance', (tester) async {
    final app = await start(tester, const MainShell());
    final before = app.balance;
    await tap(tester, find.text('Top Up').first);
    expect(find.text('Top Up Method'), findsOneWidget);
    await tap(tester, find.text('Credit Card'));
    await tap(tester, find.text('\$250.00'));
    await tap(tester, find.text('Top Up Now'));
    expect(find.text('Top Up Success'), findsOneWidget);
    expect(app.balance, before + 250);

    // "Top up more money" opens a new top up on top of Home.
    await tap(tester, find.text('Top up more money'));
    expect(find.text('Top Up with Credit Card'), findsOneWidget);
    await tap(tester, find.text('Back to home'));
    expect(find.text(money(app.balance).split('.').first), findsOneWidget);
    expect(find.text('Top up from Mastercard'), findsWidgets);
  });

  testWidgets('Top up with bank: pick bank, read guides, copy account', (tester) async {
    await start(tester, const MainShell());
    await tap(tester, find.text('Top Up').first);
    await tap(tester, find.text('Bank Transfer'));
    expect(find.text('Top Up with Bank'), findsOneWidget);
    await tap(tester, find.text('Citibank'));
    expect(find.text('Citibank Virtual Account'), findsOneWidget);
    expect(find.text('Insert your ATM card and enter your PIN.'), findsOneWidget);
    await tap(tester, find.text('Top up via m-Banking'));
    expect(find.text('Log in to the Citibank mobile app.'), findsOneWidget);
    expect(find.text('Insert your ATM card and enter your PIN.'), findsNothing);
    await tap(tester, find.text('Copy'));
    expect(find.text('Virtual account number copied'), findsOneWidget);
  });

  testWidgets('Bank transfer lowers the balance and shows a receipt', (tester) async {
    final app = await start(tester, const MainShell());
    final before = app.balance;
    await tap(tester, find.text('Bank'));
    FilledButton cont() => tester.widget(find.widgetWithText(FilledButton, 'Continue'));
    expect(cont().onPressed, isNull);
    await tap(tester, find.text('Select bank'));
    await tap(tester, find.text('DBS'));
    await tester.enterText(field(0), '12345678');
    await tester.pump();
    expect(cont().onPressed, isNotNull);
    await tap(tester, find.text('Continue'));
    expect(find.text('Confirm Transfer'), findsOneWidget);
    expect(find.textContaining('5678'), findsWidgets);
    await tester.tap(find.text('Transfer Money'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Transfer Success'), findsOneWidget);
    expect(app.balance, before - 132);
    await tap(tester, find.text('Done'));
    expect(find.text('Transfer to DBS'), findsOneWidget);
  });

  testWidgets('Wally transfer to a new phone number; over-balance is blocked', (tester) async {
    final app = await start(tester, const MainShell());
    await tap(tester, find.text('Transfer'));
    FilledButton cta() => tester.widget(find.byType(FilledButton));
    expect(find.text('Choose a contact'), findsOneWidget);
    await tester.enterText(field(0), '(555) 123-4567');
    await tap(tester, find.byIcon(Icons.add_rounded));
    expect(find.text('New recipient'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '999999');
    await tester.pump();
    expect(find.text('Amount is more than your balance'), findsOneWidget);
    expect(cta().onPressed, isNull);
    await tester.enterText(find.byType(TextField).last, '50');
    await tester.pump();
    await tap(tester, find.text('Continue'));
    await tester.tap(find.text('Transfer Money'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(app.transactions.first.amount, -50);
  });

  testWidgets('Add a card with the card scanner', (tester) async {
    final app = await start(tester, const MainShell());
    await tap(tester, find.text('Top Up').first);
    await tap(tester, find.text('Credit Card'));
    await tap(tester, find.byIcon(Icons.add_rounded).first);
    expect(find.text('Add New Card'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
    await tester.tap(find.text('Scan your card'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Scan completed, now verify your data'), findsOneWidget);
    await tap(tester, find.text('Continue'));
    expect(app.cards.length, 3);
    expect(find.text('Top Up with Credit Card'), findsOneWidget);
  });

  testWidgets('History filter, and "View statistic" opens the Statistic tab', (tester) async {
    await start(tester, const MainShell());
    await tap(tester, find.text('History'));
    expect(find.text('Top up from Mastercard'), findsOneWidget);
    await tap(tester, find.byTooltip('Filter'));
    await tap(tester, find.text('Credit Card'));
    await tap(tester, find.text('Apply Filter'));
    expect(find.text('Clear filter'), findsOneWidget);
    expect(find.text('Top up from Mastercard'), findsNothing);
    await tap(tester, find.text('Clear filter'));
    expect(find.text('Top up from Mastercard'), findsOneWidget);
    await tap(tester, find.text('View statistic  >'));
    expect(find.text('Statistic Overview'), findsOneWidget);
    await tap(tester, find.text('Monthly'));
    await tap(tester, find.text('Weekly').last);
    expect(find.text('Weekly'), findsOneWidget);
  });

  testWidgets('Scan QR finds a contact and pre-fills the transfer', (tester) async {
    await start(tester, const MainShell());
    await tester.tap(find.byTooltip('Scan QR'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Dianna Russell'), findsOneWidget);
    await tester.tap(find.text('Send Money'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Transfer with Wally'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Tabs: notification back, cashback link, profile QR and logout', (tester) async {
    await start(tester, const MainShell());
    await tap(tester, find.byTooltip('Notification'));
    expect(find.text('Cashback 50%'), findsOneWidget);
    await tap(tester, find.text('Top up now  ›'));
    expect(find.text('Top Up Method'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20)); // dismiss sheet
    await tester.pumpAndSettle();
    await tap(tester, find.byTooltip('Back'));
    expect(find.text('Hello Bianca,'), findsOneWidget);

    await tap(tester, find.byTooltip('Profile'));
    await tap(tester, find.byTooltip('My QR code'));
    expect(find.text('My Wpay QR'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tap(tester, find.text('Logout'));
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
