import 'package:flutter/material.dart';
import '../../core/colors.dart';
import 'track_model.dart';
import 'track_storage.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  int selectedMood = 2;
  int cycleDay = 1;

  final moods = ["😢", "😐", "🙂", "😊", "😍"];

  void saveEntry() async {
    final entry = TrackEntry(
      date: DateTime.now().toString(),
      mood: selectedMood,
      cycleDay: cycleDay,
    );

    await TrackStorage.saveEntry(entry);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saved 🌸")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Track Today 🌸")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text("How do you feel today?"),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(moods.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMood = index;
                    });
                  },
                  child: Text(
                    moods[index],
                    style: TextStyle(
                      fontSize: 28,
                      color: selectedMood == index
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            const Text("Cycle Day"),

            Slider(
              value: cycleDay.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              label: cycleDay.toString(),
              onChanged: (value) {
                setState(() {
                  cycleDay = value.toInt();
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: saveEntry,
              child: const Text("Save Entry"),
            )
          ],
        ),
      ),
    );
  }
}