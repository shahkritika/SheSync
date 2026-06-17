import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/user_storage.dart';
import '../home/home_screen.dart';
import '../shell/main_shell.dart';
import '../login_screen.dart';


class OnboardingForm extends StatefulWidget {
  const OnboardingForm({super.key});

  @override
  State<OnboardingForm> createState() => _OnboardingFormState();
}

class _OnboardingFormState extends State<OnboardingForm> {
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  List<String> goals = [];
  final goalOptions = [
    "Balance Mood",
    "Track Cycle",
    "Improve Energy",
    "Reduce Symptoms",
  ];

  void toggleGoal(String goal) {
    setState(() {
      if (goals.contains(goal)) {
        goals.remove(goal);
      } else {
        goals.add(goal);
      }
    });
  }

  Future<void> saveData() async {
    final data = {
      "age": ageController.text,
      "height": heightController.text,
      "weight": weightController.text,
      "goals": goals,
    };

    await UserStorage.saveUser(data);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tell us about you 🌸")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            _buildField("Age", ageController),
            _buildField("Height (cm)", heightController),
            _buildField("Weight (kg)", weightController),

            const SizedBox(height: 20),

            const Text(
              "Your Goals",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Wrap(
              spacing: 10,
              children: goalOptions.map((goal) {
                final selected = goals.contains(goal);
                return FilterChip(
                  label: Text(goal),
                  selected: selected,
                  onSelected: (_) => toggleGoal(goal),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: saveData,
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}