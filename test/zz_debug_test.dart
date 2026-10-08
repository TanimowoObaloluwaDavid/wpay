import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wpay/main.dart';
import 'package:wpay/screens/shell.dart';
import 'package:wpay/state.dart';

List<String> texts(WidgetTester t) => find.byType(Text).evaluate().map((e) => (e.widget as Text).data ?? '').where((s) => s.isNotEmpty).take(12).toList();
Future<void> tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('topup', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final app = AppState();
    await tester.pumpWidget(WpayApp(state: app, home: const MainShell()));
    await tester.pumpAndSettle();
    await tap(tester, find.text('Top Up').first);
    await tap(tester, find.text('Credit Card'));
    await tap(tester, find.text('\$250.00'));
    await tap(tester, find.text('Top Up Now'));
    print('R: ${texts(tester)} bal=${app.balance}');
    await tap(tester, find.text('Top up more money'));
    print('A: ${texts(tester)}');
    await tap(tester, find.text('Back to home'));
    print('H: ${texts(tester)}');
  });
}
