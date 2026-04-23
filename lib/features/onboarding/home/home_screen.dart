import 'package:flutter/material.dart';
import '../../core/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedMood = 0;

  final moods = ["😢", "😐", "🙂", "😊", "😍"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SheSync 🌸"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // GREETING
            const Text(
              "Hello 🌸",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "How are you feeling today?",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            // MOOD TRACKER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(moods.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMood = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selectedMood == index
                          ? AppColors.accent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      moods[index],
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            // DAILY INSIGHT CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "🌿 Today’s Insight:\nYour energy may be lower today. Try light movement and hydration.",
                style: TextStyle(fontSize: 15),
              ),
            ),

            const SizedBox(height: 20),

            // CYCLE STATUS CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "🩸 Cycle Day: 12\nLuteal Phase",
                style: TextStyle(fontSize: 15),
              ),
            ),

            const SizedBox(height: 20),

            // QUICK ACTIONS
            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                children: const [
                  _ActionCard(title: "Track Mood", icon: "😊"),
                  _ActionCard(title: "Cycle", icon: "🩸"),
                  _ActionCard(title: "Journal", icon: "📖"),
                  _ActionCard(title: "Tips", icon: "🌿"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// QUICK ACTION WIDGET
class _ActionCard extends StatelessWidget {
  final String title;
  final String icon;

  const _ActionCard({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              icon,
              style: const TextStyle(fontSize: 28),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}