import 'package:flutter/material.dart';
import '../../core/colors.dart';
import 'track_storage.dart';
import 'track_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<TrackEntry> entries = [];

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  void loadEntries() async {
    final data = await TrackStorage.getEntries();
    setState(() {
      entries = data.reversed.toList(); // latest first
    });
  }

  String getMoodEmoji(int mood) {
    const moods = ["😢", "😐", "🙂", "😊", "😍"];
    return moods[mood];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your History 🌸")),
      body: entries.isEmpty
          ? const Center(child: Text("No entries yet 🌿"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];

                return Card(
                  color: AppColors.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Text(
                      getMoodEmoji(entry.mood),
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text("Cycle Day: ${entry.cycleDay}"),
                    subtitle: Text(entry.date.split(" ")[0]),
                  ),
                );
              },
            ),
    );
  }
}