import 'package:flutter/material.dart';
import 'widgets/learn_card.dart';
import 'widgets/story_widget.dart';
import 'learn_chatbot.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final PageController controller = PageController();
  int current = 0;

  final Color bg = const Color(0xFFF2FFFA);
  final Color accent = const Color(0xFF7ED6B2);

  int selectedIndex = 0;

  final List<String> categories = [
    "All",
    "PCOS",
    "PCOD",
    "Hormones",
    "Mental Health"
  ];

  final stories = [
    {
      "title": "Hormone Insight",
      "subtitle": "Cycle & balance",
      "text":
          "Your hormones (estrogen & progesterone) control your cycle, mood, and energy."
    },
    {
      "title": "PCOS Truth",
      "subtitle": "Understand it better",
      "text":
          "PCOS is a hormonal imbalance that can be managed with lifestyle changes."
    },
    {
      "title": "Body Awareness",
      "subtitle": "Know yourself",
      "text":
          "Tracking your cycle helps you understand emotional and physical patterns."
    },
  ];

  final cards = [
    {
      "title": "PCOS (Polycystic Ovary Syndrome)",
      "subtitle": "Hormonal condition",
      "desc":
          "PCOS affects ovulation, hormones, skin, and metabolism. It is manageable.",
      "icon": Icons.health_and_safety,
      "category": "PCOS",
    },
    {
      "title": "PCOD (Polycystic Ovarian Disease)",
      "subtitle": "Mild imbalance",
      "desc":
          "PCOD is often lifestyle-related and can improve with diet and exercise.",
      "icon": Icons.spa,
      "category": "PCOD",
    },
    {
      "title": "Hormonal Balance",
      "subtitle": "Core health",
      "desc":
          "Sleep, nutrition, and stress control help balance hormones naturally.",
      "icon": Icons.favorite,
      "category": "Hormones",
    },
    {
      "title": "Mental Health",
      "subtitle": "Mind-body link",
      "desc":
          "Hormones directly affect mood, anxiety, and emotional health.",
      "icon": Icons.self_improvement,
      "category": "Mental Health",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredCards = selectedIndex == 0
        ? cards
        : cards.where((c) => c["category"] == categories[selectedIndex]).toList();

    return Scaffold(
      backgroundColor: bg,

      // 🤖 CHATBOT BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => const LearnChatBot(),
          );
        },
      ),

      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Learn",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // HEADER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "Learn about your body, hormones & cycles in a simple way 🌿",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // CATEGORY FILTER
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, i) {
                    final selected = i == selectedIndex;

                    return GestureDetector(
                      onTap: () => setState(() => selectedIndex = i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? accent : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accent),
                        ),
                        child: Text(
                          categories[i],
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // STORIES
              const Text(
                "Daily Learn 🌱",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 170,
                child: PageView.builder(
                  controller: controller,
                  onPageChanged: (i) => setState(() => current = i),
                  itemCount: stories.length,
                  itemBuilder: (context, i) {
                    final s = stories[i];
                    return StoryWidget(
                      title: s["title"]!,
                      subtitle: s["subtitle"]!,
                      text: s["text"]!,
                      isActive: i == current,
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // CARDS
              const Text(
                "PCOS • PCOD • Hormones",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredCards.length,
                itemBuilder: (context, i) {
                  final c = filteredCards[i];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LearnCard(
                      title: c["title"] as String,
                      subtitle: c["subtitle"] as String,
                      description: c["desc"] as String,
                      icon: c["icon"] as IconData,
                      color: accent,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}