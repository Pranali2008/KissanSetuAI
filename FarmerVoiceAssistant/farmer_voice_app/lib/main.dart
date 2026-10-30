import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'home_screen.dart';

void main() => runApp(const FarmerVoiceApp());

class FarmerVoiceApp extends StatelessWidget {
  const FarmerVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'KissanSetu AI',
          themeMode: mode,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          home: const HomeScreen(),
        );
      },
    );
  }
}
