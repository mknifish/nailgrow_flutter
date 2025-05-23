import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static bool _initialized = false;
  
  /// Firebaseの初期化が完了しているかどうかを確認します
  static bool get isInitialized => _initialized || Firebase.apps.isNotEmpty;

  /// Firebaseのステータスをチェックします（初期化は行いません）
  static Future<void> checkFirebaseStatus() async {
    _initialized = Firebase.apps.isNotEmpty;
    print('Firebase apps count: ${Firebase.apps.length}');
  }
}
