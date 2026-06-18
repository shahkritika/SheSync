import 'package:flutter/material.dart';
import 'track_storage.dart';
import 'track_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  List<TrackEntry> entries = [];
  bool isLoading = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final accent = const Color(0xFF7ED6B2);
  final bg = const Color(0xFFF2FFFA);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    loadEntries();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void loadEntries() async {
    final data = await TrackStorage.getEntries();
    setState(() {
      entries = data.reversed.toList();
      isLoading = false;
    });
    _animController.forward();
  }

  String getMoodEmoji(int mood) {
    const moods = ["😢", "😐", "🙂", "😊", "😍"];
    return moods[mood.clamp(0, 4)];
  }

  String getMoodLabel(int mood) {
    const labels = ["Sad", "Meh", "Okay", "Good", "Great"];
    return labels[mood.clamp(0, 4)];
  }

  Color getMoodColor(int mood) {
    const colors = [
      Color(0xFFEF9A9A), Color(0xFFFFCC80),
      Color(0xFFFFF176), Color(0xFFA5D6A7), Color(0xFF80DEEA),
    ];
    return colors[mood.clamp(0, 4)];
  }

  String getFlowLabel(int flow) {
    const labels = ["None", "Spotting", "Light", "Medium", "Heavy"];
    return labels[flow.clamp(0, 4)];
  }

  Color getFlowColor(int flow) {
    const colors = [
      Colors.grey,
      Color(0xFFFFCDD2), Color(0xFFEF9A9A),
      Color(0xFFE57373), Color(0xFFC62828),
    ];
    return colors[flow.clamp(0, 4)];
  }

  String getPhase(int cycleDay) {
    if (cycleDay <= 5) return "🩸 Period";
    if (cycleDay <= 13) return "🌱 Follicular";
    if (cycleDay <= 16) return "🌟 Ovulation";
    return "🌙 Luteal";
  }

  Color getPhaseColor(int cycleDay) {
    if (cycleDay <= 5) return const Color(0xFFEF9A9A);
    if (cycleDay <= 13) return const Color(0xFFA5D6A7);
    if (cycleDay <= 16) return const Color(0xFFFFD54F);
    return const Color(0xFFCE93D8);
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
      const days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];
      return "${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}";
    } catch (_) {
      return dateStr.split(" ")[0];
    }
  }

  String _timeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inDays == 0) return "Today";
      if (diff.inDays == 1) return "Yesterday";
      if (diff.inDays < 7) return "${diff.inDays} days ago";
      if (diff.inDays < 30) return "${(diff.inDays / 7).floor()}w ago";
      return "${(diff.inDays / 30).floor()}mo ago";
    } catch (_) { return ""; }
  }

  // ── Summary Card ──
  Widget _buildSummaryCard() {
    if (entries.isEmpty) return const SizedBox();
    final avgMood = entries.map((e) => e.mood).reduce((a, b) => a + b) / entries.length;
    final avgCycleDay = entries.map((e) => e.cycleDay).reduce((a, b) => a + b) / entries.length;
    final avgWater = entries.map((e) => e.waterGlasses).reduce((a, b) => a + b) / entries.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, const Color(0xFFB2EED6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: accent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Your Overview 📊",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 14),
          Row(
            children: [
              _statChip("Entries", "${entries.length}"),
              const SizedBox(width: 8),
              _statChip("Avg Mood", getMoodEmoji(avgMood.round())),
              const SizedBox(width: 8),
              _statChip("Avg Day", avgCycleDay.toStringAsFixed(1)),
              const SizedBox(width: 8),
              _statChip("Avg Water", "${avgWater.toStringAsFixed(1)}🥤"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // ── Detail Row ──
  Widget _detailRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Text("$label: ", style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 12, color: Color(0xFF333333), fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  // ── Entry Card ──
  Widget _buildEntryCard(TrackEntry entry, int index) {
    final moodColor = getMoodColor(entry.mood);
    final phaseColor = getPhaseColor(entry.cycleDay);
    final flowColor = getFlowColor(entry.flow);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: moodColor.withOpacity(0.3), shape: BoxShape.circle),
                  child: Center(child: Text(getMoodEmoji(entry.mood), style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(formatDate(entry.date),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF333333))),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _miniChip(getMoodLabel(entry.mood), moodColor),
                          const SizedBox(width: 4),
                          _miniChip(getPhase(entry.cycleDay), phaseColor),
                          const SizedBox(width: 4),
                          _miniChip(_timeAgo(entry.date), Colors.blue.shade300),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text("${entry.cycleDay}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D60))),
                      const Text("day", style: TextStyle(fontSize: 10, color: Color(0xFF2E7D60))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade100),

          // ── Details ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Row 1: Flow + Water
                Row(
                  children: [
                    Expanded(child: _detailRow(Icons.water_drop, "Flow", getFlowLabel(entry.flow), flowColor)),
                    const SizedBox(width: 12),
                    Expanded(child: _detailRow(Icons.local_drink, "Water", "${entry.waterGlasses}/8 glasses", Colors.blue.shade400)),
                  ],
                ),

                // Row 2: Sleep + Exercise
                Row(
                  children: [
                    Expanded(child: _detailRow(Icons.bedtime, "Sleep", "${entry.sleepHours.toStringAsFixed(1)} hrs", const Color(0xFF7B61FF))),
                    const SizedBox(width: 12),
                    Expanded(child: _detailRow(Icons.directions_run, "Exercise", entry.exercise, Colors.orange.shade400)),
                  ],
                ),

                // Row 3: Diet + Medication
                Row(
                  children: [
                    Expanded(child: _detailRow(Icons.restaurant, "Diet", entry.diet, Colors.green.shade400)),
                    const SizedBox(width: 12),
                    Expanded(child: _detailRow(
                      Icons.medication,
                      "Meds",
                      entry.tookMedication ? "✅ Taken" : "❌ Skipped",
                      entry.tookMedication ? Colors.green.shade400 : Colors.red.shade300,
                    )),
                  ],
                ),

                // Temperature (if entered)
                if (entry.temperature.isNotEmpty)
                  _detailRow(Icons.thermostat, "Temp", "${entry.temperature}°C", Colors.orange.shade300),

                // Symptoms
                if (entry.symptoms.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.sick_outlined, size: 14, color: Colors.red.shade400),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Symptoms:",
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: entry.symptoms.map((s) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade100),
                                ),
                                child: Text(s, style: TextStyle(fontSize: 10, color: Colors.red.shade400)),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                // Notes
                if (entry.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notes, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(entry.notes,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color.darken(0.2), fontWeight: FontWeight.w600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text("Your History 🌸",
            style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold, fontSize: 18)),
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accent),
            onPressed: () {
              setState(() => isLoading = true);
              loadEntries();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: accent))
          : entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("🌿", style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      const Text("No entries yet",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF444444))),
                      const SizedBox(height: 8),
                      Text("Start tracking your health today!",
                          style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildSummaryCard()),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            children: [
                              const Text("Recent Entries",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text("${entries.length} total",
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D60), fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildEntryCard(entries[index], index),
                            childCount: entries.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

extension ColorBrightness on Color {
  Color darken(double amount) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}