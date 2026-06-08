import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'track_storage.dart';
import 'track_model.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  List<TrackEntry> entries = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final data = await TrackStorage.getEntries();
    setState(() {
      entries = data;
    });
  }

  List<FlSpot> getSpots() {
    return List.generate(entries.length, (index) {
      return FlSpot(index.toDouble(), entries[index].mood.toDouble());
    });
  }

  double getAverageMood() {
    if (entries.isEmpty) return 0;
    double sum = entries.fold(0, (a, b) => a + b.mood);
    return sum / entries.length;
  }

  String getInsight() {
    double avg = getAverageMood();

    if (avg >= 4) {
      return "You're in a stable & positive phase ✨";
    } else if (avg >= 3) {
      return "Mood is slightly fluctuating 🌿";
    } else {
      return "Your mood seems low recently 💭";
    }
  }

  String getTip() {
    double avg = getAverageMood();

    if (avg >= 4) {
      return "Keep doing what you're doing 💖 Stay hydrated & maintain routine.";
    } else if (avg >= 3) {
      return "Try light workouts, journaling & proper sleep 🧘‍♀️";
    } else {
      return "Focus on self-care, warm foods & reduce stress 🌸";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: const Text("Insights 💜"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: entries.isEmpty
          ? const Center(
              child: Text(
                "No data yet 🌿",
                style: TextStyle(fontSize: 16),
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFEDE7FF),
                    Color(0xFFD6CCFF),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🌸 TITLE
                    const Text(
                      "Your Mood Journey",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 📊 CHART CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SizedBox(
                        height: 220,
                        child: LineChart(
                          LineChartData(
                            minY: 1,
                            maxY: 5,

                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                            ),

                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.deepPurple,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      "D${value.toInt() + 1}",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.deepPurple,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            borderData: FlBorderData(show: false),

                            lineBarsData: [
                              LineChartBarData(
                                spots: getSpots(),
                                isCurved: true,
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.purple,
                                    Colors.deepPurple,
                                  ],
                                ),
                                barWidth: 4,
                                dotData: FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.purple.withOpacity(0.2),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// 🧠 INSIGHT CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome,
                              color: Colors.deepPurple),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              getInsight(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// 💡 TIP CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite,
                              color: Colors.pinkAccent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              getTip(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}