import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/services.dart';

class DiaryProvider extends ChangeNotifier {
  DiaryProvider({DbHelper? dbHelper}) : _dbHelper = dbHelper ?? DbHelper.instance;

  final DbHelper _dbHelper;
  final List<Diary> _diaries = [];
  bool _isLoading = false;

  List<Diary> get diaries => List.unmodifiable(_diaries);
  bool get isLoading => _isLoading;

  Future<void> loadDiaries() async {
    _setLoading(true);
    final diaries = await _dbHelper.getDiaries();
    diaries.sort((a, b) => b.date.compareTo(a.date));
    _diaries
      ..clear()
      ..addAll(diaries);
    _setLoading(false);
  }

  Future<void> refreshDiaries() async {
    await loadDiaries();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }
}
