import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() {
  runApp(SheSyncApp());
}

class SheSyncApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SheSync',
      theme: AppTheme.lightTheme,
      home: OnboardingScreen(),
    );
  }
}