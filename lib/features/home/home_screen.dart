import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
//  JOURNAL ENTRY MODEL
// ─────────────────────────────────────────────
class JournalEntry {
  final String text;
  final String date;
  final int mood;

  JournalEntry({required this.text, required this.date, required this.mood});

  Map<String, dynamic> toJson() => {'text': text, 'date': date, 'mood': mood};

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        text: json['text'] ?? '',
        date: json['date'] ?? '',
        mood: json['mood'] ?? 2,
      );
}

// ─────────────────────────────────────────────
//  JOURNAL STORAGE
// ─────────────────────────────────────────────
class JournalStorage {
  static Future<String> _getKey() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('cached_username') ?? 'guest';
    return 'journals_$username';
  }

  static Future<void> saveEntry(JournalEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();
    final existing = prefs.getStringList(key) ?? [];
    existing.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(key, existing);
  }

  static Future<List<JournalEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();
    final data = prefs.getStringList(key) ?? [];
    return data
        .map((e) => JournalEntry.fromJson(jsonDecode(e)))
        .toList()
        .reversed
        .toList();
  }

  static Future<void> deleteEntry(int reversedIndex, int totalCount) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();
    final existing = prefs.getStringList(key) ?? [];
    final actualIndex = totalCount - 1 - reversedIndex;
    if (actualIndex >= 0 && actualIndex < existing.length) {
      existing.removeAt(actualIndex);
      await prefs.setStringList(key, existing);
    }
  }
}

// ─────────────────────────────────────────────
//  HOME BACKEND
// ─────────────────────────────────────────────
class HomeBackend {
  static const List<String> _affirmations = [
    "You are allowed to rest and still be worthy 💖",
    "Your body is not against you, it's communicating 🌸",
    "Slow progress is still progress 🌿",
    "You are doing better than you think ✨",
    "Healing is not linear, and that's okay 💭",
    "You deserve softness, especially from yourself 🫶",
    "Your hormones don't define your worth 🌙",
    "Every small step forward is still movement 🌷",
    "Breathe. You are exactly where you need to be 🍃",
    "Nourishing yourself is an act of love 💐",
    "You are more resilient than you realise 🌺",
    "It's okay to feel everything you're feeling 🌊",
    "Your softness is your superpower 🦋",
    "Rest is productive. Sleep is sacred 🌙",
    "Today, choose one kind thought about yourself 🌸",
    "You don't need to earn your own compassion 💗",
    "Your cycle is wisdom, not weakness 🌙",
    "Tiny acts of care add up to transformation ✨",
    "You are worthy of peace, today and every day 🕊️",
    "Let yourself bloom at your own pace 🌻",
    "Your feelings are valid. Always 💜",
    "Give yourself the grace you'd give a friend 🌷",
    "You carry so much — put something down today 🍃",
    "Even cloudy days are part of your journey ☁️",
    "You are not behind. You are on your own path 🌿",
    "Today, one glass of water is enough love 💧",
    "Your presence in this world matters 🌸",
    "Rest without guilt. You've earned it 🫶",
    "You are in progress — beautifully so 💫",
    "Your body listens to every word you think 🌙",
    "End this month knowing you showed up for you 💖",
  ];

  static const List<String> _tips = [
    "Sip warm water with lemon first thing to ease bloating 🍋",
    "A 10-minute walk can lift your mood as much as a workout 🚶‍♀️",
    "Magnesium-rich foods like dark chocolate ease cramps 🍫",
    "Journaling for 5 mins before bed reduces cortisol 📓",
    "Cold water on your wrists can calm anxiety fast 💧",
    "Seed cycling may help balance hormones naturally 🌱",
    "Gentle yoga twists support lymphatic drainage 🧘‍♀️",
    "Eating iron-rich foods like lentils replenishes after your period 🫘",
    "Blue light from screens can disrupt your cycle — try night mode 🌙",
    "Deep belly breathing activates your rest-and-digest system 🍃",
    "Castor oil packs on your lower belly may ease period pain 🌿",
    "Your skin may glow during ovulation — moisturise and enjoy it 🌷",
    "Avoid skipping meals during the luteal phase 🍽️",
    "Chamomile tea before bed helps with cycle-related insomnia 🌼",
    "Acupressure on the inner ankle can relieve cramps ✨",
    "Dark leafy greens = folate + iron. Your best friends this week 🥬",
    "Wearing cosy socks keeps your uterus warm and happy 🧦",
    "Omega-3s from flaxseed or walnuts reduce inflammation 🌰",
    "A hot water bottle on your lower back works wonders 🔥",
    "Limit caffeine during your luteal phase ☕",
    "Turmeric latte has anti-inflammatory magic for period cramps 🌙",
    "Stretch your hip flexors today — they hold so much tension 🌸",
    "Zinc from pumpkin seeds supports healthy progesterone 🎃",
    "Your energy is cyclical — plan your week around it 📅",
    "A foot massage can help redirect cramp pain 💆‍♀️",
    "Drinking raspberry leaf tea may ease cramping over time 🍵",
    "Your mood shifts are hormonal, not personal flaws 💜",
    "Vitamin D from sunlight supports hormone production ☀️",
    "Eat enough protein — it's essential for hormone building blocks 🥚",
    "Tracking your cycle = knowing yourself better every month 📊",
    "You made it through this month. Celebrate yourself 🌸",
  ];

