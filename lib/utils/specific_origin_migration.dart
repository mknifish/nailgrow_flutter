import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 特定のアプリURLからLocalStorageデータを移行するユーティリティ
class SpecificOriginMigration {
  /// 特定のURLからLocalStorageデータを取得してSharedPreferencesに保存
  static Future<void> migrateFromSpecificOrigin(
    BuildContext context, {
    required String url,
    String migrationCompletedKey = 'specific_origin_migration_completed',
    Function(Map<String, dynamic>)? onDataReceived,
  }) async {
    // 移行が既に完了しているか確認
    final isCompleted = await _isMigrationCompleted(migrationCompletedKey);
    if (isCompleted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('指定サイトからのデータ移行は既に完了しています')),
        );
      }
      return;
    }

    // コントローラーを作成
    final controller = WebViewController();
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    
    // JavaScriptチャネルを作成
    // これにより、JavaScriptからFlutterにデータを送信できる
    controller.addJavaScriptChannel(
      'FlutterChannel',
      onMessageReceived: (JavaScriptMessage message) async {
        try {
          // JavaScriptから受け取ったデータを処理
          final data = jsonDecode(message.message) as Map<String, dynamic>;
          
          // カスタムデータ変換処理が指定されている場合はそれを実行
          if (onDataReceived != null) {
            onDataReceived(data);
          } else {
            // デフォルトの処理：SharedPreferencesに保存
            await _saveToSharedPreferences(data);
          }
          
          // 完了フラグを設定
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(migrationCompletedKey, true);
          
          // ダイアログを閉じる
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('データの移行が完了しました')),
            );
          }
        } catch (e) {
          debugPrint('データ処理エラー: $e');
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('データの移行中にエラーが発生しました')),
            );
          }
        }
      },
    );

    // ナビゲーションデリゲートを設定
    controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (String loadedUrl) async {
          // ページが読み込まれたらLocalStorageデータを取得するJavaScriptを実行
          await controller.runJavaScript('''
            try {
              var items = {};
              for (var i = 0; i < localStorage.length; i++) {
                var key = localStorage.key(i);
                var value = localStorage.getItem(key);
                items[key] = value;
              }
              
              // データをFlutterに送信
              if (Object.keys(items).length > 0) {
                FlutterChannel.postMessage(JSON.stringify(items));
              } else {
                // データがない場合は空のオブジェクトを送信
                FlutterChannel.postMessage('{}');
              }
            } catch (e) {
              console.error('Error getting localStorage data:', e);
              FlutterChannel.postMessage('{"error": "' + e.toString() + '"}');
            }
          ''');
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('WebViewエラー: ${error.description}');
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ページ読み込みエラー: ${error.description}')),
            );
          }
        },
      ),
    );

    // 指定URLを読み込み
    controller.loadRequest(Uri.parse(url));

    // WebViewをダイアログで表示
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
                // WebViewは表示しないようにする（セキュリティ上の理由から）
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

  /// SharedPreferencesにデータを保存
  static Future<void> _saveToSharedPreferences(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    
    // エラーメッセージがある場合は処理を中断
    if (data.containsKey('error')) {
      debugPrint('JavaScriptエラー: ${data['error']}');
      return;
    }
    
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

  /// 移行が完了しているかチェック
  static Future<bool> _isMigrationCompleted(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  /// 使用例：特定のURLからデータを移行
  static void showMigrationDialog(BuildContext context, {
    required String url,
    Function(Map<String, dynamic>)? onDataReceived,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('旧バージョンからのデータ移行'),
          content: const Text('以前のバージョンのアプリからデータを移行しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 実際のアプリのURLを指定
                migrateFromSpecificOrigin(
                  context,
                  url: url,
                  onDataReceived: onDataReceived,
                );
              },
              child: const Text('移行する'),
            ),
          ],
        );
      },
    );
  }
} 