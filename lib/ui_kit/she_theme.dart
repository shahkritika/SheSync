import 'package:flutter/material.dart';
import 'mood_theme.dart';

class SheThemeController extends ChangeNotifier {
  MoodType _mood = MoodType.neutral;

  MoodType get mood => _mood;

  void setMood(MoodType newMood) {
    _mood = newMood;
    notifyListeners();
  }
}