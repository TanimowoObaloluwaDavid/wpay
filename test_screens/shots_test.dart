// Renders every screen to PNG for side-by-side comparison with the Figma kit.
// Run:  flutter test test_screens --update-goldens
// Output: test_screens/out/*.png
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wpay/main.dart';
import 'package:wpay/screens/auth.dart';
import 'package:wpay/screens/history.dart';
import 'package:wpay/screens/onboarding.dart';
import 'package:wpay/screens/receipt.dart';
import 'package:wpay/screens/scan.dart';
import 'package:wpay/screens/shell.dart';
import 'package:wpay/screens/topup.dart';
import 'package:wpay/screens/topup_bank.dart';
import 'package:wpay/screens/transfer.dart';
import 'package:wpay/state.dart';

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    loader.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
  }
  await loader.load();
}

Future<void> shot(
  WidgetTester tester,
  String name,
  Widget home, {
  Future<void> Function()? then,
  Size size = const Size(375, 812),
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(WpayApp(state: AppState(), home: home));
  await tester.pump(const Duration(seconds: 1));
  await _precache(tester);
  if (then != null) await then();
  await _precache(tester);
  await tester.pump(const Duration(seconds: 3));
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/$name.png'));
}

Future<void> _precache(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await tester.pump();
}

void main() {
  setUpAll(() async {
    await _loadFont('DM Sans', [
      for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) 'assets/fonts/DMSans-$w.ttf',
    ]);
    await _loadFont('Space Mono', ['assets/fonts/SpaceMono-Regular.ttf', 'assets/fonts/SpaceMono-Bold.ttf']);
    final sdk = Platform.environment['FLUTTER_ROOT'] ?? 'C:/flutter';
    await _loadFont('MaterialIcons', ['$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
  });

  testWidgets('onboarding', (t) => shot(t, 'onboarding', const OnboardingScreen()));
  for (final n in [2, 3]) {
    testWidgets(
      'onboarding$n',
      (t) => shot(
        t,
        'onboarding$n',
        const OnboardingScreen(),
        then: () async {
          for (var i = 1; i < n; i++) {
            await t.tap(find.text('Next'));
            await t.pumpAndSettle();
          }
        },
      ),
    );
  }
  testWidgets('onboarding_small', (t) => shot(t, 'onboarding_small', const OnboardingScreen(), size: const Size(320, 568)));
  testWidgets('login', (t) => shot(t, 'login', const LoginScreen()));
  testWidgets('faceid', (t) => shot(t, 'faceid', const FaceIdScreen()));
  testWidgets('home', (t) => shot(t, 'home', const MainShell()));
  for (final (i, tab) in ['Statistic', 'Notification', 'Profile'].indexed) {
    testWidgets(
      tab,
      (t) => shot(
        t,
        'tab${i + 1}_$tab',
        const MainShell(),
        then: () async {
          await t.tap(find.byTooltip(tab));
          await t.pump(const Duration(seconds: 1));
        },
      ),
    );
  }
  testWidgets('wally', (t) => shot(t, 'wally', const TransferWallyScreen()));
  testWidgets('bank', (t) => shot(t, 'bank', const TransferBankScreen()));
  testWidgets(
    'confirm',
    (t) => shot(
      t,
      'confirm',
      const ConfirmTransferScreen(
        to: Contact('Dianna Russell', '5150-1094-1012', avatar: 'assets/images/av_dianna.png'),
        subtitle: '5150-1094-1012',
        amount: 132,
        viaBank: true,
      ),
    ),
  );
  testWidgets('topup', (t) => shot(t, 'topup', const TopUpCardScreen()));
  testWidgets('addcard', (t) => shot(t, 'addcard', const AddCardScreen()));
  testWidgets('history', (t) => shot(t, 'history', const PaymentHistoryScreen()));
  testWidgets(
    'filter',
    (t) => shot(
      t,
      'filter',
      const PaymentHistoryScreen(),
      then: () async {
        await t.tap(find.byTooltip('Filter'));
        await t.pump(const Duration(seconds: 1));
      },
    ),
  );
  testWidgets('topupbank', (t) => shot(t, 'topupbank', const TopUpBankScreen()));
  testWidgets(
    'topupmethod',
    (t) => shot(
      t,
      'topupmethod',
      const MainShell(),
      then: () async {
        await t.tap(find.text('Top Up').first);
        await t.pump(const Duration(seconds: 1));
      },
    ),
  );
  testWidgets('scan', (t) => shot(t, 'scan', const ScanScreen()));
  testWidgets(
    'receipt',
    (t) => shot(
      t,
      'receipt',
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
    ),
  );
}