  static const List<String> _moodInsights = [
    "Low energy days are valid rest days — your body is working hard even when you can't feel it 🌙",
    "Your calm today might be before a surge of creativity — honour both 🌿",
    "Feeling balanced is a gift. Notice what you did today to get here ✨",
    "Your joy today is real and earned 💖",
    "Channel that electric energy into something creative — your peak window is open ⚡",
  ];

  static String getDailyAffirmation() {
    final day = DateTime.now().day;
    return _affirmations[(day - 1).clamp(0, 30)];
  }

  static String getDailyTip() {
    final day = DateTime.now().day;
    return _tips[(day - 1).clamp(0, 30)];
  }

  static String getMoodInsight(int moodIndex) {
    return _moodInsights[moodIndex.clamp(0, 4)];
  }

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

  // ── Compute current cycle day from lastPeriodDate + cycleLength ──
  static int computeCycleDay({
    required String? lastPeriodStartDate,
    required int cycleLength,
  }) {
    if (lastPeriodStartDate == null) return 1;
    try {
      final last = DateTime.parse(lastPeriodStartDate);
      final today = DateTime.now();
      final diff = today.difference(last).inDays;
      if (diff < 0) return 1;
      return (diff % cycleLength) + 1;
    } catch (_) {
      return 1;
    }
  }
}

// ─────────────────────────────────────────────
//  ANIMATED PETAL BACKGROUND
// ─────────────────────────────────────────────
class _Petal {
  double x, y, size, speed, angle, drift, opacity;
  String emoji;
  _Petal({required this.x, required this.y, required this.size,
      required this.speed, required this.angle, required this.drift,
      required this.opacity, required this.emoji});
}

class _FloralBg extends StatefulWidget {
  const _FloralBg();
  @override
  State<_FloralBg> createState() => _FloralBgState();
}

class _FloralBgState extends State<_FloralBg> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<_Petal> _petals = [];
  final _rand = Random();
  final _emojis = ['🌸', '🌺', '🌷', '✿', '🌼'];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 14; i++) {
      _petals.add(_Petal(
        x: _rand.nextDouble(), y: _rand.nextDouble(),
        size: 12 + _rand.nextDouble() * 14,
        speed: 0.0002 + _rand.nextDouble() * 0.0004,
        angle: _rand.nextDouble() * 2 * pi,
        drift: (_rand.nextDouble() - 0.5) * 0.0008,
        opacity: 0.08 + _rand.nextDouble() * 0.14,
        emoji: _emojis[_rand.nextInt(_emojis.length)],
      ));
    }
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(() {
        setState(() {
          for (final p in _petals) {
            p.y += p.speed; p.x += p.drift; p.angle += 0.004;
            if (p.y > 1.1) { p.y = -0.05; p.x = _rand.nextDouble(); }
            if (p.x > 1.1) p.x = -0.05;
            if (p.x < -0.1) p.x = 1.05;
          }
        });
      })
      ..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      return Stack(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFFF0FFF8), Color(0xFFFDF6F9), Color(0xFFF2FFFA)],
            ),
          ),
        ),
        ..._petals.map((p) => Positioned(
          left: p.x * c.maxWidth, top: p.y * c.maxHeight,
          child: Transform.rotate(angle: p.angle,
            child: Opacity(opacity: p.opacity,
              child: Text(p.emoji, style: TextStyle(fontSize: p.size)))),
        )),
      ]);
    });
  }
}

// ─────────────────────────────────────────────
//  CYCLE CALENDAR
// ─────────────────────────────────────────────
class _CycleCalendar extends StatelessWidget {
  final int cycleDay;
  final int cycleLength;

  const _CycleCalendar({required this.cycleDay, required this.cycleLength});

  Color _phaseColor(int day) {
    if (day <= 5) return const Color(0xFFEF9A9A);
    if (day <= 13) return const Color(0xFF81C784);
    if (day <= 16) return const Color(0xFFFFD54F);
    return const Color(0xFFCE93D8);
  }

