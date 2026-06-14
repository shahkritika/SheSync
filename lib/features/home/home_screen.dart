import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

import '../../core/recommendation_engine.dart';
import '../../core/typography.dart';

import '../../ui_kit/she_card.dart';
import '../../ui_kit/mood_theme.dart';
import '../../ui_kit/she_animated_navbar.dart';
import '../../ui_kit/animated_mood_face.dart';
import '../../ui_kit/cycle_calendar_card.dart';

import '../track/track_screen.dart';
import '../track/history_screen.dart';
import '../track/insights_screen.dart';
import '../learn/learn_page.dart';

// ─────────────────────────────────────────────
//  BACKEND DATA LAYER
//  Drop-in static data. Replace with your
//  actual Firestore / Supabase calls later.
// ─────────────────────────────────────────────
class HomeBackend {
  // 31 affirmations – one per calendar day
  static const List<String> _affirmations = [
    "You are allowed to rest and still be worthy 💖",        // 1
    "Your body is not against you, it's communicating 🌸",   // 2
    "Slow progress is still progress 🌿",                    // 3
    "You are doing better than you think ✨",                // 4
    "Healing is not linear, and that's okay 💭",             // 5
    "You deserve softness, especially from yourself 🫶",     // 6
    "Your hormones don't define your worth 🌙",              // 7
    "Every small step forward is still movement 🌷",         // 8
    "Breathe. You are exactly where you need to be 🍃",      // 9
    "Nourishing yourself is an act of love 💐",              // 10
    "You are more resilient than you realise 🌺",            // 11
    "It's okay to feel everything you're feeling 🌊",        // 12
    "Your softness is your superpower 🦋",                   // 13
    "Rest is productive. Sleep is sacred 🌙",                // 14
    "Today, choose one kind thought about yourself 🌸",      // 15
    "You don't need to earn your own compassion 💗",         // 16
    "Your cycle is wisdom, not weakness 🌙",                 // 17
    "Tiny acts of care add up to transformation ✨",          // 18
    "You are worthy of peace, today and every day 🕊️",      // 19
    "Let yourself bloom at your own pace 🌻",                // 20
    "Your feelings are valid. Always 💜",                    // 21
    "Give yourself the grace you'd give a friend 🌷",        // 22
    "You carry so much — put something down today 🍃",       // 23
    "Even cloudy days are part of your journey ☁️",          // 24
    "You are not behind. You are on your own path 🌿",       // 25
    "Today, one glass of water is enough love 💧",           // 26
    "Your presence in this world matters 🌸",                // 27
    "Rest without guilt. You've earned it 🫶",               // 28
    "You are in progress — beautifully so 💫",               // 29
    "Your body listens to every word you think 🌙",          // 30
    "End this month knowing you showed up for you 💖",       // 31
  ];

  // 31 daily tips – one per calendar day
  static const List<String> _tips = [
    "Sip warm water with lemon first thing to ease bloating 🍋",
    "A 10-minute walk can lift your mood as much as a workout 🚶‍♀️",
    "Magnesium-rich foods like dark chocolate ease cramps 🍫",
    "Journaling for 5 mins before bed reduces cortisol 📓",
    "Cold water on your wrists can calm anxiety fast 💧",
    "Seed cycling (flax + pumpkin in follicular phase) may balance hormones 🌱",
    "Gentle yoga twists support lymphatic drainage 🧘‍♀️",
    "Eating iron-rich foods like lentils replenishes after your period 🫘",
    "Blue light from screens can disrupt your cycle — try night mode 🌙",
    "Deep belly breathing activates your rest-and-digest system 🍃",
    "Castor oil packs on your lower belly may ease period pain 🌿",
    "Your skin may glow during ovulation — moisturise and enjoy it 🌷",
    "Avoid skipping meals during the luteal phase; blood sugar spikes worsen PMS 🍽️",
    "Chamomile tea before bed helps with cycle-related insomnia 🌼",
    "Acupressure on the inner ankle can relieve cramps ✨",
    "Dark leafy greens = folate + iron. Your best friends this week 🥬",
    "Wearing cosy socks keeps your uterus warm and happy 🧦",
    "Omega-3s from flaxseed or walnuts reduce inflammation 🌰",
    "A hot water bottle on your lower back works wonders 🔥",
    "Limit caffeine during your luteal phase — it can worsen anxiety ☕",
    "Turmeric latte has anti-inflammatory magic for period cramps 🌙",
    "Stretch your hip flexors today — they hold so much tension 🌸",
    "Zinc from pumpkin seeds supports healthy progesterone 🎃",
    "Your energy is cyclical — plan your week around it, not against it 📅",
    "A foot massage can help redirect cramp pain 💆‍♀️",
    "Drinking raspberry leaf tea may ease cramping over time 🍵",
    "Your mood shifts are hormonal, not personal flaws 💜",
    "Vitamin D from sunlight supports hormone production ☀️",
    "Eat enough protein — it's essential for hormone building blocks 🥚",
    "Tracking your cycle = knowing yourself better every month 📊",
    "You made it through this month. Celebrate yourself 🌸",
  ];

