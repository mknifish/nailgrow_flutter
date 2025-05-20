import 'package:flutter/material.dart';
import 'package:nailgrow_mobile_app_dev/services/preferences_service.dart';
import 'package:nailgrow_mobile_app_dev/screens/set_goal_screen.dart';
import 'package:nailgrow_mobile_app_dev/screens/my_home_page.dart';

// 紹介画面のクラス
class TutorialIntroScreen extends StatelessWidget {
  const TutorialIntroScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFCDC5), // 背景色
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
              const SizedBox(height: 8), // テキスト間の余白
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

// 各ステップの情報を格納するクラス
class TutorialStep {
  final String tooltipText;
  final Positioned tooltipPosition;
  final Positioned? highlightWidget;

  TutorialStep({
    required this.tooltipText,
    required this.tooltipPosition,
    this.highlightWidget,
  });
}

// HomeScreenの上にオーバーレイを表示するチュートリアル画面
class TutorialHomeScreen extends StatefulWidget {
  const TutorialHomeScreen({super.key});

  @override
  _TutorialHomeScreenState createState() => _TutorialHomeScreenState();
}

class _TutorialHomeScreenState extends State<TutorialHomeScreen> {
  int _currentStep = 0;
  final int _totalSteps = 6; // 合計6ステップ

  // 次のステップに進む
  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      // 最後のステップが終わったら、最終チュートリアル画面へ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TutorialScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ベースとなるMyHomePage
          MyHomePage(initialIndex: 0),
          
          // 半透明のグレーオーバーレイ - ステップごとに調整
          Container(
            width: double.infinity,
            height: _currentStep == 5 ? MediaQuery.of(context).size.height - 130 : double.infinity, // タブ説明時のみ下部を除外
            color: Colors.black.withOpacity(0.6),
          ),
          
          // 特定のステップでテキストボックスやドーナツを表示
          if (_currentStep == 1) _getInfoTextBox(), // 目標値と日数の説明
          if (_currentStep == 4) _getProgressDonut(), // 連続達成日数の説明
          
          // 現在のステップに応じた強調ウィジェット
          if (_getHighlightWidget() != null) _getHighlightWidget()!,
          
          // 現在のステップに応じたツールチップ
          _getTooltipWidget(),
          
