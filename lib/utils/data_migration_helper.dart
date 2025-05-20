import 'package:flutter/material.dart';
import 'local_storage_migration.dart';
import 'specific_origin_migration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// アプリ状態の種類
enum AppStateType {
  /// 新規インストール
  newInstall,
  
  /// AngularJSバージョンからのアップデート
  updateFromAngularJS,
  
  /// 通常のアップデート
  normalUpdate,
  
  /// 既存インストール（変更なし）
  existingInstall,
}

/// データ移行のためのメインヘルパークラス
/// 
/// このクラスは、WebViewのLocalStorageからSharedPreferencesへのデータ移行を
/// 簡単に実行するためのインターフェイスを提供します。
class DataMigrationHelper {
  // アプリバージョン保存のためのキー
  static const String _versionKey = 'app_version';
  
  // アプリ初回起動フラグのキー
  static const String _firstLaunchKey = 'is_first_launch';
  
  // Angular JSバージョンからのアップデートフラグ
  static const String _updatedFromAngularJSKey = 'updated_from_angular_js';
  
  // チュートリアル完了フラグのキー
  static const String _tutorialCompletedKey = 'tutorial_completed';

  /// アプリの状態を判別
  /// 
  /// 戻り値:
  /// - newInstall: 新規インストール
  /// - updateFromAngularJS: AngularJSバージョンからのアップデート
  /// - normalUpdate: 通常のアップデート
  /// - existingInstall: 既存インストール（変更なし）
  static Future<AppStateType> determineAppState() async {
    final prefs = await SharedPreferences.getInstance();
    final info = await PackageInfo.fromPlatform();
    final currentVersion = info.version;
    
    // 保存されているバージョン情報を取得
    final savedVersion = prefs.getString(_versionKey);
    
    // 初回起動フラグを取得
    final isFirstLaunch = prefs.getBool(_firstLaunchKey) ?? true;
    
    // AngularJSからのアップデートフラグを取得
    final updatedFromAngularJS = prefs.getBool(_updatedFromAngularJSKey) ?? false;
    
    if (isFirstLaunch) {
      // 初回起動時
      
      // LocalStorageにデータがあるかチェック（AngularJSバージョンのデータが存在するか）
      final hasAngularJSData = await _checkForAngularJSData();
      
      if (hasAngularJSData) {
        // AngularJSバージョンからのアップデート
        await prefs.setBool(_updatedFromAngularJSKey, true);
        await prefs.setBool(_firstLaunchKey, false);
        await prefs.setString(_versionKey, currentVersion);
        return AppStateType.updateFromAngularJS;
      } else {
        // 新規インストール
        await prefs.setBool(_firstLaunchKey, false);
        await prefs.setString(_versionKey, currentVersion);
        return AppStateType.newInstall;
      }
    } else if (savedVersion != currentVersion) {
      // バージョンが変わっている場合はアップデート
      await prefs.setString(_versionKey, currentVersion);
      return AppStateType.normalUpdate;
    } else {
      // 既存インストール（変更なし）
      return AppStateType.existingInstall;
    }
  }
  
  /// AngularJSバージョンのデータが存在するかチェック
  static Future<bool> _checkForAngularJSData() async {
    // TODO: 実際の環境に合わせたチェックロジックを実装
    // 例えば、特定のLocalStorageキーの存在確認や、
    // 特定のファイルの存在確認など
    
    // この例では、移行フラグが立っていないことを確認
    final prefs = await SharedPreferences.getInstance();
    final migrationCompleted = prefs.getBool('migration_completed') ?? false;
    final specificOriginMigrationCompleted = 
        prefs.getBool('specific_origin_migration_completed') ?? false;
    
    // WebViewで特定のページにアクセスして確認することも可能
    // ここではシンプルな例として、移行が完了していないことをチェック
    return !migrationCompleted && !specificOriginMigrationCompleted;
  }

