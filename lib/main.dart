import 'package:flutter/material.dart';
import 'package:nailgrow_mobile_app_dev/services/firebase_service.dart';
import 'package:nailgrow_mobile_app_dev/my_app.dart';
import 'package:provider/provider.dart';
import 'package:nailgrow_mobile_app_dev/state/data_provider.dart';
import 'package:nailgrow_mobile_app_dev/state/progress_provider.dart';
import 'package:nailgrow_mobile_app_dev/services/progress_service.dart';
import 'package:nailgrow_mobile_app_dev/screens/splash_screen.dart'; // スプラッシュスクリーンをインポート
import 'package:nailgrow_mobile_app_dev/theme.dart'; // テーマをインポート

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();

  runApp(AppWrapper());
}

class AppWrapper extends StatefulWidget {
  @override
  _AppWrapperState createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  final ProgressService _progressService = ProgressService();
  bool _showSplashScreen = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _printSharedPreferences();

    // 表示時間を1秒に短縮
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _showSplashScreen = false;
      });
    });
  }

  Future<void> _printSharedPreferences() async {
    await _progressService.printSharedPreferences();// ホットリロード時にSharedPreferencesの値をコンソールに出力
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplashScreen) {
      return MaterialApp(
        theme: AppTheme.theme, // テーマを適用
        home: SplashScreen(),
      );
    } else {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DataProvider()),
          ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.theme, // テーマを適用
          home: MyApp(),
        ),
      );
    }
  }
}
