import 'package:flutter/material.dart';

/// Colours sampled from the Wpay UI kit.
class WColors {
  static const forest = Color(0xFF105D38); // header green
  static const forestDark = Color(0xFF0D462F);
  static const green = Color(0xFF4CD080); // buttons, balance card
  static const greenSoft = Color(0xFFEDFAF2);
  static const orange = Color(0xFFFFAE58);
  static const orangeSoft = Color(0xFFFFF7EE);
  static const pink = Color(0xFFFF4081);
  static const ink = Color(0xFF030319);
  static const grey = Color(0xFF8F92A1);
  static const line = Color(0xFFE4E4E4);
  static const field = Color(0xFFF6F6F6);
  static const white = Colors.white;
}

class WTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'DM Sans',
      brightness: Brightness.light,
      scaffoldBackgroundColor: WColors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: WColors.green,
        primary: WColors.green,
        secondary: WColors.orange,
        surface: WColors.white,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: 'DM Sans', bodyColor: WColors.ink, displayColor: WColors.ink),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating, backgroundColor: WColors.forest),
      dividerColor: WColors.line,
    );
  }
}

/// Monospace style used on the cards ("Balance", "$26,968.00", card numbers).
TextStyle mono({double size = 14, Color color = WColors.white, FontWeight weight = FontWeight.w400}) =>
    TextStyle(fontFamily: 'Space Mono', fontSize: size, color: color, fontWeight: weight);

String money(double v) {
  final fixed = v.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '${v < 0 ? '-' : ''}\$$whole.${parts[1]}';
}
