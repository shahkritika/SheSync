class UserProfile {
  final int age;
  final double height;
  final double weight;
  final String cycleType;
  final List<String> goals;

  UserProfile({
    required this.age,
    required this.height,
    required this.weight,
    required this.cycleType,
    required this.goals,
  });

  Map<String, dynamic> toJson() {
    return {
      "age": age,
      "height": height,
      "weight": weight,
      "cycleType": cycleType,
      "goals": goals,
    };
  }
}