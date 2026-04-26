import 'package:flutter/material.dart';

import '../../core/recommendation_engine.dart';
import '../../core/typography.dart';

import '../../ui_kit/floral_background.dart';
import '../../ui_kit/she_card.dart';
import '../../ui_kit/mood_theme.dart';
import '../../ui_kit/she_animated_navbar.dart';
import '../../ui_kit/animated_mood_face.dart';
import '../../ui_kit/cycle_calendar_card.dart';

import '../track/track_screen.dart';
import '../track/history_screen.dart';
import '../track/insights_screen.dart';
import '../learn/learn_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedMood = 2;
  int navIndex = 0;
  int cycleDay = 12;

  final moods = MoodType.values;

  MoodType get mood => moods[selectedMood];

  @override
  Widget build(BuildContext context) {
    final accent = MoodTheme.accent(mood);
    final bg = MoodTheme.background(mood);

    return Scaffold(
      backgroundColor: bg,

      body: Stack(
        children: [
          const FloralBackground(),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🌸 HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Good day ✨", style: SheTypography.h1),
                          const SizedBox(height: 6),
                          Text(
                            "check in with your energy today",
                            style: SheTypography.bodyMd,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text("🧸"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // 🌿 INSIGHT CARD
                  SheCard(
                    child: Text(
                      "🌿 ${RecommendationEngine.getRecommendation(selectedMood, cycleDay)}",
                      style: SheTypography.bodyMd,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🩸 CYCLE CARD
                  CycleCalendarCard(cycleDay: cycleDay),

                  const SizedBox(height: 20),

                  // 😊 MOOD SELECTOR
                  Text("how are you feeling?", style: SheTypography.h3),
                  const SizedBox(height: 12),

                  SheCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (index) {
                        return AnimatedMoodFace(
                          moodIndex: index,
                          isSelected: selectedMood == index,
                          onTap: () {
                            setState(() {
                              selectedMood = index;
                            });
                          },
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 💖 DAILY CARE
                  SheCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("💖 daily care", style: SheTypography.h3),
                        const SizedBox(height: 8),
                        Text(
                          "Drink water, move gently, and give yourself grace today.",
                          style: SheTypography.bodyMd,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 📝 JOURNAL PROMPT
                  SheCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📝 journal prompt", style: SheTypography.h3),
                        const SizedBox(height: 8),
                        Text(
                          "What made you feel calm or happy today?",
                          style: SheTypography.bodyMd,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🌙 CYCLE TIP
                  SheCard(
                    child: Text(
                      "🌙 Tip: Your energy may be lower today — take things slow.",
                      style: SheTypography.bodyMd,
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // 🌸 ANIMATED NAVBAR
        bottomNavigationBar: SheAnimatedNavBar(
        currentIndex: navIndex,
        onTap: (index) {
            setState(() => navIndex = index);

            switch (index) {
            case 1:
                Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InsightsScreen()),
                );
                break;

            case 2:
                Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrackScreen()),
                );
                break;

            case 3:
                Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LearnPage()),
                );
                break;

            case 4:
                Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
                break;
            }
        },
        ),
    );
  }
}