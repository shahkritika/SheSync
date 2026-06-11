import 'package:flutter/material.dart';
import 'widgets/learn_card.dart';
import 'widgets/story_widget.dart';

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

  final stories = [
    {
      "title": "Hormone Insight",
      "subtitle": "Cycle & balance",
      "text":
          "Your menstrual cycle is regulated by estrogen, progesterone, insulin, and cortisol. Even stress or sleep changes can shift ovulation timing."
    },
    {
      "title": "PCOS Truth",
      "subtitle": "A manageable condition",
      "text":
          "PCOS is not a fixed disease — it is a metabolic-hormonal imbalance that can be improved through consistent lifestyle changes."
    },
    {
      "title": "Body Awareness",
      "subtitle": "Understand patterns",
      "text":
          "Tracking your cycle helps identify emotional, physical, and hormonal patterns over time."
    },
  ];

  final cards = [
    {
      "title": "PCOS (Polycystic Ovary Syndrome)",
      "subtitle": "Hormonal + metabolic condition",
      "desc":
          "PCOS involves irregular ovulation, increased androgen levels, and insulin resistance. It affects metabolism, skin, mood, and fertility.",
      "icon": Icons.health_and_safety,
    },
    {
      "title": "PCOD (Polycystic Ovarian Disease)",
      "subtitle": "Mild ovarian imbalance",
      "desc":
          "PCOD occurs when ovaries release immature eggs. It is often influenced by lifestyle and is more reversible compared to PCOS.",
      "icon": Icons.spa,
    },
    {
      "title": "Key Difference",
      "subtitle": "PCOS vs PCOD",
      "desc":
          "PCOS is a systemic hormonal condition with metabolic effects. PCOD is mainly ovarian and often less severe.",
      "icon": Icons.compare_arrows,
    },
    {
      "title": "Management Approach",
      "subtitle": "Holistic lifestyle system",
      "desc":
          "• Balanced nutrition (whole foods, low sugar)\n"
          "• Strength training + daily movement\n"
          "• Stress reduction (meditation, journaling)\n"
          "• Sleep consistency (7–9 hours)\n"
          "• Medical support if required\n\n"
          "Small consistent habits create long-term hormonal balance and stability.",
      "icon": Icons.self_improvement,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Learn",
          style: TextStyle(
            color: Colors.green.shade900,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.green.shade800),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🌿 HEADER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.2),
                      blurRadius: 12,
                    )
                  ],
                ),
                child: const Text(
                  "Gentle, science-backed understanding of your hormones 🌿",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 📖 STORIES
              const Text(
                "Daily Learn 🌱",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

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

              // 🧠 GUIDE
              const Text(
                "PCOS & PCOD Guide 🌿",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              // FIXED OVERFLOW → shrinkWrap + no extra constraints
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cards.length,
                itemBuilder: (context, i) {
                  final c = cards[i];

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

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}