import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../track/settings_screen.dart';
import '../track/track_screen.dart';
import '../learn/learn_page.dart';
import '../track/history_screen.dart';

import '../../ui_kit/she_animated_navbar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int navIndex = 0;

  // Order must match SheAnimatedNavBar's icons/labels:
  // 0 Home, 1 Settings, 2 Track, 3 Learn, 4 History
  final List<Widget> _pages = const [
    HomeScreen(),
    TrackScreen(),
    LearnPage(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: navIndex,
        children: _pages,
      ),
      bottomNavigationBar: SheAnimatedNavBar(
        currentIndex: navIndex,
        onTap: (index) => setState(() => navIndex = index),
      ),
    );
  }
}