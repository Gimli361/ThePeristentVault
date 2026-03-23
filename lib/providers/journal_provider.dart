import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/journal_entry.dart';

class JournalProvider extends ChangeNotifier {
  List<JournalEntry> _entries = [];
  JournalEntry? _todayEntry;
  Set<DateTime> _journalDates = {};
  bool _isLoading = false;

  List<JournalEntry> get entries => _entries;
  JournalEntry? get todayEntry => _todayEntry;
  Set<DateTime> get journalDates => _journalDates;
  bool get isLoading => _isLoading;
  int get entryCount => _entries.length;

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    _entries = await DatabaseHelper.instance.getAllJournals();
    _journalDates = await DatabaseHelper.instance.getJournalDates();

    final now = DateTime.now();
    _todayEntry = await DatabaseHelper.instance
        .getJournalByDate(DateTime(now.year, now.month, now.day));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveEntry(JournalEntry entry) async {
    if (entry.id != null) {
      await DatabaseHelper.instance.updateJournal(entry);
    } else {
      await DatabaseHelper.instance.insertJournal(entry);
    }
    await loadEntries();
  }

  Future<void> deleteEntry(int id) async {
    await DatabaseHelper.instance.deleteJournal(id);
    await loadEntries();
  }

  Future<JournalEntry?> getEntryByDate(DateTime date) async {
    return await DatabaseHelper.instance.getJournalByDate(date);
  }

  Future<List<JournalEntry>> searchEntries(String query) async {
    return await DatabaseHelper.instance.searchJournals(query);
  }
}
