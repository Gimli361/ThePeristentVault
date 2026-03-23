class JournalEntry {
  final int? id;
  final String entryText;
  final String? moodEmoji;
  final DateTime createdAt;

  JournalEntry({
    this.id,
    required this.entryText,
    this.moodEmoji,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'entry_text': entryText,
      'mood_emoji': moodEmoji,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as int?,
      entryText: map['entry_text'] as String,
      moodEmoji: map['mood_emoji'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  JournalEntry copyWith({
    int? id,
    String? entryText,
    String? moodEmoji,
    DateTime? createdAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      entryText: entryText ?? this.entryText,
      moodEmoji: moodEmoji ?? this.moodEmoji,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
