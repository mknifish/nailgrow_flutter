import 'package:flutter/material.dart';
import 'package:nailgrow_mobile_app_dev/screens/my_home_page.dart';
import 'package:nailgrow_mobile_app_dev/screens/tutorial_screen.dart';
import 'package:nailgrow_mobile_app_dev/services/preferences_service.dart';
import 'package:nailgrow_mobile_app_dev/services/data_migration_service.dart';
import 'package:nailgrow_mobile_app_dev/screens/test_data_screen.dart';
import 'package:nailgrow_mobile_app_dev/theme.dart'; // テーマをインポート

class MyApp extends StatelessWidget {
  final PreferencesService _preferencesService = PreferencesService();
  final DataMigrationService _dataMigrationService = DataMigrationService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkInitialSetup(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            theme: AppTheme.theme, // テーマを適用
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          final Widget initialScreen = snapshot.data == true
              ? const MyHomePage()
              : const TutorialIntroScreen();
              
          return MaterialApp(
            theme: AppTheme.theme, // テーマを適用
            home: Builder(
              builder: (context) {
                // データ移行が成功/失敗した場合、Widgetがビルドされた後に対応する画面を表示
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // 成功時
                  if (_migrationSuccess) {
                    _dataMigrationService.showMigrationSuccessScreen(context);
                    _migrationSuccess = false; // 画面を一度だけ表示するためにフラグをリセット
                  }
                  // 失敗時
                  else if (_migrationError) {
                    _dataMigrationService.showMigrationErrorScreen(context);
                    _migrationError = false; // 画面を一度だけ表示するためにフラグをリセット
                    _dataMigrationService.resetErrorState(); // エラー状態をリセット
                  }
                });
                return initialScreen;
              },
            ),
            routes: {
              '/test': (context) => const TestDataScreen(),
            },
          );
        }
      },
    );
  }
  
  // データ移行成功フラグ
  bool _migrationSuccess = false;
  
  // データ移行失敗フラグ
  bool _migrationError = false;
  
  /// アプリの初期設定を行い、チュートリアルを表示するかどうかを決定します
  Future<bool> _checkInitialSetup() async {
    // チュートリアルが完了しているか確認
    final tutorialCompleted = await _preferencesService.isTutorialCompleted();
    
    // 旧アプリからのデータ移行が必要かつ、まだ移行していない場合
    final dataMigrated = await _dataMigrationService.isDataAlreadyMigrated();
    
    if (!dataMigrated) {
      // 旧アプリからデータを移行
      final migrationSuccess = await _dataMigrationService.migrateDataFromLegacyApp();
      
      if (migrationSuccess) {
        // 移行に成功したらプログレスデータを読み込み
        await _preferencesService.printSharedPreferences();
        // 移行成功フラグを設定
        _migrationSuccess = true;
        // データ移行に成功した場合はチュートリアルをスキップ
        if (!tutorialCompleted) {
          await _preferencesService.setTutorialCompleted();
          return true;
        }
      } else {
        // 移行に失敗した場合はエラーフラグを設定
        _migrationError = true;
        debugPrint('データ移行に失敗しました: ${_dataMigrationService.getErrorMessage()}');
      }
    }
    
    return tutorialCompleted;
  }
}
