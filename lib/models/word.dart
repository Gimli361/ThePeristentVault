/// Mastery levels for the SRS (Spaced Repetition System)
enum MasteryLevel {
  seed(1, 'Seed', '🌱'),
  sprout(2, 'Sprout', '🌿'),
  oak(3, 'Oak', '🌳');

  final int value;
  final String label;
  final String emoji;

  const MasteryLevel(this.value, this.label, this.emoji);

  static MasteryLevel fromValue(int value) {
    switch (value) {
      case 2:
        return MasteryLevel.sprout;
      case 3:
        return MasteryLevel.oak;
      default:
        return MasteryLevel.seed;
    }
  }
}

class Word {
  final int? id;
  final String term;
  final String meaning;
  final String? exampleSentence;
  final String? synonyms;
  final String? audioUrl;
  final String? phonetic;
  final DateTime createdAt;
  final String? categoryTag;
  final MasteryLevel masteryLevel;

  Word({
    this.id,
    required this.term,
    required this.meaning,
    this.exampleSentence,
    this.synonyms,
    this.audioUrl,
    this.phonetic,
    DateTime? createdAt,
    this.categoryTag,
    this.masteryLevel = MasteryLevel.seed,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'term': term,
      'meaning': meaning,
      'example_sentence': exampleSentence,
      'synonyms': synonyms,
      'audio_url': audioUrl,
      'phonetic': phonetic,
      'created_at': createdAt.toIso8601String(),
      'category_tag': categoryTag,
      'mastery_level': masteryLevel.value,
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'] as int?,
      term: map['term'] as String,
      meaning: map['meaning'] as String,
      exampleSentence: map['example_sentence'] as String?,
      synonyms: map['synonyms'] as String?,
      audioUrl: map['audio_url'] as String?,
      phonetic: map['phonetic'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      categoryTag: map['category_tag'] as String?,
      masteryLevel: MasteryLevel.fromValue(map['mastery_level'] as int? ?? 1),
    );
  }

  Word copyWith({
    int? id,
    String? term,
    String? meaning,
    String? exampleSentence,
    String? synonyms,
    String? audioUrl,
    String? phonetic,
    DateTime? createdAt,
    String? categoryTag,
    MasteryLevel? masteryLevel,
  }) {
    return Word(
      id: id ?? this.id,
      term: term ?? this.term,
      meaning: meaning ?? this.meaning,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      synonyms: synonyms ?? this.synonyms,
      audioUrl: audioUrl ?? this.audioUrl,
      phonetic: phonetic ?? this.phonetic,
      createdAt: createdAt ?? this.createdAt,
      categoryTag: categoryTag ?? this.categoryTag,
      masteryLevel: masteryLevel ?? this.masteryLevel,
    );
  }

  List<String> get synonymList {
    if (synonyms == null || synonyms!.isEmpty) return [];
    return synonyms!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  bool get isMastered => masteryLevel == MasteryLevel.oak;
}
