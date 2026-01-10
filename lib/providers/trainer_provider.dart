import 'package:flutter/material.dart';

class TrainerProvider with ChangeNotifier {
  String _name = "RED";
  String _gender = "MALE";

  String get name => _name;
  String get gender => _gender;

  void updateName(String newName) {
    _name = newName.toUpperCase();
    notifyListeners();
  }

  void updateGender(String newGender) {
    _gender = newGender.toUpperCase();
    notifyListeners();
  }
}
