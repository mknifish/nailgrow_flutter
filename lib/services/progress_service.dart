import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nailgrow_mobile_app_dev/services/preferences_service.dart';
import 'package:nailgrow_mobile_app_dev/state/progress_provider.dart';
import 'package:provider/provider.dart';

class ProgressService {
  final PreferencesService _preferencesService = PreferencesService();

  PreferencesService get preferencesService => _preferencesService; // _preferencesServiceゲッターを追加

  Future<void> updateAchievedDays(BuildContext context) async {
    print('===== updateAchievedDays 開始 =====');
    DateTime? goalSetDate = await _preferencesService.getGoalSetDate();
    print('goalSetDate: $goalSetDate');
    
    if (goalSetDate != null) {
      int achievedDays = DateTime.now().difference(goalSetDate).inDays;
      achievedDays = achievedDays < 0 ? 0 : achievedDays;
      print('計算したachievedDays: $achievedDays');
      
      await _preferencesService.setAchievedDays(achievedDays);
      Provider.of<ProgressProvider>(context, listen: false).loadProgress();
      print('達成日数を更新しました');
    } else {
      print('goalSetDateがnullのため更新できません');
    }
  }

  Future<void> resetAchievedDays(BuildContext context) async {
    await _preferencesService.setAchievedDays(0);
    Provider.of<ProgressProvider>(context, listen: false).loadProgress();
  }

  Future<void> getProgressData(Function(int?, int, int) onLoaded) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? targetDays = prefs.getInt('targetDays') ?? 10;
    int achievedGoals = prefs.getInt('achievedGoals') ?? 0;
    int achievedDays = 0;
    String? goalSetDateString = prefs.getString('goalSetDate');
    if (goalSetDateString != null) {
      DateTime goalSetDate = DateTime.parse(goalSetDateString);
      achievedDays = DateTime.now().difference(goalSetDate).inDays;
      achievedDays = achievedDays < 0 ? 0 : achievedDays;
    }
    onLoaded(targetDays, achievedGoals, achievedDays);
  }

  Future<void> incrementAchievedGoals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int achievedGoals = prefs.getInt('achievedGoals') ?? 0;
    achievedGoals++;
    await prefs.setInt('achievedGoals', achievedGoals);
  }

  Future<void> printSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('targetDays: ${prefs.getInt('targetDays')}');
    print('achievedDays: ${prefs.getInt('achievedDays')}');
    print('achievedGoals: ${prefs.getInt('achievedGoals')}');
    print('goalSetDate: ${prefs.getString('goalSetDate')}');
    print('tutorial_completed: ${prefs.getBool('tutorial_completed')}');
  }
}
