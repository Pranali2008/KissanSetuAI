import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const KissanSetuApp());
}

class KissanSetuApp extends StatelessWidget {
  const KissanSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KissanSetu AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}