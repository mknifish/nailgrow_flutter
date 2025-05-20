import 'package:flutter/material.dart';
import 'data_migration_helper.dart';
import 'nailgrow_data_migration.dart';
import 'specific_origin_migration.dart';

/// NailGrowアプリのデータ移行の使用例
///
/// このファイルは、旧アプリ（AngularJS）からのデータ移行を具体的に
/// どのように行うかの例を示しています。
class NailGrowMigrationExample {
  /// アプリ起動時にデータ移行の有無をチェックし、必要に応じて移行を実行
  ///
  /// [context] ビルドコンテキスト
  /// [oldAppUrl] 旧アプリのURL（例：'https://your-old-app-url.com'）
  /// [onTutorialRequired] チュートリアル表示が必要な場合のコールバック
  /// [onMigrationCompleted] データ移行完了後のコールバック
  static Future<void> checkAndMigrateOnLaunch(
    BuildContext context, {
    required String oldAppUrl,
    VoidCallback? onTutorialRequired,
    VoidCallback? onMigrationCompleted,
  }) async {
    // アプリの状態を判別
    final appState = await DataMigrationHelper.determineAppState();
    
    switch (appState) {
      case AppStateType.newInstall:
        // 新規インストールの場合はチュートリアルを表示
        if (onTutorialRequired != null) {
          onTutorialRequired();
        }
        break;
        
      case AppStateType.updateFromAngularJS:
        // AngularJSバージョンからのアップデートの場合はデータ移行を実行
        if (context.mounted) {
          // データ移行を確認なしで実行
          await SpecificOriginMigration.migrateFromSpecificOrigin(
            context,
            url: oldAppUrl,
            migrationCompletedKey: 'nailgrow_migration_completed',
            onDataReceived: (data) async {
              // 専用のデータ変換処理を実行
              await NailGrowDataMigration.convertLocalStorageToSharedPreferences(data);
            },
          );
          
          // 移行完了後のコールバックを実行
          if (onMigrationCompleted != null && context.mounted) {
            onMigrationCompleted();
          }
        }
        break;
        
      case AppStateType.normalUpdate:
        // 通常のアップデートの場合は特に何もしない
        break;
        
      case AppStateType.existingInstall:
        // 既存インストールの場合は特に何もしない
        break;
    }
  }
  
  /// 移行したデータからProgressモデルを作成する例
  static Future<Map<String, dynamic>> getProgressFromMigratedData() async {
    return await NailGrowDataMigration.getProgressDataFromPrefs();
  }
}

/// 使用例：main.dartファイルでの実装
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:nailgrow_mobile_app_dev/utils/migration_example_usage.dart';
/// 
/// void main() {
///   runApp(const MyApp());
/// }
/// 
/// class MyApp extends StatelessWidget {
///   const MyApp({Key? key}) : super(key: key);
/// 
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       title: 'ネイルグロー',
///       theme: ThemeData(
///         primarySwatch: Colors.pink,
///         visualDensity: VisualDensity.adaptivePlatformDensity,
///       ),
///       home: Builder(
///         builder: (context) {
///           // アプリの起動後にデータ移行を確認
///           WidgetsBinding.instance.addPostFrameCallback((_) {
///             NailGrowMigrationExample.checkAndMigrateOnLaunch(
///               context,
///               oldAppUrl: 'https://your-angular-app-url.com',
///               onTutorialRequired: () {
///                 // チュートリアル画面へ遷移
///                 Navigator.of(context).pushNamed('/tutorial');
///               },
///               onMigrationCompleted: () {
///                 // データ移行完了後の処理
///                 ScaffoldMessenger.of(context).showSnackBar(
///                   const SnackBar(content: Text('データの移行が完了しました')),
///                 );
///                 
///                 // 必要に応じて移行したデータを使用
///                 NailGrowMigrationExample.getProgressFromMigratedData()
///                   .then((progressData) {
///                     // Progressモデルを使用してUIを更新するなど
///                     print('Target days: ${progressData['targetDays']}');
///                     print('Achieved days: ${progressData['achievedDays']}');
///                   });
///               },
///             );
///           });
///           return const HomePage();
///         },
///       ),
///       routes: {
///         '/tutorial': (context) => const TutorialScreen(),
///         // その他のルート定義
///       },
///     );
///   }
/// }
/// ``` 