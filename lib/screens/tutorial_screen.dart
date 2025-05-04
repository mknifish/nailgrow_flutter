import 'package:flutter/material.dart';
import 'package:nailgrow_mobile_app_dev/services/preferences_service.dart';
import 'package:nailgrow_mobile_app_dev/screens/set_goal_screen.dart';

class TutorialScreen extends StatelessWidget {
  final PreferencesService _preferencesService = PreferencesService();

  Future<void> _completeTutorial(BuildContext context) async {
    await _preferencesService.setTutorialCompleted();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SetGoalScreen(isFirstTime: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('チュートリアル'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('これはチュートリアル画面です。'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _completeTutorial(context),
              child: Text('チュートリアルを完了'),
            ),
          ],
        ),
      ),
    );
  }
}
