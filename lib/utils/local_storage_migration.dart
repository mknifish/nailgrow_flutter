import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LocalStorageMigration {
  /// WebViewのLocalStorageからデータを取得してSharedPreferencesに保存する
  static Future<void> migrateFromLocalStorage(BuildContext context) async {
    // マイグレーションが既に完了しているか確認
    final isCompleted = await isMigrationCompleted();
    if (isCompleted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('データの移行は既に完了しています')),
        );
      }
      return;
    }

    // コントローラーを作成
    final controller = WebViewController();
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.loadRequest(Uri.parse('about:blank'));
    
    // ナビゲーションデリゲートを設定
    controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (String url) async {
          // JavaScriptを実行してLocalStorageのデータを取得
          final result = await _getLocalStorageData(controller);
          
          // データを保存
          if (result != null) {
            await _saveToSharedPreferences(result);
            
            // 完了フラグを設定
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('migration_completed', true);
            
            // ダイアログを閉じる
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('データの移行が完了しました')),
              );
            }
          } else {
            // エラー処理
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('データの移行中にエラーが発生しました')),
              );
            }
          }
        },
      ),
    );

    // 不可視WebViewをダイアログで表示
    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('データ移行中...'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 10),
                const Text('旧バージョンのデータを移行しています'),
                SizedBox(
                  width: 1,
                  height: 1,
                  child: WebViewWidget(controller: controller),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  /// LocalStorageからデータを取得するJavaScriptを実行
  static Future<Map<String, dynamic>?> _getLocalStorageData(WebViewController controller) async {
    try {
      const script = '''
        var items = {};
        for (var i = 0; i < localStorage.length; i++) {
          var key = localStorage.key(i);
          var value = localStorage.getItem(key);
          items[key] = value;
        }
        JSON.stringify(items);
      ''';

      final result = await controller.runJavaScriptReturningResult(script);
      // 結果は通常 "{"key":"value"}" のような文字列なので、適切にパースする
      final jsonStr = result.toString().replaceAll('"', '').replaceAll('\\', '');
      if (jsonStr.isEmpty || jsonStr == '{}') {
        return {}; // データがない場合は空のMapを返す
      }
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('LocalStorage取得エラー: $e');
      return null;
    }
  }

  /// SharedPreferencesにデータを保存
  static Future<void> _saveToSharedPreferences(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    
    for (var entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      
      try {
        // 数値の場合
        final num? numValue = num.tryParse(value.toString());
        if (numValue != null) {
          if (numValue is int) {
            await prefs.setInt(key, numValue);
          } else {
            await prefs.setDouble(key, numValue.toDouble());
          }
          continue;
        }
        
        // 真偽値の場合
        if (value.toString().toLowerCase() == 'true') {
          await prefs.setBool(key, true);
          continue;
        } else if (value.toString().toLowerCase() == 'false') {
          await prefs.setBool(key, false);
          continue;
        }
        
        // それ以外は文字列として保存
        await prefs.setString(key, value.toString());
      } catch (e) {
        debugPrint('SharedPreferences保存エラー - キー: $key, エラー: $e');
      }
    }
  }

  /// マイグレーションが完了しているかチェック
  static Future<bool> isMigrationCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('migration_completed') ?? false;
  }
} 