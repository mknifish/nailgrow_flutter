import 'package:flutter/material.dart';
import 'package:nailgrow_mobile_app_dev/services/preferences_service.dart';
import 'package:nailgrow_mobile_app_dev/screens/set_goal_screen.dart';
import 'package:nailgrow_mobile_app_dev/screens/my_home_page.dart';

// 紹介画面のクラス
class TutorialIntroScreen extends StatelessWidget {
  final PreferencesService _preferencesService = PreferencesService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFCDC5), // 背景色
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, // 画面全体をタップ可能に
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TutorialHomeScreen(), // 次の画面へ遷移
            ),
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'nailgrowへようこそ！',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8), // テキスト間の余白
              Text(
                'まずは使い方をご説明します。',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// HomeScreenの上にオーバーレイを表示するチュートリアル画面
class TutorialHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ベースとなるMyHomePage（ボトムナビゲーションバーを含む）
          MyHomePage(initialIndex: 0),
          
          // 半透明のグレーオーバーレイ
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.6),
          ),
          
          // 設定ボタンの位置に重ねて表示する強調ボタン
          Positioned(
            top: 120, // AppBarの高さ
            right: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFFE0E5EC),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    offset: Offset(-3, -3),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(3, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.settings,
                  size: 46,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
          
          // 設定ボタンの位置に合わせた説明ツールチップ
          Positioned(
            top: 200,
            right: 40,
            child: _buildTooltip(
              '最初に目標値を設定します。\n目標値を変更したいときは、\nこのボタンを押します。',
              TriangleDirection.topRight,
            ),
          ),
          
          // タップで次の画面に進むための透明なGestureDetector
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TutorialScreen(),
                  ),
                );
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // ツールチップウィジェットを作成
  Widget _buildTooltip(String text, TriangleDirection direction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 矢印（上向き）
        Container(
          margin: EdgeInsets.only(right: 20),  // 矢印の位置調整
          width: 20,
          height: 15,
          child: CustomPaint(
            painter: TrianglePainter(Colors.white),
          ),
        ),
        // ツールチップ本体
        Container(
          width: 300,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 三角形を描画するためのカスタムペインター
class TrianglePainter extends CustomPainter {
  final Color color;
  
  TrianglePainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    // 上向きの三角形
    path.moveTo(0, size.height);  // 左下
    path.lineTo(size.width / 2, 0);  // 上中央
    path.lineTo(size.width, size.height);  // 右下
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(TrianglePainter oldDelegate) => color != oldDelegate.color;
}

// 矢印方向の列挙型
enum TriangleDirection { topLeft, topRight, bottomLeft, bottomRight }

// 最終チュートリアル画面のクラス
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
