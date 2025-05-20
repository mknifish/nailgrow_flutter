import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data_migration_helper.dart';

/// NailGrowアプリ専用のデータ移行クラス
/// 旧アプリ（AngularJS）のLocalStorageから新アプリ（Flutter）のSharedPreferencesへの
/// 具体的なデータマッピングを行います。
class NailGrowDataMigration {
  // 旧アプリのキー
  static const String _oldBadgesKey = 'my_badges';
  static const String _oldGoalKey = 'my_goal';
  static const String _oldStartYearKey = 'start_year';
  static const String _oldStartMonthKey = 'start_month';
  static const String _oldStartDayKey = 'start_day';
  static const String _oldDayCountKey = 'myDayCount';
  static const String _oldCalGoalKey = 'myCalGoal';
  static const String _oldGoalDaysKey = 'my_goalDays';

  // 新アプリのキー（必要に応じて変更）
  static const String newBadgesKey = 'badges_count';
  static const String newGoalKey = 'goal_length_cm';
  static const String newStartDateKey = 'start_date';
  static const String newDayCountKey = 'elapsed_days';
  static const String newCurrentProgressKey = 'current_progress';
  static const String newGoalDaysKey = 'goal_days';
  static const String newTargetDaysKey = 'target_days';
  static const String newAchievedDaysKey = 'achieved_days';

  /// LocalStorageデータを取得してSharedPreferencesに変換
  /// AngularJSアプリのデータ項目をFlutterアプリのデータ項目に対応させます
  static Future<void> convertLocalStorageToSharedPreferences(Map<String, dynamic> localStorageData) async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      // バッジ数の移行
      if (localStorageData.containsKey(_oldBadgesKey)) {
        final badges = int.tryParse(localStorageData[_oldBadgesKey].toString()) ?? 0;
        await prefs.setInt(newBadgesKey, badges);
      }
      
      // 目標長さの移行
      if (localStorageData.containsKey(_oldGoalKey)) {
        final goal = double.tryParse(localStorageData[_oldGoalKey].toString()) ?? 1.0;
        await prefs.setDouble(newGoalKey, goal);
      }
      
      // 開始日の移行
      if (localStorageData.containsKey(_oldStartYearKey) && 
          localStorageData.containsKey(_oldStartMonthKey) && 
          localStorageData.containsKey(_oldStartDayKey)) {
        final year = int.tryParse(localStorageData[_oldStartYearKey].toString()) ?? DateTime.now().year;
        final month = int.tryParse(localStorageData[_oldStartMonthKey].toString()) ?? DateTime.now().month;
        final day = int.tryParse(localStorageData[_oldStartDayKey].toString()) ?? DateTime.now().day;
        
        final startDate = DateTime(year, month, day);
        await prefs.setString(newStartDateKey, startDate.toIso8601String());
      }
      
      // 経過日数の移行
      if (localStorageData.containsKey(_oldDayCountKey)) {
        final dayCount = int.tryParse(localStorageData[_oldDayCountKey].toString()) ?? 0;
        await prefs.setInt(newDayCountKey, dayCount);
        
        // Progressモデル用のachievedDaysとしても保存
        await prefs.setInt(newAchievedDaysKey, dayCount);
      }
      
      // 現在の進捗状況の移行
      if (localStorageData.containsKey(_oldCalGoalKey)) {
        final currentProgress = double.tryParse(localStorageData[_oldCalGoalKey].toString()) ?? 0.0;
        await prefs.setDouble(newCurrentProgressKey, currentProgress);
      }
      
      // 目標日数の移行
      if (localStorageData.containsKey(_oldGoalDaysKey)) {
        final goalDays = int.tryParse(localStorageData[_oldGoalDaysKey].toString()) ?? 10;
        await prefs.setInt(newGoalDaysKey, goalDays);
        
        // Progressモデル用のtargetDaysとしても保存
        await prefs.setInt(newTargetDaysKey, goalDays);
      } else if (localStorageData.containsKey(_oldGoalKey)) {
        // goalDaysが無い場合はmy_goalから計算（旧アプリのロジックに合わせて）
        final goal = double.tryParse(localStorageData[_oldGoalKey].toString()) ?? 1.0;
        final goalDays = (goal * 10).toInt();
        await prefs.setInt(newGoalDaysKey, goalDays);
        await prefs.setInt(newTargetDaysKey, goalDays);
      }
      
      // 移行完了フラグを設定
      await prefs.setBool('nailgrow_migration_completed', true);
      
    } catch (e) {
      debugPrint('データ変換エラー: $e');
    }
  }
  
  /// 旧アプリのデータが存在するかどうかを確認する
  /// LocalStorageのデータを確認して、旧アプリのデータが存在するかを判断します
  static bool hasOldAppData(Map<String, dynamic> localStorageData) {
    // 最低限必要なデータが存在するかをチェック
    return localStorageData.containsKey(_oldBadgesKey) || 
           localStorageData.containsKey(_oldGoalKey) || 
           localStorageData.containsKey(_oldStartYearKey);
  }
  
  /// 移行したデータからProgressモデルオブジェクトを作成する
  /// この関数を使って、移行後のデータからProgressモデルを簡単に作成できます
  static Future<Map<String, dynamic>> getProgressDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    final targetDays = prefs.getInt(newTargetDaysKey) ?? 10;
    final achievedDays = prefs.getInt(newAchievedDaysKey) ?? 0;
    
    return {
      'targetDays': targetDays,
      'achievedDays': achievedDays,
    };
  }
  
  /// データ移行が完了しているかどうかを確認する
  static Future<bool> isMigrationCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('nailgrow_migration_completed') ?? false;
  }
}

// 使用例:
// 
// import 'package:nailgrow_mobile_app_dev/utils/specific_origin_migration.dart';
// import 'package:nailgrow_mobile_app_dev/utils/nailgrow_data_migration.dart';
//
// // LocalStorageデータを取得後、変換処理を行う例
// SpecificOriginMigration.migrateFromSpecificOrigin(
//   context,
//   url: 'https://your-old-app-url.com',
//   onDataReceived: (Map<String, dynamic> data) async {
//     // 取得したデータをNailGrow専用の形式に変換
//     await NailGrowDataMigration.convertLocalStorageToSharedPreferences(data);
//   },
// ); 