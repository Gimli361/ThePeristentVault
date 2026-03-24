import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'package:intl/intl.dart';

class StreakProvider extends ChangeNotifier {
  int _streakCount = 0;
  String? _lastActivityDate;
  bool _isActive = false;
  bool _showCelebration = false;
  int _celebrationMilestone = 0;

  int get streakCount => _streakCount;
  bool get isActive => _isActive;
  bool get showCelebration => _showCelebration;
  int get celebrationMilestone => _celebrationMilestone;

  static const List<int> _milestones = [7, 30, 100, 365];

  Future<void> loadStreak() async {
    final stats = await DatabaseHelper.instance.getUserStats();
    _streakCount = stats['streak_count'] as int? ?? 0;
    _lastActivityDate = stats['last_activity_date'] as String?;
    _checkActiveState();
    notifyListeners();
  }

  void _checkActiveState() {
    if (_lastActivityDate == null) {
      _isActive = false;
      return;
    }

    final lastDate = DateTime.parse(_lastActivityDate!);
    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);
    final lastStr = DateFormat('yyyy-MM-dd').format(lastDate);

    if (todayStr == lastStr) {
      // Activity today
      _isActive = true;
    } else {
      final diff = DateTime(today.year, today.month, today.day)
          .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
          .inDays;
      if (diff == 1) {
        // Yesterday was last activity, streak alive but not yet active today
        _isActive = false;
      } else {
        // Streak broken
        _streakCount = 0;
        _isActive = false;
      }
    }
  }

  /// Records activity for today. Call when user adds a word or journal entry.
  Future<void> recordActivity() async {
    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);

    if (_lastActivityDate != null) {
      final lastDate = DateTime.parse(_lastActivityDate!);
      final lastStr = DateFormat('yyyy-MM-dd').format(lastDate);

      if (todayStr == lastStr) {
        // Already recorded today
        return;
      }

      final diff = DateTime(today.year, today.month, today.day)
          .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
          .inDays;

      if (diff == 1) {
        _streakCount++;
      } else {
        _streakCount = 1;
      }
    } else {
      _streakCount = 1;
    }

    _lastActivityDate = todayStr;
    _isActive = true;

    await DatabaseHelper.instance.updateStreak(_streakCount, todayStr);

    // Check for milestone celebration
    if (_milestones.contains(_streakCount)) {
      _showCelebration = true;
      _celebrationMilestone = _streakCount;
    }

    notifyListeners();
  }

  void dismissCelebration() {
    _showCelebration = false;
    notifyListeners();
  }
}
