import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const ExpTrailApp());
}

class ExpTrailApp extends StatelessWidget {
  const ExpTrailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExpTrail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
