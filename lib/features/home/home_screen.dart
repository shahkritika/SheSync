import 'package:flutter/material.dart';
import 'dart:ui';

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

  final TextEditingController journalController = TextEditingController();

  /// 🌸 DAILY AFFIRMATIONS
  String getDailyAffirmation() {
    final affirmations = [
      "You are allowed to rest and still be worthy 💖",
      "Your body is not against you, it's communicating 🌸",
      "Slow progress is still progress 🌿",
      "You are doing better than you think ✨",
      "Healing is not linear, and that’s okay 💭",
      "You deserve softness, especially from yourself 🫶",
      "Your hormones don’t define your worth 🌙",
    ];

    final day = DateTime.now().day;
    return affirmations[day % affirmations.length];
  }

  String getMoodEmoji() {
    switch (selectedMood) {
      case 0:
        return "🥺";
      case 1:
        return "🌿";
      case 2:
        return "😌";
      case 3:
        return "💖";
      case 4:
        return "⚡";
      default:
        return "✨";
    }
  }

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

                  /// 🌸 PINTEREST HEADER (GLASS STACK)
                  SizedBox(
                    height: 230,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [

                        /// 🌙 GLOW
                        Positioned(
                          top: 30,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  accent.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        /// BACK CARD
                        Positioned(
                          top: 30,
                          child: Transform.rotate(
                            angle: -0.05,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              height: 170,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: accent.withOpacity(0.15),
                              ),
                            ),
                          ),
                        ),

                        /// MIDDLE CARD
                        Positioned(
                          top: 15,
                          child: Transform.rotate(
                            angle: 0.04,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.88,
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.4),
                                    accent.withOpacity(0.2),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        /// FRONT GLASS CARD
                        TweenAnimationBuilder(
                          tween: Tween(begin: 0.9, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, (1 - value) * 20),
                              child: Transform.scale(
                                scale: value,
                                child: child,
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 190,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white.withOpacity(0.25),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "today’s affirmation 🌙",
                                          style: SheTypography.bodyMd.copyWith(
                                            fontSize: 13,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                        Text(
                                          getMoodEmoji(),
                                          style: const TextStyle(fontSize: 22),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    Text(
                                      getDailyAffirmation(),
                                      style: SheTypography.h2.copyWith(
                                        height: 1.4,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),

                                    const Spacer(),

                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: accent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "for your journey 💫",
                                          style: SheTypography.bodyMd.copyWith(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🌿 INSIGHT
                  SheCard(
                    child: Text(
                      "🌿 ${RecommendationEngine.getRecommendation(selectedMood, cycleDay)}",
                      style: SheTypography.bodyMd,
                    ),
                  ),

                  const SizedBox(height: 16),

                  CycleCalendarCard(cycleDay: cycleDay),

                  const SizedBox(height: 20),

                  /// 😊 MOOD
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

                  /// 💖 DAILY CARE
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

                  /// 📝 INTERACTIVE JOURNAL
                  SheCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📝 journal", style: SheTypography.h3),
                        const SizedBox(height: 8),

                        TextField(
                          controller: journalController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "write what you're feeling...",
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              // TODO: save journal
                            },
                            child: const Text("Save 💖"),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 🌙 TIP
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

      /// 🌸 NAVBAR
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