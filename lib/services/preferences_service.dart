import 'package:shared_preferences/shared_preferences.dart';
import 'package:nailgrow_mobile_app_dev/models/progress_model.dart';
import 'package:flutter/material.dart';

class PreferencesService {
  Future<void> setTargetDays(int targetDays) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('targetDays', targetDays);
  }

  Future<int> getTargetDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('targetDays') ?? 30;
  }

  Future<void> setAchievedDays(int achievedDays) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('achievedDays', achievedDays);
  }

  Future<int> getAchievedDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('achievedDays') ?? 10;
  }

  Future<void> setGoalSetDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('goalSetDate', date.toIso8601String());
  }

  Future<DateTime?> getGoalSetDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('goalSetDate');
    if (dateString == null) {
      return null;
    }
    return DateTime.parse(dateString);
  }

  Future<Progress> getProgress() async {
    final prefs = await SharedPreferences.getInstance();
    int targetDays = prefs.getInt('targetDays') ?? 30;
    int achievedDays = prefs.getInt('achievedDays') ?? 10;
    return Progress(targetDays: targetDays, achievedDays: achievedDays);
  }

  Future<void> setTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);
  }

  Future<bool> isTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorial_completed') ?? false;
  }

  Future<void> printSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> allPrefs = {
      'targetDays': prefs.getInt('targetDays'),
      'achievedDays': prefs.getInt('achievedDays'),
      'achievedGoals': prefs.getInt('achievedGoals'),
      'goalSetDate': prefs.getString('goalSetDate'),
      'tutorial_completed': prefs.getBool('tutorial_completed'),
    };

    allPrefs.forEach((key, value) {
      debugPrint('$key: ${value != null ? value.toString() : 'NULL'}');
    });
  }
}
