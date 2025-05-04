import 'package:flutter/material.dart';
import 'package:nailgrow_mobile_app_dev/models/progress_model.dart';
import 'package:nailgrow_mobile_app_dev/services/preferences_service.dart';

class ProgressProvider with ChangeNotifier {
  Progress _progress = Progress(targetDays: 0, achievedDays: 0);
  final PreferencesService _preferencesService = PreferencesService();

  Progress get progress => _progress;

  Future<void> loadProgress() async {
    _progress = await _preferencesService.getProgress();
    notifyListeners();
  }

  Future<void> setTargetDays(int targetDays) async {
    _progress = Progress(targetDays: targetDays, achievedDays: _progress.achievedDays);
    await _preferencesService.setTargetDays(targetDays);
    notifyListeners();
  }

  Future<void> setAchievedDays(int achievedDays) async {
    _progress = Progress(targetDays: _progress.targetDays, achievedDays: achievedDays);
    await _preferencesService.setAchievedDays(achievedDays);
    notifyListeners();
  }
}
