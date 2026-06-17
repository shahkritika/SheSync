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
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
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

  // ── Helpers ──
  String getMoodEmoji(int mood) {
    const moods = ["😢", "😐", "🙂", "😊", "😍"];
    return moods[mood];
  }

  String getMoodLabel(int mood) {
    const labels = ["Sad", "Meh", "Okay", "Good", "Great"];
    return labels[mood];
  }

  Color getMoodColor(int mood) {
    const colors = [
      Color(0xFFEF9A9A),
      Color(0xFFFFCC80),
      Color(0xFFFFF176),
      Color(0xFFA5D6A7),
      Color(0xFF80DEEA),
    ];
    return colors[mood];
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
      const months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
      const days = [
        "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
      ];
      return "${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}";
    } catch (_) {
      return dateStr.split(" ")[0];
    }
  }

  // ── Summary Stats ──
  Widget _buildSummaryCard() {
    if (entries.isEmpty) return const SizedBox();

    final avgMood = entries.map((e) => e.mood).reduce((a, b) => a + b) /
        entries.length;
    final avgCycleDay =
        entries.map((e) => e.cycleDay).reduce((a, b) => a + b) /
            entries.length;

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
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Overview 📊",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _statChip(
                label: "Total Entries",
                value: "${entries.length}",
                icon: Icons.calendar_month,
              ),
              const SizedBox(width: 10),
              _statChip(
                label: "Avg Mood",
                value: getMoodEmoji(avgMood.round()),
                icon: Icons.mood,
              ),
              const SizedBox(width: 10),
              _statChip(
                label: "Avg Cycle Day",
                value: avgCycleDay.toStringAsFixed(1),
                icon: Icons.loop,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Entry Card ──
  Widget _buildEntryCard(TrackEntry entry, int index) {
    final moodColor = getMoodColor(entry.mood);
    final phaseColor = getPhaseColor(entry.cycleDay);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
        children: [

          // ── Top Row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [

                // Mood circle
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: moodColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      getMoodEmoji(entry.mood),
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Date & mood label
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDate(entry.date),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: moodColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              getMoodLabel(entry.mood),
                              style: TextStyle(
                                fontSize: 11,
                                color: moodColor.darken(0.3),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: phaseColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              getPhase(entry.cycleDay),
                              style: TextStyle(
                                fontSize: 11,
                                color: phaseColor.darken(0.3),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Cycle day badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7ED6B2).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${entry.cycleDay}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D60),
                        ),
                      ),
                      const Text(
                        "day",
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF2E7D60),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──
          Divider(height: 1, color: Colors.grey.shade100),

          // ── Bottom Row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoChip(Icons.calendar_today, "Entry #${entries.length - entries.indexOf(entry)}", Colors.blue),
                _infoChip(Icons.access_time, _timeAgo(entry.date), Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withOpacity(0.7)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
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
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Your History 🌸",
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: accent),
            )
          : entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("🌿", style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      const Text(
                        "No entries yet",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF444444),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Start tracking your health today!",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: CustomScrollView(
                    slivers: [

                      // ── Summary ──
                      SliverToBoxAdapter(child: _buildSummaryCard()),

                      // ── Section title ──
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            children: [
                              const Text(
                                "Recent Entries",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7ED6B2).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${entries.length} total",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2E7D60),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Entries List ──
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _buildEntryCard(entries[index], index),
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

// ── Color extension helper ──
extension ColorBrightness on Color {
  Color darken(double amount) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}