  // 7 mood-aware insights (index 0-4 for mood, 5 = general, 6 = general)
  static const List<String> _moodInsights = [
    "Low energy days are valid rest days — your body is working hard even when you can't feel it 🌙",
    "Your calm today might be the calm before a surge of creativity — honour both 🌿",
    "Feeling balanced is a gift. Notice what you did today to get here ✨",
    "Your joy today is real and earned 💖",
    "Channel that electric energy into something creative — your peak window is open ⚡",
    "Small steps today count as much as big ones tomorrow 🌸",
    "Being gentle with yourself IS the work 🫶",
  ];

  static String getDailyAffirmation() {
    final day = DateTime.now().day; // 1–31
    return _affirmations[(day - 1).clamp(0, 30)];
  }

  static String getDailyTip() {
    final day = DateTime.now().day;
    return _tips[(day - 1).clamp(0, 30)];
  }

  static String getMoodInsight(int moodIndex) {
    return _moodInsights[moodIndex.clamp(0, 4)];
  }

  // Cycle phase label based on day
  static String getCyclePhaseLabel(int cycleDay) {
    if (cycleDay <= 5) return "Menstrual 🩸";
    if (cycleDay <= 13) return "Follicular 🌱";
    if (cycleDay <= 16) return "Ovulation ✨";
    return "Luteal 🌙";
  }

  static Color getCyclePhaseColor(int cycleDay) {
    if (cycleDay <= 5) return const Color(0xFFE57373);
    if (cycleDay <= 13) return const Color(0xFF81C784);
    if (cycleDay <= 16) return const Color(0xFFFFD54F);
    return const Color(0xFF9575CD);
  }

  // Generate 28-day calendar with phase info
  static List<Map<String, dynamic>> generateCycleCalendar(int currentCycleDay) {
    return List.generate(28, (i) {
      final day = i + 1;
      String phase;
      Color color;
      if (day <= 5) {
        phase = "M";
        color = const Color(0xFFE57373);
      } else if (day <= 13) {
        phase = "F";
        color = const Color(0xFF81C784);
      } else if (day <= 16) {
        phase = "O";
        color = const Color(0xFFFFD54F);
      } else {
        phase = "L";
        color = const Color(0xFF9575CD);
      }
      return {'day': day, 'phase': phase, 'color': color, 'isCurrent': day == currentCycleDay};
    });
  }
}

// ─────────────────────────────────────────────
//  ANIMATED PETAL BACKGROUND
// ─────────────────────────────────────────────
class _Petal {
  double x, y, size, speed, angle, drift, opacity;
  String emoji;

  _Petal({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
    required this.drift,
    required this.opacity,
    required this.emoji,
  });
}

class FloralParticleBackground extends StatefulWidget {
  final Color accentColor;
  const FloralParticleBackground({super.key, required this.accentColor});

  @override
  State<FloralParticleBackground> createState() => _FloralParticleBackgroundState();
}

