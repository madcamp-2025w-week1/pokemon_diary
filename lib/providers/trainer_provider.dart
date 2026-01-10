import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/services.dart';

class TrainerProvider with ChangeNotifier {
  String _name = "RED";
  String _gender = "MALE";
  String _debutDate = "???"; 
  int _streak = 0;

  String get name => _name;
  String get gender => _gender;
  String get debutDate => _debutDate;
  int get streak => _streak;

  // 1. Load data immediately when the Provider is created
  TrainerProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    // Try to load saved data, otherwise fallback to defaults
    _name = prefs.getString('trainer_name') ?? "RED";
    _gender = prefs.getString('trainer_gender') ?? "MALE";

    // load debut date 
    String? savedDebut = prefs.getString('trainer_debut');
    if (savedDebut != null) {
      _debutDate = savedDebut;
    } else {
      // Not in prefs? Check DB (First time run logic)
      final diaries = await DbHelper.instance.getDiaries();
      if (diaries.isNotEmpty) {
        // Diaries are usually sorted ID DESC (Newest first), so Last is Oldest
        _debutDate = diaries.last.date; 
        // Save to prefs so we never query DB for this again
        await prefs.setString('trainer_debut', _debutDate); 
      } else {
        _debutDate = "NOT STARTED";
      }
    }

    // calculate streak for today 
    final allDiaries = await DbHelper.instance.getDiaries();
    _streak = calculateStreak(allDiaries);

    notifyListeners();
  }

  // 2. Update memory AND save to disk
  Future<void> updateName(String newName) async {
    _name = newName.toUpperCase();
    notifyListeners(); // Update UI immediately
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('trainer_name', _name); // Save permanently
  }

  Future<void> updateGender(String newGender) async {
    _gender = newGender.toUpperCase();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('trainer_gender', _gender);
  }

  // Helper to strip time off a DateTime (keep only YYYY-MM-DD)
  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Call this whenever a new Diary is saved to refresh the streak
  Future<void> refreshStreak() async {
    final allDiaries = await DbHelper.instance.getDiaries();
    _streak = calculateStreak(allDiaries);
    
    // Also check debut date if this was the VERY FIRST entry
    if (_debutDate == "NOT STARTED" && allDiaries.isNotEmpty) {
       _debutDate = allDiaries.last.date;
       final prefs = await SharedPreferences.getInstance();
       await prefs.setString('trainer_debut', _debutDate);
    }
    
    notifyListeners();
  }

  int calculateStreak(List<Diary> diaries) {
    if (diaries.isEmpty) return 0;

    // 1. Sort diaries newest to oldest (just in case)
    // Assumes Diary.date is an ISO8601 string 'YYYY-MM-DD'
    diaries.sort((a, b) => b.date.compareTo(a.date));

    // 2. Get unique dates (in case user wrote 2 entries in 1 day)
    final uniqueDates = diaries.map((e) => e.date).toSet().toList();
    
    // 3. Check the latest entry
    final today = _dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    final lastEntryDate = DateTime.parse(uniqueDates.first); // Assuming 'YYYY-MM-DD'

    // If the last entry is older than yesterday, the streak is broken.
    if (_dateOnly(lastEntryDate).isBefore(yesterday)) {
      return 0;
    }

    // 4. Count backwards
    int streak = 1;
    for (int i = 0; i < uniqueDates.length - 1; i++) {
      final current = DateTime.parse(uniqueDates[i]);
      final next = DateTime.parse(uniqueDates[i + 1]);

      // Check if 'next' is exactly 1 day before 'current'
      if (_dateOnly(current).subtract(const Duration(days: 1)) == _dateOnly(next)) {
        streak++;
      } else {
        break; // Streak broken
      }
    }

    return streak;
  }
}