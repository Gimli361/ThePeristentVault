import 'package:flutter/material.dart';
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
  final DictionaryService _dictionaryService = DictionaryService();

  List<Word> get words => _selectedTag != null ? _filteredWords : _words;
  Word? get randomWord => _randomWord;
  List<String> get allTags => _allTags;
  String? get selectedTag => _selectedTag;
  bool get isLoading => _isLoading;
  int get wordCount => _words.length;

  Future<void> loadWords() async {
    _isLoading = true;
    notifyListeners();

    _words = await DatabaseHelper.instance.getAllWords();
    _allTags = await DatabaseHelper.instance.getAllTags();
    _randomWord = await DatabaseHelper.instance.getRandomWord();

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
    _randomWord = await DatabaseHelper.instance.getRandomWord();
    notifyListeners();
  }

  Future<List<String>> getAllTerms() async {
    return await DatabaseHelper.instance.getAllTerms();
  }
}
