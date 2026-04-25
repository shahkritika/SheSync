import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Insights 📊")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: entries.isEmpty
            ? const Center(child: Text("No data yet 🌿"))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Mood Trend",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(show: true),
                        borderData: FlBorderData(show: true),

                        lineBarsData: [
                          LineChartBarData(
                            spots: getSpots(),
                            isCurved: true,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "🌿 Insight: Your mood trends help understand your hormonal patterns.",
                  ),
                ],
              ),
      ),
    );
  }
}