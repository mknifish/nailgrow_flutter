import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseService {
  static bool _initialized = false;
  static FirebaseAnalytics? _analytics;
  static FirebaseApp? _app;
  
  /// Firebaseの初期化状態を取得
  static bool get isInitialized {
    _checkInitialization();
    return _initialized;
  }
  
  /// 内部的な初期化状態チェック
  static void _checkInitialization() {
    _initialized = Firebase.apps.isNotEmpty;
    if (_initialized && _app == null) {
      _app = Firebase.app();
    }
  }
  
  /// Firebase Analyticsインスタンスを取得
  static FirebaseAnalytics get analytics {
    if (_analytics == null && isInitialized) {
      try {
        _analytics = FirebaseAnalytics.instance;
        print('Firebase Analytics instance created');
      } catch (e) {
        print('Firebase Analytics initialization error: $e');
      }
    }
    return _analytics ?? FirebaseAnalytics.instance;
  }

  /// Firebaseのステータスをチェックして初期化処理を完了
  static Future<void> checkFirebaseStatus() async {
    try {
      _checkInitialization();
      
      if (_initialized) {
        print('Firebase is initialized with ${Firebase.apps.length} app(s)');
        
        // Firebase Analyticsの設定
        try {
          _analytics = FirebaseAnalytics.instance;
          await _analytics?.setAnalyticsCollectionEnabled(true);
          print('Firebase Analytics initialized and enabled');
        } catch (e) {
          print('Failed to initialize Firebase Analytics: $e');
        }
      } else {
        print('Firebase is not initialized');
      }
    } catch (e) {
      print('Firebase status check error: $e');
    }
  }
  
  /// カスタムイベントを記録
  static Future<void> logEvent({
    required String name, 
    Map<String, dynamic>? parameters,
  }) async {
    try {
      _checkInitialization();
      if (_initialized) {
        await analytics.logEvent(name: name, parameters: parameters);
        print('Event logged: $name with params: $parameters');
      } else {
        print('Firebase not initialized, cannot log event: $name');
      }
    } catch (e) {
      print('Failed to log event $name: $e');
    }
  }
  
  /// WINボタンクリックイベントを記録
  static Future<void> logWinButtonClick() async {
    try {
      await logEvent(name: 'win_button_click');
    } catch (e) {
      print('Failed to log win button click: $e');
    }
  }
  
  /// LOSEボタンクリックイベントを記録
  static Future<void> logLoseButtonClick() async {
    try {
      await logEvent(name: 'lose_button_click');
    } catch (e) {
      print('Failed to log lose button click: $e');
    }
  }
  
  /// 目標達成イベントを記録
  static Future<void> logGoalAchieved(int days) async {
    try {
      await logEvent(
        name: 'goal_achieved',
        parameters: {'days': days},
      );
    } catch (e) {
      print('Failed to log goal achieved: $e');
    }
  }
  
  /// 目標設定イベントを記録
  static Future<void> logGoalSet(int targetDays) async {
    try {
      await logEvent(
        name: 'goal_set',
        parameters: {'target_days': targetDays},
      );
    } catch (e) {
      print('Failed to log goal set: $e');
    }
  }
  
  /// 画面表示イベントを記録
  static Future<void> logScreenView(String screenName) async {
    try {
      _checkInitialization();
      if (_initialized) {
        await analytics.setCurrentScreen(screenName: screenName);
        print('Screen view logged: $screenName');
      } else {
        print('Firebase not initialized, cannot log screen view: $screenName');
      }
    } catch (e) {
      print('Failed to log screen view $screenName: $e');
    }
  }
}
