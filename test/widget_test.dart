import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wpay/main.dart';
import 'package:wpay/screens/auth.dart';
import 'package:wpay/screens/history.dart';
import 'package:wpay/screens/onboarding.dart';
import 'package:wpay/screens/receipt.dart';
import 'package:wpay/screens/shell.dart';
import 'package:wpay/screens/topup.dart';
import 'package:wpay/screens/transfer.dart';
import 'package:wpay/state.dart';

Future<AppState> pump(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(375 * 3, 812 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final state = AppState();
  await tester.pumpWidget(WpayApp(state: state, home: home));
  await tester.pump(const Duration(milliseconds: 800));
  return state;
}

void main() {
  testWidgets('Onboarding renders and advances', (tester) async {
    await pump(tester, const OnboardingScreen());
    expect(find.text('Next'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Send & receive'), findsOneWidget);
  });

  testWidgets('Auth screens render', (tester) async {
    await pump(tester, const LoginScreen());
    expect(find.text('Forgot password?'), findsOneWidget);
    await pump(tester, const SignUpScreen());
    expect(find.text('Full Name'), findsOneWidget);
    await pump(tester, const EmailVerifyScreen(email: 'a@b.co', forSignUp: true));
    expect(find.text('Verify'), findsOneWidget);
    await pump(tester, const FaceIdScreen());
    expect(find.text('Scan My Face'), findsOneWidget);
  });

  testWidgets('All tabs render', (tester) async {
    await pump(tester, const MainShell());
    expect(find.text('Hello Bianca,'), findsOneWidget);
    for (final tip in ['Statistic', 'Notification', 'Profile']) {
      await tester.tap(find.byTooltip(tip));
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('My Profile'), findsOneWidget);
  });

  testWidgets('Wally transfer lowers the balance', (tester) async {
    final state = await pump(tester, const TransferWallyScreen());
    final before = state.balance;
    await tester.tap(find.text('Dianna'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm Transfer'), findsOneWidget);
    await tester.tap(find.text('Transfer Money'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(state.balance, before - 132);
    expect(find.text('Transfer Success'), findsOneWidget);
  });

  testWidgets('Other money screens render', (tester) async {
    await pump(tester, const TransferBankScreen());
    expect(find.text('Select bank'), findsOneWidget);
    await pump(tester, const TopUpCardScreen());
    expect(find.text('Top Up Now'), findsOneWidget);
    await pump(tester, const AddCardScreen());
    expect(find.text('Scan your card'), findsOneWidget);
    await pump(tester, const PaymentHistoryScreen());
    expect(find.text('Spendings'), findsOneWidget);
    await pump(
      tester,
      const ReceiptScreen(
        title: 'Top Up Receipt',
        headline: 'Top Up Success',
        message: 'Your top up has been successfully done.',
        amountLabel: 'Total Top Up',
        amount: 132,
        destinationLabel: 'Top up destination',
        destination: 'Wally Virtual Card',
        destinationDetail: '0318-1608-2105',
        againLabel: 'Top up more money',
      ),
    );
    expect(find.text('\$132.00'), findsOneWidget);
  });
}
