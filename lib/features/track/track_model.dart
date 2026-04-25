class TrackEntry {
  final String date;
  final int mood;
  final int cycleDay;

  TrackEntry({
    required this.date,
    required this.mood,
    required this.cycleDay,
  });

  Map<String, dynamic> toJson() {
    return {
      "date": date,
      "mood": mood,
      "cycleDay": cycleDay,
    };
  }

  factory TrackEntry.fromJson(Map<String, dynamic> json) {
    return TrackEntry(
      date: json["date"],
      mood: json["mood"],
      cycleDay: json["cycleDay"],
    );
  }
}