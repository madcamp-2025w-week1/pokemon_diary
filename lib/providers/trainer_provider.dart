import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrainerProvider with ChangeNotifier {
  String _name = "RED";
  String _gender = "MALE";

  String get name => _name;
  String get gender => _gender;

  // 1. Load data immediately when the Provider is created
  TrainerProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    // Try to load saved data, otherwise fallback to defaults
    _name = prefs.getString('trainer_name') ?? "RED";
    _gender = prefs.getString('trainer_gender') ?? "MALE";
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
}