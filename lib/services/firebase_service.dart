import 'package:firebase_core/firebase_core.dart';
import 'package:nailgrow_mobile_app_dev/firebase_options.dart';

class FirebaseService {
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
