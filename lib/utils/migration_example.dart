import 'package:flutter/material.dart';
import 'local_storage_migration.dart';

/// アプリケーションの初期化時にデータ移行をチェックする例
class MigrationHelper {
  /// アプリの起動時にデータ移行が必要かチェックして実行する
  static Future<void> checkAndMigrateData(BuildContext context) async {
    // 移行が完了しているかチェック
    final isCompleted = await LocalStorageMigration.isMigrationCompleted();
    
    if (!isCompleted) {
      // 移行が完了していない場合、確認ダイアログを表示
      if (context.mounted) {
        final shouldMigrate = await _showMigrationConfirmDialog(context);
        if (shouldMigrate && context.mounted) {
          // ユーザーが同意した場合、データ移行を実行
          await LocalStorageMigration.migrateFromLocalStorage(context);
        }
      }
    }
  }

  /// データ移行の確認ダイアログを表示
  static Future<bool> _showMigrationConfirmDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('データ移行'),
          content: const Text(
            '以前のバージョンのアプリで保存されたデータを見つけました。\n'
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
}

/// 使用例：アプリの起動時に呼び出す
///
/// ```dart
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
///       home: Builder(
///         builder: (context) {
///           // アプリ起動後にデータ移行をチェック
///           WidgetsBinding.instance.addPostFrameCallback((_) {
///             MigrationHelper.checkAndMigrateData(context);
///           });
///           return const HomePage();
///         },
///       ),
///     );
///   }
/// }
/// ``` 