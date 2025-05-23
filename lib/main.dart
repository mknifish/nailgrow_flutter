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
  
  // Firebase初期化とセットアップ
  await _initializeFirebase();
  
  runApp(const AppWrapper());
}

/// Firebase初期化とセットアップを行う
Future<void> _initializeFirebase() async {
  try {
    // すでに初期化されているか確認
    if (Firebase.apps.isEmpty) {
      // 初期化されていない場合は初期化
      final app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized with app: ${app.name}');
    } else {
      print('Firebase already initialized, using existing app: ${Firebase.app().name}');
    }
    
    // FirebaseServiceの状態を更新
    await FirebaseService.checkFirebaseStatus();
    
    // 初期化が完了したか確認
    final isInitialized = FirebaseService.isInitialized;
    print('Firebase initialization complete: $isInitialized');
    
  } catch (e) {
    print('Firebase initialization error: $e');
  }
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
  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? _observer;
  
  static FirebaseAnalytics get analytics {
    if (_analytics == null) {
      _analytics = FirebaseService.analytics;
    }
    return _analytics!;
  }
  
  static FirebaseAnalyticsObserver get observer {
    if (_observer == null) {
      _observer = FirebaseAnalyticsObserver(analytics: analytics);
    }
    return _observer!;
  }

  @override
  void initState() {
    super.initState();
    
    // アプリ起動時にイベントを記録
    _logAppOpen();
  }
  
  // アプリ起動イベントを記録
  Future<void> _logAppOpen() async {
    try {
      await FirebaseService.logEvent(name: 'app_open');
      print('App open event logged through FirebaseService');
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
    // FirebaseAnalyticsObserverのリストを生成（nullセーフに）
    List<NavigatorObserver> observers = [];
    try {
      observers.add(observer);
    } catch (e) {
      print('Failed to add observer: $e');
    }
    
    if (_showSplashScreen) {
      return MaterialApp(
        theme: AppTheme.theme, // テーマを適用
        home: const SplashScreen(),
        navigatorObservers: observers, // Analytics画面トラッキング設定
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
          navigatorObservers: observers, // Analytics画面トラッキング設定
        ),
      );
    }
  }
}
