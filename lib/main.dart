import 'package:flutter/material.dart';

import 'canteen_page.dart';

void main() {
  runApp(const CanteenGoApp());
}

class CanteenGoApp extends StatelessWidget {
  const CanteenGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CanteenGo',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9F7FF),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9B7DD4)),
      ),
      home: const CanteenPage(),
    );
  }
}
