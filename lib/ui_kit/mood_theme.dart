import 'package:flutter/material.dart';

enum MoodType { sad, neutral, happy, excited, loved }

class MoodTheme {
  static Color background(MoodType mood) {
    switch (mood) {
      case MoodType.sad:
        return const Color(0xFFFFEFF3);
      case MoodType.neutral:
        return const Color(0xFFFFF5F7);
      case MoodType.happy:
        return const Color(0xFFFFE4EC);
      case MoodType.excited:
        return const Color(0xFFFFD6E8);
      case MoodType.loved:
        return const Color(0xFFFFC1D6);
    }
  }

  static Color accent(MoodType mood) {
    switch (mood) {
      case MoodType.sad:
        return const Color(0xFFB0A4B3);
      case MoodType.neutral:
        return const Color(0xFFFFA6C9);
      case MoodType.happy:
        return const Color(0xFFFF7AA2);
      case MoodType.excited:
        return const Color(0xFFFF4D88);
      case MoodType.loved:
        return const Color(0xFFFF2E63);
    }
  }
}