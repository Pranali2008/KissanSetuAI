import 'package:flutter/material.dart';

/// Global theme mode: Light / Dark / System (follows the phone setting).
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

/// Brand colours (deep farm green, like the KissanAI look).
const Color kBrandLight = Color(0xFF14532D);
const Color kBrandDark = Color(0xFF2E9E5B);

Color brandof(BuildContext context) => brandOf(context);

Color brandOf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? kBrandDark : kBrandLight;

/// Works on every Flutter version (no withOpacity / withValues issues).
Color alpha(Color c, double opacity) => c.withAlpha((opacity * 255).round());

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: kBrandLight,
    brightness: brightness,
  ).copyWith(
    surface: dark ? const Color(0xFF15201A) : const Color(0xFFFFFFFF),
    onSurface: dark ? const Color(0xFFE8F0E9) : const Color(0xFF14211A),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? kBrandDark : kBrandLight,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}