import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nailgrow_mobile_app_dev/screens/migration_success_screen.dart';
import 'package:nailgrow_mobile_app_dev/screens/migration_error_screen.dart';

class DataMigrationService {
  static const MethodChannel _channel = MethodChannel('com.nailgrow/data_migration');
  
  /// 旧アプリのLocalStorageからデータを移行します
  Future<bool> migrateDataFromLegacyApp() async {
    // iOSのみで実行
    if (!Platform.isIOS) {
      debugPrint('データ移行はiOSのみサポートされています');
      _migrationErrorMessage = 'この機能はiOSのみサポートされています';
      return false;
    }
    
    try {
      // MethodChannelを使用してiOSネイティブコードを呼び出し
      final Map<dynamic, dynamic>? migrationData = 
          await _channel.invokeMethod('migrateLocalStorageData');
          
      if (migrationData == null || migrationData.isEmpty) {
        debugPrint('移行するデータが見つかりませんでした');
        _migrationErrorMessage = '移行するデータが見つかりませんでした';
        return false;
      }
      
      debugPrint('移行するデータ: $migrationData');
      
      // SharedPreferencesにデータを保存
      return await _saveDataToSharedPreferences(migrationData);
    } on PlatformException catch (e) {
      debugPrint('データ移行エラー: ${e.message}');
      _migrationErrorMessage = 'データ移行エラー: ${e.message}';
      return false;
    } catch (e) {
      debugPrint('予期しないエラー: $e');
      _migrationErrorMessage = '予期しないエラー: ${e.toString()}';
      return false;
    }
  }
  
  /// 移行データをSharedPreferencesに保存
  Future<bool> _saveDataToSharedPreferences(Map<dynamic, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> savedData = {};
      
      // start_yearとstart_monthとstart_dayから目標設定日を設定
      if (data.containsKey('start_year') && 
          data.containsKey('start_month') && 
          data.containsKey('start_day')) {
        final year = data['start_year'] as int;
        final month = data['start_month'] as int;
        final day = data['start_day'] as int;
        
        final goalSetDate = DateTime(year, month, day);
        await prefs.setString('goalSetDate', goalSetDate.toIso8601String());
        savedData['goalSetDate'] = goalSetDate;
      }
      
      // my_goalが存在する場合は保存（将来的な拡張用）
      if (data.containsKey('my_goal')) {
        final myGoal = data['my_goal'].toString();
        await prefs.setString('legacy_my_goal', myGoal);
        savedData['legacy_my_goal'] = myGoal;
      }
      
      // myCalGoalをtargetDaysに変換
      if (data.containsKey('myCalGoal')) {
        final targetDays = data['myCalGoal'] as int;
        await prefs.setInt('targetDays', targetDays);
        savedData['targetDays'] = targetDays;
      } else {
        // デフォルト値
        await prefs.setInt('targetDays', 30);
        savedData['targetDays'] = 30;
      }
      
      // myDayCountをachievedDaysに変換
      if (data.containsKey('myDayCount')) {
        final achievedDays = data['myDayCount'] as int;
        await prefs.setInt('achievedDays', achievedDays);
        savedData['achievedDays'] = achievedDays;
      } else {
        await prefs.setInt('achievedDays', 0);
        savedData['achievedDays'] = 0;
      }
      
      // my_badgesが存在する場合は保存（将来的な拡張用）
      if (data.containsKey('my_badges')) {
        final myBadges = data['my_badges'].toString();
        await prefs.setString('legacy_my_badges', myBadges);
        savedData['legacy_my_badges'] = myBadges;
      }
      
      // データ移行フラグを設定
      await prefs.setBool('data_migrated', true);
      
      debugPrint('データの移行が完了しました');
      
      // 成功データを返す
      _migrationCompletedData = savedData;
      return true;
    } catch (e) {
      debugPrint('SharedPreferencesへの保存エラー: $e');
      _migrationErrorMessage = 'データの保存に失敗しました: ${e.toString()}';
      return false;
    }
  }
  
  /// データが既に移行されているかを確認
  Future<bool> isDataAlreadyMigrated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('data_migrated') ?? false;
  }
  
  // 移行が完了したデータ
  Map<String, dynamic>? _migrationCompletedData;
  
  // エラーメッセージ
  String? _migrationErrorMessage;
  
  // 移行成功画面を表示する
  void showMigrationSuccessScreen(BuildContext context) {
    if (_migrationCompletedData != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MigrationSuccessScreen(
            migratedData: _migrationCompletedData!,
          ),
        ),
      );
    }
  }
  
  // 移行失敗画面を表示する
  void showMigrationErrorScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MigrationErrorScreen(
          errorMessage: _migrationErrorMessage ?? '',
        ),
      ),
    );
  }
  
  // エラーメッセージを取得
  String? getErrorMessage() {
    return _migrationErrorMessage;
  }
  
  // エラー状態をリセット
  void resetErrorState() {
    _migrationErrorMessage = null;
  }
} 