class _FloralParticleBackgroundState extends State<FloralParticleBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Petal> _petals = [];
  final _rand = Random();
  final _emojis = ['🌸', '🌺', '🌷', '✿', '❋', '🌼'];

  @override
  void initState() {
    super.initState();
    _spawnPetals();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        _update();
      })
      ..repeat();
  }

  void _spawnPetals() {
    for (int i = 0; i < 18; i++) {
      _petals.add(_Petal(
        x: _rand.nextDouble(),
        y: _rand.nextDouble(),
        size: 14 + _rand.nextDouble() * 16,
        speed: 0.0003 + _rand.nextDouble() * 0.0005,
        angle: _rand.nextDouble() * 2 * pi,
        drift: (_rand.nextDouble() - 0.5) * 0.001,
        opacity: 0.12 + _rand.nextDouble() * 0.18,
        emoji: _emojis[_rand.nextInt(_emojis.length)],
      ));
    }
  }

  void _update() {
    setState(() {
      for (final p in _petals) {
        p.y += p.speed;
        p.x += p.drift;
        p.angle += 0.005;
        if (p.y > 1.1) {
          p.y = -0.05;
          p.x = _rand.nextDouble();
        }
        if (p.x > 1.1) p.x = -0.05;
        if (p.x < -0.1) p.x = 1.05;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.accentColor.withOpacity(0.08),
                  const Color(0xFFFDF6F9),
                  widget.accentColor.withOpacity(0.05),
                ],
              ),
            ),
          ),
          // Petals
          ...(_petals.map((p) => Positioned(
                left: p.x * constraints.maxWidth,
                top: p.y * constraints.maxHeight,
                child: Transform.rotate(
                  angle: p.angle,
                  child: Opacity(
                    opacity: p.opacity,
                    child: Text(
                      p.emoji,
                      style: TextStyle(fontSize: p.size),
                    ),
                  ),
                ),
              ))),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────
//  CYCLE PHASE LEGEND ROW
// ─────────────────────────────────────────────
class _PhaseLegend extends StatelessWidget {
  const _PhaseLegend();