  @override
  Widget build(BuildContext context) {
    final phaseLabel = HomeBackend.getCyclePhaseLabel(cycleDay);
    final phaseColor = HomeBackend.getCyclePhaseColor(cycleDay);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("🗓 Your Cycle",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: phaseColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("Day $cycleDay · $phaseLabel",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: phaseColor.darken(0.25))),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mo','Tu','We','Th','Fr','Sa','Su'].map((d) =>
              SizedBox(width: 36,
                child: Text(d, textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black38)))).toList(),
          ),

          const SizedBox(height: 8),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, childAspectRatio: 1, mainAxisSpacing: 4, crossAxisSpacing: 4),
            itemCount: cycleLength,
            itemBuilder: (context, i) {
              final day = i + 1;
              final isCurrent = day == cycleDay;
              final color = _phaseColor(day);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isCurrent ? color : color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: isCurrent ? Border.all(color: color, width: 2.5) : null,
                  boxShadow: isCurrent ? [BoxShadow(color: color.withOpacity(0.45), blurRadius: 8)] : null,
                ),
                child: Center(child: Text('$day',
                    style: TextStyle(
                        fontSize: day > 9 ? 10 : 12,
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                        color: isCurrent ? Colors.white : Colors.black54))),
              );
            },
          ),

          const SizedBox(height: 12),

          // Phase legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _legendDot("Period", const Color(0xFFEF9A9A)),
              _legendDot("Follicular", const Color(0xFF81C784)),
              _legendDot("Ovulation", const Color(0xFFFFD54F)),
              _legendDot("Luteal", const Color(0xFFCE93D8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 9, color: Colors.black45, fontWeight: FontWeight.w500)),
    ]);
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
  int cycleDay = 1;
  int cycleLength = 28;
  String? username;

  final moods = ["😢", "😐", "😌", "💖", "⚡"];
  final moodLabels = ["Low", "Calm", "Okay", "Happy", "Energised"];
  final moodColors = [
    Color(0xFFEF9A9A), Color(0xFFB0BEC5), Color(0xFF81C784),
    Color(0xFFF48FB1), Color(0xFFFFD54F),
  ];

  final TextEditingController journalController = TextEditingController();
  List<JournalEntry> journals = [];
  bool journalsExpanded = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const Color accent = Color(0xFF7ED6B2);
  static const Color bg = Color(0xFFF2FFFA);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _loadAll();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    journalController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadProfile(), _loadJournals()]);
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final uname = prefs.getString('cached_username');

    // Try to get profile data from ProfileService / SharedPreferences
    // These keys match what ProfileService saves
    final lastPeriod = prefs.getString('last_period_start_date');
    final cl = prefs.getInt('average_cycle_length') ?? 28;

    // Compute cycle day from last period date
    final computed = HomeBackend.computeCycleDay(
      lastPeriodStartDate: lastPeriod,
      cycleLength: cl,
    );

    if (!mounted) return;
    setState(() {
      username = uname;
      cycleLength = cl;
      cycleDay = computed;
    });
  }

  Future<void> _loadJournals() async {
    final data = await JournalStorage.getEntries();
    if (!mounted) return;
    setState(() => journals = data);
  }

  Future<void> _saveJournal() async {
    final text = journalController.text.trim();
    if (text.isEmpty) return;

    final entry = JournalEntry(
      text: text,
      date: DateTime.now().toString(),
      mood: selectedMood,
    );
    await JournalStorage.saveEntry(entry);
    journalController.clear();
    await _loadJournals();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Journal saved 💖"),
        backgroundColor: accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return "Good morning";
    if (h < 17) return "Good afternoon";
    return "Good evening";
  }

  String _formattedDate() {
    final now = DateTime.now();
    const weekdays = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    const months = ['January','February','March','April','May','June',
        'July','August','September','October','November','December'];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  String _formatJournalDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final time = '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
      return '${d.day} ${months[d.month-1]} ${d.year} · $time';
    } catch (_) { return dateStr; }
  }

  @override
  Widget build(BuildContext context) {
    final affirmation = HomeBackend.getDailyAffirmation();
    final tip = HomeBackend.getDailyTip();
    final insight = HomeBackend.getMoodInsight(selectedMood);
    final phaseColor = HomeBackend.getCyclePhaseColor(cycleDay);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          const Positioned.fill(child: _FloralBg()),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── GREETING HEADER ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_formattedDate().toUpperCase(),
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                                    color: accent, letterSpacing: 1.4)),
                            const SizedBox(height: 4),
                            Text("${_greeting()}${username != null ? ', $username' : ''} 🌿",
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                                    color: Color(0xFF1A1A2E), letterSpacing: -0.5)),
                          ],
                        ),
                        Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: accent.withOpacity(0.3), width: 1.5),
                          ),
                          child: Center(child: Text(moods[selectedMood], style: const TextStyle(fontSize: 22))),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ── PHASE BANNER ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: phaseColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: phaseColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 10, color: phaseColor),
                          const SizedBox(width: 8),
                          Text("Currently in: ${HomeBackend.getCyclePhaseLabel(cycleDay)}",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                  color: phaseColor.darken(0.3))),
                          const Spacer(),
                          Text("Day $cycleDay of $cycleLength",
                              style: TextStyle(fontSize: 12, color: phaseColor.darken(0.2),
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── AFFIRMATION CARD ──
                    _buildInfoCard(
                      label: "TODAY'S AFFIRMATION 🌙",
                      content: '"$affirmation"',
                      isQuote: true,
                    ),

                    const SizedBox(height: 14),

                    // ── MOOD PICKER ──
                    _buildSection("How are you feeling? 💭",
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(5, (i) {
                          final selected = selectedMood == i;
                          return GestureDetector(
                            onTap: () => setState(() => selectedMood = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: selected ? moodColors[i].withOpacity(0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: selected ? moodColors[i] : Colors.transparent, width: 2),
                              ),
                              child: Column(children: [
                                Text(moods[i], style: TextStyle(fontSize: selected ? 30 : 24)),
                                const SizedBox(height: 4),
                                Text(moodLabels[i],
                                    style: TextStyle(fontSize: 10,
                                        color: selected ? moodColors[i].darken(0.2) : Colors.grey,
                                        fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                              ]),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── MOOD INSIGHT ──
                    _buildInfoCard(label: "🌿 INSIGHT FOR TODAY", content: insight),

                    const SizedBox(height: 14),

                    // ── CYCLE CALENDAR ──
                    _CycleCalendar(cycleDay: cycleDay, cycleLength: cycleLength),

                    const SizedBox(height: 14),

                    // ── TIP OF THE DAY ──
                    _buildInfoCard(label: "🌙 TIP OF THE DAY", content: tip),

                    const SizedBox(height: 14),

                    // ── JOURNAL WRITE ──
                    _buildSection("Journal 📝",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: journalController,
                            maxLines: 4,
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: "Write what you're feeling...",
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.all(14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: accent),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Mood: ${moods[selectedMood]} ${moodLabels[selectedMood]}",
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                onPressed: _saveJournal,
                                child: const Text("Save 💖",
                                    style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── PAST JOURNALS ──
                    if (journals.isNotEmpty) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.88),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.07), blurRadius: 16, offset: const Offset(0,4))],
                        ),
                        child: Column(
                          children: [
                            // Header toggle
                            InkWell(
                              onTap: () => setState(() => journalsExpanded = !journalsExpanded),
                              borderRadius: BorderRadius.circular(22),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: accent.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text("📖", style: TextStyle(fontSize: 16)),
                                    ),
                                    const SizedBox(width: 10),
                                    Text("Past Journals (${journals.length})",
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                                            color: Color(0xFF1A1A2E))),
                                    const Spacer(),
                                    Icon(journalsExpanded ? Icons.expand_less : Icons.expand_more,
                                        color: Colors.grey.shade400),
                                  ],
                                ),
                              ),
                            ),

                            // Journal list
                            if (journalsExpanded) ...[
                              Divider(height: 1, color: Colors.grey.shade100),
                              ...journals.take(journalsExpanded ? journals.length : 3).map((j) {
                                final idx = journals.indexOf(j);
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Mood bubble
                                          Container(
                                            width: 36, height: 36,
                                            decoration: BoxDecoration(
                                              color: moodColors[j.mood.clamp(0,4)].withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(child: Text(moods[j.mood.clamp(0,4)],
                                                style: const TextStyle(fontSize: 16))),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(_formatJournalDate(j.date),
                                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                                const SizedBox(height: 4),
                                                Text(j.text,
                                                    style: const TextStyle(fontSize: 13, color: Color(0xFF333333), height: 1.4)),
                                              ],
                                            ),
                                          ),
                                          // Delete button
                                          GestureDetector(
                                            onTap: () async {
                                              await JournalStorage.deleteEntry(idx, journals.length);
                                              await _loadJournals();
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 8),
                                              child: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade300),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (idx < journals.length - 1)
                                      Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade100),
                                  ],
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Card ──
  Widget _buildInfoCard({required String label, required String content, bool isQuote = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.07), blurRadius: 16, offset: const Offset(0,4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                  color: accent, letterSpacing: 1.3)),
          const SizedBox(height: 10),
          Text(content,
              style: TextStyle(
                fontSize: isQuote ? 17 : 14,
                fontWeight: isQuote ? FontWeight.w700 : FontWeight.w400,
                fontStyle: isQuote ? FontStyle.italic : FontStyle.normal,
                color: const Color(0xFF2A2A3A),
                height: 1.5,
              )),
        ],
      ),
    );
  }

  // ── Section Card ──
  Widget _buildSection(String title, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.07), blurRadius: 16, offset: const Offset(0,4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Color extension ──
extension _ColorX on Color {
  Color darken(double amount) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}