  /// メインの処理を実行
  /// 
  /// アプリの状態に応じて、適切な初期化処理を実行します：
  /// - 新規インストール: チュートリアルを表示
  /// - AngularJSからのアップデート: データ移行を実行
  /// - 通常のアップデート: 必要に応じて追加の処理
  /// 
  /// [context] - BuildContext
  /// [oldAppUrl] - 古いバージョンのアプリのURL (指定する場合)
  /// [onNewInstall] - 新規インストール時のコールバック
  /// [onUpdateFromAngularJS] - AngularJSからのアップデート時のコールバック
  /// [onNormalUpdate] - 通常のアップデート時のコールバック
  static Future<void> initializeApp(
    BuildContext context, {
    String? oldAppUrl,
    VoidCallback? onNewInstall,
    VoidCallback? onUpdateFromAngularJS,
    VoidCallback? onNormalUpdate,
  }) async {
    final appState = await determineAppState();
    
    switch (appState) {
      case AppStateType.newInstall:
        // 新規インストールの場合はチュートリアルを表示
        if (onNewInstall != null) {
          onNewInstall();
        }
        break;
        
      case AppStateType.updateFromAngularJS:
        // AngularJSバージョンからのアップデートの場合はデータ移行を実行
        if (context.mounted) {
          final shouldMigrate = await _showMigrationConfirmDialog(context);
          if (shouldMigrate && context.mounted) {
            if (oldAppUrl != null) {
              // 特定のURLからデータを移行
              await SpecificOriginMigration.migrateFromSpecificOrigin(
                context,
                url: oldAppUrl,
              );
            } else {
              // 汎用的な移行処理を実行
              await LocalStorageMigration.migrateFromLocalStorage(context);
            }
            
            // 移行後のコールバックを実行
            if (onUpdateFromAngularJS != null && context.mounted) {
              onUpdateFromAngularJS();
            }
          }
        }
        break;
        
      case AppStateType.normalUpdate:
        // 通常のアップデートの場合の処理
        if (onNormalUpdate != null) {
          onNormalUpdate();
        }
        break;
        
      case AppStateType.existingInstall:
        // 既存インストールの場合は特に何もしない
        break;
    }
  }

  /// チュートリアルが完了したかどうかを確認
  static Future<bool> isTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialCompletedKey) ?? false;
  }
  
  /// チュートリアル完了フラグを設定
  static Future<void> setTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, true);
  }

  /// 移行確認ダイアログを表示
  static Future<bool> _showMigrationConfirmDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('データ移行'),
          content: const Text(
            '以前のバージョンのアプリで保存したデータが見つかりました。\n'
            'このデータを新しいバージョンに移行しますか？'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('いいえ'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('はい'),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }

  /// いずれかの移行が完了しているかチェック
  static Future<bool> _isAnyMigrationCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 各種移行完了フラグをチェック
    final isMigrationCompleted = prefs.getBool('migration_completed') ?? false;
    final isSpecificOriginMigrationCompleted = 
        prefs.getBool('specific_origin_migration_completed') ?? false;
    
    return isMigrationCompleted || isSpecificOriginMigrationCompleted;
  }

  /// 移行完了フラグをリセット（テスト用）
  static Future<void> resetMigrationFlags() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('migration_completed');
    await prefs.remove('specific_origin_migration_completed');
    await prefs.remove(_versionKey);
    await prefs.remove(_firstLaunchKey);
    await prefs.remove(_updatedFromAngularJSKey);
    await prefs.remove(_tutorialCompletedKey);
  }
}

/// Main アプリでの使用例:
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'utils/data_migration_helper.dart';
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
///       title: 'データ移行デモ',
///       home: Builder(
///         builder: (context) {
///           // アプリの起動後に状態に応じた処理を実行
///           WidgetsBinding.instance.addPostFrameCallback((_) {
///             DataMigrationHelper.initializeApp(
///               context,
///               oldAppUrl: 'https://your-old-app-url.com', // 必要に応じて指定
///               onNewInstall: () {
///                 // 新規インストール時の処理（チュートリアル表示など）
///                 Navigator.of(context).pushNamed('/tutorial');
///               },
///               onUpdateFromAngularJS: () {
///                 // AngularJSからのアップデート時の処理
///                 ScaffoldMessenger.of(context).showSnackBar(
///                   const SnackBar(content: Text('データ移行が完了しました')),
///                 );
///               },
///             );
///           });
///           return const HomePage();
///         },
///       ),
///     );
///   }
/// }
/// ``` 