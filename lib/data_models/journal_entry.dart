class JournalEntry {
  final int? id;
  final String title;
  final String content;
  final String mood;
  final int moodScore;
  final String date;
  final String? insight; // 🆕 tambahan baru

  JournalEntry({
    this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.moodScore,
    required this.date,
    this.insight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'mood': mood,
      'moodScore': moodScore,
      'date': date,
      'insight': insight,
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      mood: map['mood'] ?? 'Unknown',
      moodScore: map['moodScore'] ?? 0,
      date: map['date'] ?? '',
      insight: map['insight'],
    );
  }
}
