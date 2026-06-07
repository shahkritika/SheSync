import 'package:flutter/material.dart';

class SheAnimatedNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SheAnimatedNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<SheAnimatedNavBar> createState() => _SheAnimatedNavBarState();
}

class _SheAnimatedNavBarState extends State<SheAnimatedNavBar> {
  final List<IconData> icons = [
    Icons.home_rounded,
    Icons.insights_rounded,
    Icons.track_changes_rounded,
    Icons.auto_stories_rounded, // 🌸 Learn (Pinterest / Stories vibe)
    Icons.history_rounded,
  ];

  final List<String> labels = [
    "Home",
    "Insights",
    "Track",
    "Learn",
    "History",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC1CC).withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(icons.length, (index) {
          final isSelected = widget.currentIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFC1CC).withOpacity(0.25)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: isSelected ? 1.2 : 1.0,
                      child: Icon(
                        icons[index],
                        color: isSelected
                            ? const Color(0xFFE91E63)
                            : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? const Color(0xFFE91E63)
                            : Colors.grey.shade500,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      child: Text(labels[index]),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}