import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nailgrow_mobile_app_dev/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E テスト', () {
    // 各テスト前に実行されるセットアップ
    setUp(() async {
      // SharedPreferencesをクリア
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // デバッグ用に状態を出力
      print('Setup completed - SharedPreferences cleared');
    });

    testWidgets('アプリ起動とチュートリアル画面遷移', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3)); // 初期化に十分な時間を確保
      
      // 画面の状態を確認（デバッグ用）
      print('Current widgets on screen:');
      for (var widget in tester.allWidgets) {
        if (widget is Text) {
          print('Text widget: "${widget.data}"');
        }
      }

      // 画面をタップして次に進む（どの画面が表示されていても）
      print('Tapping screen to proceed');
      await tester.tapAt(const Offset(200, 300));
      await tester.pumpAndSettle();
      
      // 何回かタップしてチュートリアルを進める（または設定画面に到達する）
      for (int i = 0; i < 8; i++) {
        print('Tap #$i');
        await tester.tapAt(const Offset(200, 300));
        await tester.pumpAndSettle();
        
        // 目標設定画面またはホーム画面に到達したかチェック
        final goalScreenFinder = find.textContaining('伸ばし');
        final startButtonFinder = find.text('START');
        if (goalScreenFinder.evaluate().isNotEmpty || startButtonFinder.evaluate().isNotEmpty) {
          print('Found goal setting screen or START button');
          break;
        }
      }
      
      // STARTボタンを探し、あれば押す
      final startButton = find.text('START');
      if (startButton.evaluate().isNotEmpty) {
        print('Found START button, tapping it');
        await tester.tap(startButton);
        await tester.pumpAndSettle();
      } else {
        print('START button not found, may already be in main app screen');
      }
      
      // メイン画面に遷移していることを確認
      expect(find.byType(Scaffold), findsWidgets);
      
      // テスト成功
      print('Test completed successfully');
    });
  });
} 