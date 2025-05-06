import 'package:flutter/material.dart';
import 'package:nailgrow_mobile_app_dev/services/dialog_service.dart';
import 'package:nailgrow_mobile_app_dev/services/progress_service.dart';
import 'package:nailgrow_mobile_app_dev/state/data_provider.dart';
import 'package:nailgrow_mobile_app_dev/state/progress_provider.dart'; // ProgressProviderのインポート
import 'package:nailgrow_mobile_app_dev/screens/data_screen.dart';
import 'package:nailgrow_mobile_app_dev/screens/set_goal_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeService {
  final DialogService _dialogService = DialogService();
  final ProgressService _progressService = ProgressService();

  Future<void> loadPreferences({
    required Function(int?, int, int) onLoaded,
  }) async {
    await _progressService.getProgressData(onLoaded);
  }

  Future<void> updateAchievedDays(BuildContext context) async {
    await _progressService.updateAchievedDays(context);
  }

  Future<void> handleWinButtonPressed(BuildContext context, int? targetDays, int achievedDays) async {
    await _progressService.updateAchievedDays(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    achievedDays = DateTime.now().difference((await _progressService.preferencesService.getGoalSetDate())!).inDays; // 修正ポイント
    achievedDays = achievedDays < 0 ? 0 : achievedDays;
    if (achievedDays >= (targetDays ?? 0)) {
      await _progressService.incrementAchievedGoals();
      Provider.of<DataProvider>(context, listen: false).loadAchievedGoals();
      await _progressService.resetAchievedDays(context);
      Provider.of<ProgressProvider>(context, listen: false).loadProgress();

      await _dialogService.showWinDialog(context, () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DataScreen(),
          ),
        );
      });
    } else {
      Provider.of<ProgressProvider>(context, listen: false).loadProgress(); // ProgressProviderのインポートに対応
    }
  }

  Future<void> handleLoseButtonPressed(BuildContext context) async {
    await _progressService.resetAchievedDays(context);
    await _dialogService.showLoseDialog(context, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SetGoalScreen(isFirstTime: true)),
      );
    });
  }
}