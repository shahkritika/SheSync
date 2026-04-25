class RecommendationEngine {

  static String getRecommendation(int mood, int cycleDay) {

    // 🌿 Mood-based suggestions
    if (mood <= 1) {
      return "You're feeling low 💛 Try rest, warm tea, and gentle movement.";
    }

    if (mood == 2) {
      return "You're doing okay 🌿 Stay hydrated and take light walks.";
    }

    if (mood >= 3) {
      return "You're feeling great ✨ Perfect time for workouts or productivity!";
    }

    // 🩸 Cycle-based fallback
    if (cycleDay >= 21) {
      return "Luteal phase 🌙 Focus on rest, self-care, and low intensity work.";
    }

    return "Listen to your body 🌸 You're doing your best.";
  }
}