import 'package:flutter/material.dart';
import '../../core/colors.dart';
import 'track_model.dart';
import 'track_storage.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen>
    with SingleTickerProviderStateMixin {
  // ── Mood ──
  int selectedMood = 2;
  final moods = ["😢", "😐", "🙂", "😊", "😍"];
  final moodLabels = ["Sad", "Meh", "Okay", "Good", "Great"];

  // ── Cycle ──
  int cycleDay = 1;

  // ── Flow ──
  int selectedFlow = 0;
  final flows = ["None", "Spotting", "Light", "Medium", "Heavy"];
  final flowColors = [
    Colors.grey,
    Color(0xFFFFCDD2),
    Color(0xFFEF9A9A),
    Color(0xFFE57373),
    Color(0xFFC62828),
  ];

  // ── Symptoms ──
  final symptoms = [
    "🤕 Cramps",
    "🫠 Bloating",
    "🤯 Headache",
    "😤 Acne",
    "😴 Fatigue",
    "😤 Mood Swings",
    "🔙 Back Pain",
    "🤢 Nausea",
    "🥵 Hot Flashes",
    "💧 Discharge",
  ];
  final Set<String> selectedSymptoms = {};

  // ── Water ──
  int waterGlasses = 0;

  // ── Sleep ──
  double sleepHours = 7;

  // ── Exercise ──
  String selectedExercise = "Rest";
  final exercises = ["Rest 🛋️", "Walk 🚶", "Yoga 🧘", "Gym 🏋️", "Run 🏃"];

  // ── Diet ──
  String selectedDiet = "Moderate";
  final diets = ["Healthy 🥗", "Moderate 🍱", "Unhealthy 🍔"];

  // ── Temperature ──
  final tempController = TextEditingController();

  // ── Notes ──
  final notesController = TextEditingController();

  // ── Medication ──
  bool tookMedication = false;

  // ── Animation ──
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    tempController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void saveEntry() async {
    final entry = TrackEntry(
      date: DateTime.now().toString(),
      mood: selectedMood,
      cycleDay: cycleDay,
    );

    await TrackStorage.saveEntry(entry);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🌸", style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text(
                "Entry Saved!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your health data for today has been recorded.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7ED6B2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 44),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Done",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Reusable Section Card ──
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF444444),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF7ED6B2);
    final bg = const Color(0xFFF2FFFA);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Track Today 🌸",
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: saveEntry,
              child: Text(
                "Save",
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Date Header ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, const Color(0xFFB2EED6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      _formatDate(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Day $cycleDay",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Mood ──
              _sectionCard(
                title: "How do you feel today? 💭",
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(moods.length, (i) {
                        final selected = selectedMood == i;
                        return GestureDetector(
                          onTap: () => setState(() => selectedMood = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? accent.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected ? accent : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  moods[i],
                                  style: TextStyle(
                                    fontSize: selected ? 32 : 26,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  moodLabels[i],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: selected ? accent : Colors.grey,
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // ── Cycle Day ──
              _sectionCard(
                title: "Cycle Day 📅",
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Day $cycleDay",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                        Text(
                          cycleDay <= 5
                              ? "🩸 Period Phase"
                              : cycleDay <= 13
                                  ? "🌱 Follicular Phase"
                                  : cycleDay <= 16
                                      ? "🌟 Ovulation Phase"
                                      : "🌙 Luteal Phase",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: accent,
                        inactiveTrackColor: accent.withOpacity(0.2),
                        thumbColor: accent,
                        overlayColor: accent.withOpacity(0.1),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: cycleDay.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        onChanged: (val) =>
                            setState(() => cycleDay = val.toInt()),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("1", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text("30", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Flow Intensity ──
              _sectionCard(
                title: "Flow Intensity 🩸",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(flows.length, (i) {
                    final selected = selectedFlow == i;
                    return GestureDetector(
                      onTap: () => setState(() => selectedFlow = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? flowColors[i].withOpacity(0.2)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? flowColors[i] : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.water_drop,
                              color: selected ? flowColors[i] : Colors.grey.shade400,
                              size: selected ? 22 : 18,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              flows[i],
                              style: TextStyle(
                                fontSize: 10,
                                color: selected
                                    ? flowColors[i]
                                    : Colors.grey,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // ── Symptoms ──
              _sectionCard(
                title: "Symptoms Today 🤒",
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: symptoms.map((s) {
                    final selected = selectedSymptoms.contains(s);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selected) {
                            selectedSymptoms.remove(s);
                          } else {
                            selectedSymptoms.add(s);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? accent.withOpacity(0.15)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? accent : Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            fontSize: 12,
                            color: selected ? const Color(0xFF2E7D60) : Colors.grey.shade700,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ── Water Intake ──
              _sectionCard(
                title: "Water Intake 💧",
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$waterGlasses",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "/ 8 glasses",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(8, (i) {
                        return GestureDetector(
                          onTap: () =>
                              setState(() => waterGlasses = i + 1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            child: Icon(
                              Icons.local_drink,
                              size: 30,
                              color: i < waterGlasses
                                  ? const Color(0xFF29B6F6)
                                  : Colors.grey.shade300,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      waterGlasses >= 8
                          ? "🎉 Goal reached!"
                          : "${8 - waterGlasses} more to go",
                      style: TextStyle(
                        color: waterGlasses >= 8
                            ? const Color(0xFF2E7D60)
                            : Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Sleep ──
              _sectionCard(
                title: "Sleep Hours 😴",
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${sleepHours.toStringAsFixed(1)} hrs",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF7B61FF),
                          ),
                        ),
                        Text(
                          sleepHours < 6
                              ? "😴 Too little"
                              : sleepHours <= 9
                                  ? "✅ Well rested"
                                  : "😪 Oversleeping",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF7B61FF),
                        inactiveTrackColor:
                            const Color(0xFF7B61FF).withOpacity(0.2),
                        thumbColor: const Color(0xFF7B61FF),
                        overlayColor:
                            const Color(0xFF7B61FF).withOpacity(0.1),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: sleepHours,
                        min: 0,
                        max: 12,
                        divisions: 24,
                        onChanged: (val) =>
                            setState(() => sleepHours = val),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("0h", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text("12h", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Exercise ──
              _sectionCard(
                title: "Exercise Today 🏃",
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: exercises.map((e) {
                    final selected = selectedExercise == e;
                    return GestureDetector(
                      onTap: () => setState(() => selectedExercise = e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFFF7043).withOpacity(0.15)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFFFF7043)
                                : Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          e,
                          style: TextStyle(
                            fontSize: 13,
                            color: selected
                                ? const Color(0xFFBF360C)
                                : Colors.grey.shade700,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ── Diet ──
              _sectionCard(
                title: "Diet Today 🍎",
                child: Row(
                  children: diets.map((d) {
                    final selected = selectedDiet == d;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedDiet = d),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? accent.withOpacity(0.15)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected ? accent : Colors.grey.shade200,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            d,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: selected
                                  ? const Color(0xFF2E7D60)
                                  : Colors.grey.shade600,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ── Body Temperature ──
              _sectionCard(
                title: "Body Temperature 🌡️",
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tempController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: "e.g. 36.6",
                          hintStyle:
                              TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          suffixText: "°C",
                          suffixStyle: TextStyle(color: accent),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECB3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text("🌡️", style: TextStyle(fontSize: 24)),
                    ),
                  ],
                ),
              ),

              // ── Medication ──
              _sectionCard(
                title: "Medication / Supplement 💊",
                child: GestureDetector(
                  onTap: () =>
                      setState(() => tookMedication = !tookMedication),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tookMedication
                          ? accent.withOpacity(0.12)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            tookMedication ? accent : Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color:
                                tookMedication ? accent : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: tookMedication
                                  ? accent
                                  : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: tookMedication
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 18)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          tookMedication
                              ? "✅ Taken today!"
                              : "Did you take your medication?",
                          style: TextStyle(
                            color: tookMedication
                                ? const Color(0xFF2E7D60)
                                : Colors.grey.shade600,
                            fontWeight: tookMedication
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Notes ──
              _sectionCard(
                title: "Personal Notes 📝",
                child: TextField(
                  controller: notesController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText:
                        "How was your day? Any other symptoms or thoughts...",
                    hintStyle:
                        TextStyle(color: Colors.grey.shade400, fontSize: 13),
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
                      borderSide: BorderSide(color: accent),
                    ),
                  ),
                ),
              ),

              // ── Save Button ──
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: saveEntry,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_alt, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Save Today's Entry",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    const days = [
      "Monday", "Tuesday", "Wednesday",
      "Thursday", "Friday", "Saturday", "Sunday"
    ];
    return "${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}";
  }
}