import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../track/track_screen.dart';
import '../track/history_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  final screens = [
    const HomeScreen(),
    const TrackScreen(),
    const HistoryScreen(),
    const TipsScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTabTapped,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: "Track",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.spa),
            label: "Tips",
          ),
        ],
      ),
    );
  }
}

//
// TEMP Tips Screen
//
class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Tips coming soon 🌿"),
      ),
    );
  }
}