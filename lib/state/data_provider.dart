import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataProvider with ChangeNotifier {
  int _achievedGoals = 0;

  int get achievedGoals => _achievedGoals;

  DataProvider() {
    loadAchievedGoals();
  }

  Future<void> loadAchievedGoals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _achievedGoals = prefs.getInt('achievedGoals') ?? 0;
    notifyListeners();
  }
}
