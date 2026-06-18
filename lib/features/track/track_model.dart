class TrackEntry {
  final String date;
  final int mood;
  final int cycleDay;
  final int flow;
  final List<String> symptoms;
  final int waterGlasses;
  final double sleepHours;
  final String exercise;
  final String diet;
  final String temperature;
  final bool tookMedication;
  final String notes;

  TrackEntry({
    required this.date,
    required this.mood,
    required this.cycleDay,
    this.flow = 0,
    this.symptoms = const [],
    this.waterGlasses = 0,
    this.sleepHours = 7,
    this.exercise = 'Rest 🛋️',
    this.diet = 'Moderate 🍱',
    this.temperature = '',
    this.tookMedication = false,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      "date": date,
      "mood": mood,
      "cycleDay": cycleDay,
      "flow": flow,
      "symptoms": symptoms,
      "waterGlasses": waterGlasses,
      "sleepHours": sleepHours,
      "exercise": exercise,
      "diet": diet,
      "temperature": temperature,
      "tookMedication": tookMedication,
      "notes": notes,
    };
  }

  factory TrackEntry.fromJson(Map<String, dynamic> json) {
    return TrackEntry(
      date: json["date"] ?? '',
      mood: json["mood"] ?? 2,
      cycleDay: json["cycleDay"] ?? 1,
      flow: json["flow"] ?? 0,
      symptoms: json["symptoms"] != null
          ? List<String>.from(json["symptoms"])
          : [],
      waterGlasses: json["waterGlasses"] ?? 0,
      sleepHours: (json["sleepHours"] ?? 7).toDouble(),
      exercise: json["exercise"] ?? 'Rest 🛋️',
      diet: json["diet"] ?? 'Moderate 🍱',
      temperature: json["temperature"] ?? '',
      tookMedication: json["tookMedication"] ?? false,
      notes: json["notes"] ?? '',
    );
  }
}