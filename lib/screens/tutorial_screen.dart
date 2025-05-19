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
      backgroundColor: Color(0xFFFFCDC5),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _completeTutorial(context),
        child: Center(
          child: Text(
            'それでは、はじめましょう！',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
