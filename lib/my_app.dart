import 'package:flutter/material.dart';
import 'package:nailgrow_mobile_app_dev/screens/my_home_page.dart';
import 'package:nailgrow_mobile_app_dev/screens/tutorial_screen.dart';
import 'package:nailgrow_mobile_app_dev/services/preferences_service.dart';
import 'package:nailgrow_mobile_app_dev/screens/test_data_screen.dart';
import 'package:nailgrow_mobile_app_dev/theme.dart'; // テーマをインポート

class MyApp extends StatelessWidget {
  final PreferencesService _preferencesService = PreferencesService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _preferencesService.isTutorialCompleted(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            theme: AppTheme.theme, // テーマを適用
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          return MaterialApp(
            theme: AppTheme.theme, // テーマを適用
            home: TutorialScreen(), // 一時的にチュートリアルを常に表示
            routes: {
              '/test': (context) => TestDataScreen(),
            },
          );
        }
      },
    );
  }
}
