import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/database_helper.dart';
import '../models/word.dart';
import '../services/dictionary_service.dart';

class WordProvider extends ChangeNotifier {
  List<Word> _words = [];
  List<Word> _filteredWords = [];
  Word? _randomWord;
  List<String> _allTags = [];
  String? _selectedTag;
  bool _isLoading = false;
  Map<MasteryLevel, int> _masteryStats = {};
  final DictionaryService _dictionaryService = DictionaryService();

  List<Word> get words => _selectedTag != null ? _filteredWords : _words;
  Word? get randomWord => _randomWord;
  List<String> get allTags => _allTags;
  String? get selectedTag => _selectedTag;
  bool get isLoading => _isLoading;
  int get wordCount => _words.length;
  Map<MasteryLevel, int> get masteryStats => _masteryStats;

  Future<void> loadWords() async {
    _isLoading = true;
    notifyListeners();

    _words = await DatabaseHelper.instance.getAllWords();
    _allTags = await DatabaseHelper.instance.getAllTags();
    _randomWord = await DatabaseHelper.instance.getWeightedRandomWord();
    _masteryStats = await DatabaseHelper.instance.getMasteryStats();

    if (_selectedTag != null) {
      _filteredWords =
          _words.where((w) => w.categoryTag == _selectedTag).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWord(Word word, {bool autoEnrich = true}) async {
    Word wordToSave = word;

    if (autoEnrich) {
      _isLoading = true;
      notifyListeners();

      final data = await _dictionaryService.fetchWordData(word.term);
      if (data.isNotEmpty) {
        wordToSave = word.copyWith(
          audioUrl: data['audioUrl'] ?? word.audioUrl,
          phonetic: data['phonetic'] ?? word.phonetic,
          synonyms: (data['synonyms'] as String?)?.isNotEmpty == true
              ? data['synonyms']
              : word.synonyms,
        );
      }
    }

    await DatabaseHelper.instance.insertWord(wordToSave);

    // Haptic feedback on save
    HapticFeedback.lightImpact();

    await loadWords();
  }

  Future<void> updateWord(Word word) async {
    await DatabaseHelper.instance.updateWord(word);
    await loadWords();
  }

  Future<void> deleteWord(int id) async {
    await DatabaseHelper.instance.deleteWord(id);
    await loadWords();
  }

  /// Promote a word's mastery level (Seed → Sprout → Oak)
  Future<void> promoteWord(int wordId) async {
    final word = _words.firstWhere((w) => w.id == wordId);
    if (word.masteryLevel == MasteryLevel.oak) return;

    final nextLevel = MasteryLevel.fromValue(word.masteryLevel.value + 1);
    await DatabaseHelper.instance.updateMasteryLevel(wordId, nextLevel.value);

    HapticFeedback.mediumImpact();

    await loadWords();
  }

  Future<List<Word>> searchWords(String query) async {
    return await DatabaseHelper.instance.searchWords(query);
  }

  void filterByTag(String? tag) {
    _selectedTag = tag;
    if (tag != null) {
      _filteredWords =
          _words.where((w) => w.categoryTag == tag).toList();
    }
    notifyListeners();
  }

  Future<void> refreshRandomWord() async {
    _randomWord = await DatabaseHelper.instance.getWeightedRandomWord();
    notifyListeners();
  }

  Future<List<String>> getAllTerms() async {
    return await DatabaseHelper.instance.getAllTerms();
  }
}
