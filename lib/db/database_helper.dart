import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/word.dart';
import '../models/journal_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('persistent_vault.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, fileName);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        term TEXT NOT NULL,
        meaning TEXT NOT NULL,
        example_sentence TEXT,
        synonyms TEXT,
        audio_url TEXT,
        phonetic TEXT,
        created_at TEXT NOT NULL,
        category_tag TEXT,
        mastery_level INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE journal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_text TEXT NOT NULL,
        mood_emoji TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_stats (
        id INTEGER PRIMARY KEY,
        streak_count INTEGER DEFAULT 0,
        last_activity_date TEXT,
        is_notifications_enabled INTEGER DEFAULT 1
      )
    ''');

    // Insert default user stats row
    await db.insert('user_stats', {
      'id': 1,
      'streak_count': 0,
      'last_activity_date': null,
      'is_notifications_enabled': 1,
    });
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE words ADD COLUMN mastery_level INTEGER DEFAULT 1');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_stats (
          id INTEGER PRIMARY KEY,
          streak_count INTEGER DEFAULT 0,
          last_activity_date TEXT,
          is_notifications_enabled INTEGER DEFAULT 1
        )
      ''');

      final existing = await db.query('user_stats', where: 'id = 1');
      if (existing.isEmpty) {
        await db.insert('user_stats', {
          'id': 1,
          'streak_count': 0,
          'last_activity_date': null,
          'is_notifications_enabled': 1,
        });
      }
    }
  }

  // ── WORD CRUD ──

  Future<int> insertWord(Word word) async {
    final db = await database;
    return await db.insert('words', word.toMap());
  }

  Future<List<Word>> getAllWords() async {
    final db = await database;
    final result = await db.query('words', orderBy: 'created_at DESC');
    return result.map((map) => Word.fromMap(map)).toList();
  }

  Future<Word?> getWordById(int id) async {
    final db = await database;
    final result = await db.query('words', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) return Word.fromMap(result.first);
    return null;
  }

  Future<Word?> getRandomWord() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT * FROM words ORDER BY RANDOM() LIMIT 1');
    if (result.isNotEmpty) return Word.fromMap(result.first);
    return null;
  }

  /// SRS-weighted random word: 75% chance for Seed/Sprout, 25% for Oak
  Future<Word?> getWeightedRandomWord() async {
    final db = await database;

    // Try to get a Seed or Sprout word first (75% of the time)
    final shouldPrioritize = DateTime.now().millisecond % 4 != 0; // ~75%

    if (shouldPrioritize) {
      final result = await db.rawQuery(
        'SELECT * FROM words WHERE mastery_level < 3 ORDER BY RANDOM() LIMIT 1',
      );
      if (result.isNotEmpty) return Word.fromMap(result.first);
    }

    // Fallback to any random word
    final result =
        await db.rawQuery('SELECT * FROM words ORDER BY RANDOM() LIMIT 1');
    if (result.isNotEmpty) return Word.fromMap(result.first);
    return null;
  }

  Future<int> updateWord(Word word) async {
    final db = await database;
    return await db
        .update('words', word.toMap(), where: 'id = ?', whereArgs: [word.id]);
  }

  Future<int> updateMasteryLevel(int wordId, int level) async {
    final db = await database;
    return await db.update(
      'words',
      {'mastery_level': level},
      where: 'id = ?',
      whereArgs: [wordId],
    );
  }

  Future<int> deleteWord(int id) async {
    final db = await database;
    return await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Word>> searchWords(String query) async {
    final db = await database;
    final result = await db.query(
      'words',
      where: 'term LIKE ? OR meaning LIKE ? OR example_sentence LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Word.fromMap(map)).toList();
  }

  Future<List<Word>> getWordsByTag(String tag) async {
    final db = await database;
    final result = await db.query(
      'words',
      where: 'category_tag LIKE ?',
      whereArgs: ['%$tag%'],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Word.fromMap(map)).toList();
  }

  Future<List<String>> getAllTags() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT DISTINCT category_tag FROM words WHERE category_tag IS NOT NULL AND category_tag != ""');
    return result.map((map) => map['category_tag'] as String).toList();
  }

  Future<List<String>> getAllTerms() async {
    final db = await database;
    final result = await db.rawQuery('SELECT term FROM words');
    return result.map((map) => map['term'] as String).toList();
  }

  /// Get mastery stats: count per level
  Future<Map<MasteryLevel, int>> getMasteryStats() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT mastery_level, COUNT(*) as cnt FROM words GROUP BY mastery_level',
    );
    final stats = <MasteryLevel, int>{
      MasteryLevel.seed: 0,
      MasteryLevel.sprout: 0,
      MasteryLevel.oak: 0,
    };
    for (final row in result) {
      final level =
          MasteryLevel.fromValue(row['mastery_level'] as int? ?? 1);
      stats[level] = row['cnt'] as int;
    }
    return stats;
  }

  // ── JOURNAL CRUD ──

  Future<int> insertJournal(JournalEntry entry) async {
    final db = await database;
    return await db.insert('journal', entry.toMap());
  }

  Future<List<JournalEntry>> getAllJournals() async {
    final db = await database;
    final result = await db.query('journal', orderBy: 'created_at DESC');
    return result.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<JournalEntry?> getJournalByDate(DateTime date) async {
    final db = await database;
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final result = await db.query(
      'journal',
      where: 'created_at LIKE ?',
      whereArgs: ['$dateStr%'],
    );
    if (result.isNotEmpty) return JournalEntry.fromMap(result.first);
    return null;
  }

  Future<List<JournalEntry>> getJournalsForMonth(int year, int month) async {
    final db = await database;
    final monthStr = month.toString().padLeft(2, '0');
    final result = await db.query(
      'journal',
      where: 'created_at LIKE ?',
      whereArgs: ['$year-$monthStr%'],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<int> updateJournal(JournalEntry entry) async {
    final db = await database;
    return await db.update('journal', entry.toMap(),
        where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<int> deleteJournal(int id) async {
    final db = await database;
    return await db.delete('journal', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<JournalEntry>> searchJournals(String query) async {
    final db = await database;
    final result = await db.query(
      'journal',
      where: 'entry_text LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<Set<DateTime>> getJournalDates() async {
    final db = await database;
    final result = await db.rawQuery('SELECT created_at FROM journal');
    return result.map((map) {
      final dt = DateTime.parse(map['created_at'] as String);
      return DateTime(dt.year, dt.month, dt.day);
    }).toSet();
  }

  // ── USER STATS (Streak) ──

  Future<Map<String, dynamic>> getUserStats() async {
    final db = await database;
    final result = await db.query('user_stats', where: 'id = 1');
    if (result.isNotEmpty) return result.first;
    return {'streak_count': 0, 'last_activity_date': null, 'is_notifications_enabled': 1};
  }

  Future<void> updateStreak(int streak, String lastDate) async {
    final db = await database;
    await db.update(
      'user_stats',
      {'streak_count': streak, 'last_activity_date': lastDate},
      where: 'id = 1',
    );
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final db = await database;
    await db.update(
      'user_stats',
      {'is_notifications_enabled': enabled ? 1 : 0},
      where: 'id = 1',
    );
  }

  // ── GLOBAL SEARCH ──

  Future<Map<String, List<dynamic>>> globalSearch(String query) async {
    final words = await searchWords(query);
    final journals = await searchJournals(query);
    return {
      'words': words,
      'journals': journals,
    };
  }
}
