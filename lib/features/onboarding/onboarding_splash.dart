import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/colors.dart';
import 'onboarding_form.dart';

class OnboardingSplash extends StatefulWidget {
  const OnboardingSplash({super.key});

  @override
  State<OnboardingSplash> createState() => _OnboardingSplashState();
}

class _OnboardingSplashState extends State<OnboardingSplash> {

  @override
  void initState() {
    super.initState();

    // Navigate after 5 seconds
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingForm(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // keep your theme soft
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 🌸 Your App Icon
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.2),
                    blurRadius:40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(
                  'assets/icon.png',
                  width: 170,
                  height: 170,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // App Name
            const Text(
              "SheSync",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.3,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 10),

            // Tagline
            const Text(
              "Track • Balance • Thrive",
              style: TextStyle(
                fontSize: 17,
                color: Colors.black54,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}