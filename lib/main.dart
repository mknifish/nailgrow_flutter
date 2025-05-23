import 'package:flutter/material.dart';
import 'package:nailgrow_mobile_app_dev/my_app.dart';
import 'package:provider/provider.dart';
import 'package:nailgrow_mobile_app_dev/state/data_provider.dart';
import 'package:nailgrow_mobile_app_dev/state/progress_provider.dart';
import 'package:nailgrow_mobile_app_dev/services/progress_service.dart';
import 'package:nailgrow_mobile_app_dev/screens/splash_screen.dart'; // スプラッシュスクリーンをインポート
import 'package:nailgrow_mobile_app_dev/theme.dart'; // テーマをインポート
import 'package:nailgrow_mobile_app_dev/services/firebase_service.dart'; // Firebaseサービスをインポート
import 'package:firebase_core/firebase_core.dart'; // Firebase初期化用
import 'package:firebase_analytics/firebase_analytics.dart'; // Firebase Analytics用
import 'firebase_options.dart'; // Firebase設定

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Firebase初期化
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // FirebaseServiceのステータスをチェック
    await FirebaseService.checkFirebaseStatus();
    print('Firebase status checked: ${FirebaseService.isInitialized}');
    print('Firebase Analytics initialized');
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(const AppWrapper());
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  _AppWrapperState createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  final ProgressService _progressService = ProgressService();
  bool _showSplashScreen = true;
  
  // Firebase Analytics インスタンス
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  void initState() {
    super.initState();
    
    // アプリ起動時にイベントを記録
    _logAppOpen();
  }
  
  // アプリ起動イベントを記録
  Future<void> _logAppOpen() async {
    try {
      await analytics.logAppOpen();
      print('App open event logged');
    } catch (e) {
      print('Failed to log app open event: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _printSharedPreferences();

    // 表示時間を1秒に短縮
    Future.delayed(const Duration(seconds: 1), () {
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
        home: const SplashScreen(),
        navigatorObservers: [observer], // Analytics画面トラッキング設定
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
          navigatorObservers: [observer], // Analytics画面トラッキング設定
        ),
      );
    }
  }
}