          // タップで次のステップに進むための透明なGestureDetector
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _nextStep,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 目標値と日数の説明用のテキストボックス
  Widget _getInfoTextBox() {
    return Positioned(
      bottom: 130,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '爪が伸びるスピードは、1日あたり約0.1mm。\n目標達成にむけて、10日間頑張りましょう！',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // 連続達成日数の説明用のドーナツ
  Widget _getProgressDonut() {
    return Positioned(
      top: 217,
      left: 30,
      right: 30,
      child: Container(
        height: 250,
        decoration: const BoxDecoration(
          color: Color(0xFFE0E5EC),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'DAY',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(120, 124, 130, 1),
                ),
              ),
              SizedBox(height: 5),
              Text(
                '1',
                style: TextStyle(
                  fontSize: 115,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(120, 124, 130, 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 現在のステップに応じたツールチップを取得
  Positioned _getTooltipWidget() {
    switch (_currentStep) {
      case 0:
        return Positioned(
          top: 180,
          right: 20,
          child: _buildTooltip(
            '最初に目標値を設定します。\n目標値を変更したいときは、\nこのボタンを押します。',
            TriangleDirection.topRight,
          ),
        );
      case 1:
        return Positioned(
          bottom: 210,
          left: 50,
          right: 50,
          child: _buildTooltip(
            '目標値に合わせて日数が設定されます。',
            TriangleDirection.bottomLeft,
          ),
        );
      case 2:
        return Positioned(
          bottom: 340,
          left: 70,
          child: _buildTooltip(
            '爪を噛まなかったら、\nこちらのWINボタンを。',
            TriangleDirection.bottomLeft,
          ),
        );
      case 3:
        return Positioned(
          bottom: 340,
          right: 40,
          child: _buildTooltip(
            '噛んでしまったら、\nLOSEボタンを押します。',
            TriangleDirection.bottomRight,
          ),
        );
      case 4:
        return Positioned(
          top: 110,
          left: 80,
          right: 60,
          child: _buildTooltip(
            '連続で爪を噛まなかった日数\nがカウントされます。',
            TriangleDirection.bottomLeft,
          ),
        );
      default: // case 5
        return Positioned(
          bottom: 150,
          right: 50,
          child: _buildTooltip(
            '目標達成回数の合計は、\nこちらのタブから確認できます。',
            TriangleDirection.bottomRight,
          ),
        );
    }
  }

  // 現在のステップに応じた強調ウィジェットを取得
  Positioned? _getHighlightWidget() {
    switch (_currentStep) {
      case 0:
        // 設定ボタンを強調表示
        return Positioned(
          top: 110,
          right: 20,
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFE0E5EC),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.settings,
                size: 46,
                color: Colors.grey[700],
              ),
            ),
          ),
        );
      case 1:
        // WINとLOSEボタンの間を強調
        return Positioned(
          bottom: 250,
          left: 70,
          right: 70,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
      case 2:
        // WINボタンを強調表示
        return Positioned(
          bottom: 230,
          left: 55,
          child: Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFE0E5EC),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'WIN',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF09182),
                ),
              ),
            ),
          ),
        );
      case 3:
        // LOSEボタンを強調表示
        return Positioned(
          bottom: 230,
          right: 55,
          child: Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFE0E5EC),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'LOSE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        );
      case 4:
        // 特に強調は不要（ドーナツ自体を表示するため）
        return null;
      case 5:
        // 右下タブ（爪アイコン）の強調表示を削除
        return null;
      default:
        return null;
    }
  }
  
  // ツールチップウィジェットを作成
  Widget _buildTooltip(String text, TriangleDirection direction) {
    Widget triangle = Container();
    CrossAxisAlignment alignment = CrossAxisAlignment.center;
    
    // 方向に応じた三角形と配置を設定
    switch (direction) {
      case TriangleDirection.topRight:
        triangle = Container(
          margin: const EdgeInsets.only(right: 20),
          width: 10,
          height: 10,
          child: CustomPaint(
            painter: TrianglePainter(Colors.white, TriangleDirection.topRight),
          ),
        );
        alignment = CrossAxisAlignment.end;
        break;
      case TriangleDirection.topLeft:
        triangle = Container(
          margin: const EdgeInsets.only(left: 20),
          width: 20,
          height: 15,
          child: CustomPaint(
            painter: TrianglePainter(Colors.white, TriangleDirection.topLeft),
          ),
        );
        alignment = CrossAxisAlignment.start;
        break;
      case TriangleDirection.bottomLeft:
        triangle = Container(
          margin: const EdgeInsets.only(left: 20),
          width: 15,
          height: 10,
          child: CustomPaint(
            painter: TrianglePainter(Colors.white, TriangleDirection.bottomLeft),
          ),
        );
        alignment = CrossAxisAlignment.start;
        break;
      case TriangleDirection.bottomRight:
        triangle = Container(
          margin: const EdgeInsets.only(right: 50),
          width: 15,
          height: 10,
          child: CustomPaint(
            painter: TrianglePainter(Colors.white, TriangleDirection.bottomRight),
          ),
        );
        alignment = CrossAxisAlignment.end;
        break;
    }
    
    // 上または下に三角形を配置
    List<Widget> columnChildren = [];
    if (direction == TriangleDirection.topRight || direction == TriangleDirection.topLeft) {
      columnChildren.add(triangle);
      columnChildren.add(
        Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ),
      );
    } else {
      columnChildren.add(
        Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ),
      );
      columnChildren.add(triangle);
    }
    
    return Column(
      crossAxisAlignment: alignment,
      children: columnChildren,
    );
  }
}

// 三角形を描画するためのカスタムペインター
class TrianglePainter extends CustomPainter {
  final Color color;
  final TriangleDirection direction;
  
  TrianglePainter(this.color, this.direction);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    // 方向に応じたパスを設定
    switch (direction) {
      case TriangleDirection.topRight:
      case TriangleDirection.topLeft:
        // 上向きの三角形
        path.moveTo(0, size.height);  // 左下
        path.lineTo(size.width / 2, 0);  // 上中央
        path.lineTo(size.width, size.height);  // 右下
        break;
      case TriangleDirection.bottomLeft:
      case TriangleDirection.bottomRight:
        // 下向きの三角形
        path.moveTo(0, 0);  // 左上
        path.lineTo(size.width, 0);  // 右上
        path.lineTo(size.width / 2, size.height);  // 下中央
        break;
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(TrianglePainter oldDelegate) => 
      color != oldDelegate.color || direction != oldDelegate.direction;
}

// 矢印方向の列挙型
enum TriangleDirection { topLeft, topRight, bottomLeft, bottomRight }

// 最終チュートリアル画面のクラス
class TutorialScreen extends StatelessWidget {
  final PreferencesService _preferencesService = PreferencesService();

  TutorialScreen({super.key});

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
      backgroundColor: const Color(0xFFFFCDC5),
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
