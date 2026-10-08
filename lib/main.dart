import 'package:flutter/material.dart';

import 'screens/onboarding.dart';
import 'state.dart';
import 'theme.dart';

void main() => runApp(WpayApp(state: AppState()));

class WpayApp extends StatelessWidget {
  const WpayApp({super.key, required this.state, this.home});

  final AppState state;
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Wpay',
        debugShowCheckedModeBanner: false,
        theme: WTheme.light,
        home: home ?? const OnboardingScreen(),
      ),
    );
  }
}
