import 'package:flutter/material.dart';
import 'package:nailgrow_mobile_app_dev/services/dialog_service.dart';
import 'package:nailgrow_mobile_app_dev/services/progress_service.dart';
import 'package:nailgrow_mobile_app_dev/state/data_provider.dart';
import 'package:nailgrow_mobile_app_dev/state/progress_provider.dart'; // ProgressProviderのインポート
import 'package:nailgrow_mobile_app_dev/screens/data_screen.dart';
import 'package:nailgrow_mobile_app_dev/screens/set_goal_screen.dart';
import 'package:provider/provider.dart';

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
    // 最初にGoalSetDateを取得
    DateTime? goalSetDate = await _progressService.preferencesService.getGoalSetDate();
    print('goalSetDate: $goalSetDate');
    
    // もし目標設定日がなければ早期リターン
    if (goalSetDate == null) {
      print('goalSetDateがnullのため処理を中止');
      return;
    }
    
    // 実際の経過日数を計算
    int actualAchievedDays = DateTime.now().difference(goalSetDate).inDays;
    actualAchievedDays = actualAchievedDays < 0 ? 0 : actualAchievedDays;
    print('計算したactualAchievedDays: $actualAchievedDays');
    
    // 達成日数をSharedPreferencesに保存して更新
    await _progressService.preferencesService.setAchievedDays(actualAchievedDays);
    
    // ProviderのProgressを更新
    Provider.of<ProgressProvider>(context, listen: false).loadProgress();
    
    // 達成した日数が目標日数以上なら成功処理
    print('判定結果: actualAchievedDays: $actualAchievedDays >= targetDays: $targetDays = ${actualAchievedDays >= (targetDays ?? 0)}');
    if (actualAchievedDays >= (targetDays ?? 0)) {
      print('目標達成と判定されました');
      await _progressService.incrementAchievedGoals();
      Provider.of<DataProvider>(context, listen: false).loadAchievedGoals();
      await _progressService.resetAchievedDays(context);
      
      // UI更新のためにProviderを再度更新
      Provider.of<ProgressProvider>(context, listen: false).loadProgress();

      await _dialogService.showWinDialog(context, () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DataScreen(fromAchievement: true),
          ),
        );
      });
    } else {
      print('目標未達成と判定されました');
    }
  }

  Future<void> handleLoseButtonPressed(BuildContext context) async {
    await _progressService.resetAchievedDays(context);
    await _dialogService.showLoseDialog(context, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SetGoalScreen(isFirstTime: true)),
      );
    });
  }

  // デバッグ情報を表示する
  Future<void> printDebugInfo() async {
    print('===== HomeService デバッグ情報 =====');
    await _progressService.preferencesService.printSharedPreferences();
  }
}