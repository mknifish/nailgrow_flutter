import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFFFCDC5), // 背景色を設定 (薄いピンク色)
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'nailgrow', // ロゴのテキスト
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20), // テキストとアイコンの間にスペースを追加
              Image.asset(
                'assets/img/icon_white.png',
                width: 50,
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