  @override
  Widget build(BuildContext context) {
    final phases = [
      {'label': 'Menstrual', 'color': const Color(0xFFE57373)},
      {'label': 'Follicular', 'color': const Color(0xFF81C784)},
      {'label': 'Ovulation', 'color': const Color(0xFFFFD54F)},
      {'label': 'Luteal', 'color': const Color(0xFF9575CD)},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: phases
          .map((p) => Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: p['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    p['label'] as String,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────
//  CYCLE CALENDAR WIDGET
// ─────────────────────────────────────────────
class _CycleCalendarWidget extends StatelessWidget {
  final int cycleDay;
  const _CycleCalendarWidget({required this.cycleDay});

  @override
  Widget build(BuildContext context) {
    final calData = HomeBackend.generateCycleCalendar(cycleDay);
    final phaseLabel = HomeBackend.getCyclePhaseLabel(cycleDay);
    final phaseColor = HomeBackend.getCyclePhaseColor(cycleDay);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "🗓 Your Cycle",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: phaseColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Day $cycleDay · $phaseLabel",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: phaseColor.withBlue(10),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Day-of-week headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                .map((d) => SizedBox(
                      width: 36,
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black38,
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 8),

          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 28,
            itemBuilder: (context, i) {
              final entry = calData[i];
              final isCurrent = entry['isCurrent'] as bool;
              final color = entry['color'] as Color;
              final day = entry['day'] as int;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isCurrent ? color : color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(color: color, width: 2.5)
                      : null,
                  boxShadow: isCurrent
                      ? [BoxShadow(color: color.withOpacity(0.45), blurRadius: 8)]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                      color: isCurrent ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          const _PhaseLegend(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  GLASS CARD HELPER
// ─────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;

  const _GlassCard({
    required this.child,
    this.padding,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.white.withOpacity(0.60),
            border: Border.all(color: Colors.white.withOpacity(0.55), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.07),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int selectedMood = 2;
  int navIndex = 0;
  int cycleDay = 12;

  final moods = MoodType.values;
  MoodType get mood => moods[selectedMood];

  final TextEditingController journalController = TextEditingController();
  late AnimationController _headerAnimController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _headerFade = CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOutCubic));

    _headerAnimController.forward();
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    journalController.dispose();
    super.dispose();
  }

  String _getMoodEmoji() {
    const emojis = ["🥺", "🌿", "😌", "💖", "⚡"];
    return emojis[selectedMood.clamp(0, 4)];
  }

  String _getMoodLabel() {
    const labels = ["Low", "Calm", "Okay", "Happy", "Energised"];
    return labels[selectedMood.clamp(0, 4)];
  }

  @override
  Widget build(BuildContext context) {
    final accent = MoodTheme.accent(mood);
    final bg = MoodTheme.background(mood);
    final affirmation = HomeBackend.getDailyAffirmation();
    final tip = HomeBackend.getDailyTip();
    final insight = HomeBackend.getMoodInsight(selectedMood);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ── ANIMATED PETAL BACKGROUND ──
          Positioned.fill(
            child: FloralParticleBackground(accentColor: accent),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── GREETING ──
                  FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Small-caps date line like screenshot
                              Text(
                                _formattedDate().toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: accent.withOpacity(0.85),
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Bold large greeting with leaf emoji
                              Row(
                                children: [
                                  Text(
                                    _greetingWord(),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1A1A2E),
                                      letterSpacing: -0.5,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text("🌿", style: TextStyle(fontSize: 22)),
                                ],
                              ),
                            ],
                          ),
                          // Emoji avatar circle — matches screenshot smiley face style
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: accent.withOpacity(0.30),
                                width: 1.5,
                              ),
                            ),
                            child: const Center(
                              child: Text("😊", style: TextStyle(fontSize: 22)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── AFFIRMATION HEADER CARD ──
                  FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: _buildAffirmationCard(accent, affirmation),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── MOOD PICKER ──
                  const Text(
                    "how are you feeling?",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (index) {
                        return AnimatedMoodFace(
                          moodIndex: index,
                          isSelected: selectedMood == index,
                          onTap: () => setState(() => selectedMood = index),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── TODAY'S INSIGHT (MOOD-AWARE) ──
                  _buildLabeledCard(
                    emoji: "🌿",
                    title: "today's insight",
                    content: insight,
                    accent: accent,
                  ),

                  const SizedBox(height: 16),

                  // ── CYCLE CALENDAR ──
                  _CycleCalendarWidget(cycleDay: cycleDay),

                  const SizedBox(height: 16),

                  // ── DAILY TIP ──
                  _buildLabeledCard(
                    emoji: "🌙",
                    title: "tip of the day",
                    content: tip,
                    accent: accent,
                  ),

                  const SizedBox(height: 16),

                  // ── JOURNAL ──
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text("📝", style: TextStyle(fontSize: 16)),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "journal",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: journalController,
                          maxLines: 4,
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: "write what you're feeling...",
                            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.65),
                            contentPadding: const EdgeInsets.all(14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            onPressed: () {
                              // TODO: save journal entry to backend
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Journal saved 💖"),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: accent,
                                ),
                              );
                              journalController.clear();
                            },
                            child: const Text(
                              "Save 💖",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── NAVBAR ──
      bottomNavigationBar: SheAnimatedNavBar(
        currentIndex: navIndex,
        onTap: (index) {
          setState(() => navIndex = index);
          switch (index) {
            case 1:
              Navigator.push(context, _route(const InsightsScreen()));
              break;
            case 2:
              Navigator.push(context, _route(const TrackScreen()));
              break;
            case 3:
              Navigator.push(context, _route(const LearnPage()));
              break;
            case 4:
              Navigator.push(context, _route(const HistoryScreen()));
              break;
          }
        },
      ),
    );
  }

  // ─── AFFIRMATION CARD ───────────────────────
  Widget _buildAffirmationCard(Color accent, String affirmation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row — "TODAY'S AFFIRMATION 🌙" in small teal caps
          Row(
            children: [
              Text(
                "TODAY'S AFFIRMATION",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 5),
              const Text("🌙", style: TextStyle(fontSize: 13)),
            ],
          ),

          const SizedBox(height: 14),

          // Italic serif bold quote with quotation marks — exactly like screenshot
          Text(
            '"$affirmation"',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              color: Color(0xFF1A1A2E),
              height: 1.38,
              letterSpacing: -0.3,
              fontFamily: 'Georgia',
            ),
          ),

          const SizedBox(height: 16),

          // Footer dot + text
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                "for your journey 🌿",
                style: TextStyle(
                  fontSize: 12,
                  color: accent.withOpacity(0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── LABELED INFO CARD ──────────────────────
  Widget _buildLabeledCard({
    required String emoji,
    required String title,
    required String content,
    required Color accent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label in teal small-caps + emoji — matches screenshot "🌿 INSIGHT FOR TODAY"
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF3A3A4A),
              height: 1.55,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ────────────────────────────────

  /// Just the greeting word, no emoji — emoji lives inline in the Row
  String _greetingWord() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  /// "SUNDAY, JUNE 14" style — matches screenshot exactly
  String _formattedDate() {
    final now = DateTime.now();
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, $month ${now.day}';
  }

  PageRoute _route(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
      );
}