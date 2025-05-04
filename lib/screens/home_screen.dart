import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nailgrow_mobile_app_dev/services/home_service.dart';
import 'package:nailgrow_mobile_app_dev/state/progress_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeService _homeService = HomeService();
  int? targetDays;
  int achievedDays = 0;
  int achievedGoals = 0;

  @override
  void initState() {
    super.initState();
    _homeService.loadPreferences(
      onLoaded: (loadedTargetDays, loadedAchievedGoals, loadedAchievedDays) {
        setState(() {
          targetDays = loadedTargetDays;
          achievedGoals = loadedAchievedGoals;
          achievedDays = loadedAchievedDays;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        double progress = progressProvider.progress.progress;
        // 残り日数を計算
        int remainingDays = (targetDays ?? 0) - achievedDays;

        return Scaffold(
          backgroundColor: Color(0xFFE0E5EC),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProgressIndicator(progressProvider, progress),
                  SizedBox(height: 20),
                  _buildActionButtons(context, progressProvider),
                  SizedBox(height: 20),
                  Text(
                    '目標達成に向けて、残り$remainingDays 日間頑張りましょう！',
                    style: TextStyle(
                      fontSize: 14, // 文字サイズを半分程度に調整
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

Widget _buildProgressIndicator(ProgressProvider progressProvider, double progress) {
  const double outerRadius = 300; // 外側円の直径（1.5倍に拡大）
  const double outerStrokeWidth = 30; // 外側円の厚さ（拡大）
  const double progressStrokeWidth = 30; // プログレスバーの太さ（拡大）
  const double innerRadius = 210; // 内側円の直径（拡大）

  return Container(
    width: outerRadius,
    height: outerRadius,
    child: Stack(
      alignment: Alignment.center,
      children: [
        // 外側のドーナツ（立体的）
        SizedBox(
          width: outerRadius,
          height: outerRadius,
          child: CustomPaint(
            painter: NeumorphicDonutPainter(
              thickness: outerStrokeWidth,
              baseColor: Color(0xFFE0E5EC),
              shadowColor: Colors.black.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        // プログレスバー
        SizedBox(
          width: outerRadius - outerStrokeWidth,
          height: outerRadius - outerStrokeWidth,
          child: CustomPaint(
            painter: GradientProgressPainter(
              progress: progress.isFinite ? progress : 0.0,
              backgroundColor: Color(0xFFD1D9E6), // トラックの背景色
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 245, 233, 224), Color.fromARGB(255, 241, 168, 165)], // 根本と先端の色
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              strokeWidth: progressStrokeWidth,
            ),
          ),
        ),
        // 内側の円
        Container(
          width: innerRadius,
          height: innerRadius,
          decoration: BoxDecoration(
            color: Color(0xFFE0E5EC),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                offset: Offset(-5, -5),
                blurRadius: 8,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(5, 5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        // テキスト
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'DAY',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.normal,
                  color: Color.fromRGBO(120, 124, 130, 1),
                ),
              ),
              Text(
                '${progressProvider.progress.achievedDays}',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(120, 124, 130, 1),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}




  Widget _buildActionButtons(BuildContext context, ProgressProvider progressProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNeumorphicButton(
          label: 'WIN',
          onPressed: () async {
            await _homeService.handleWinButtonPressed(context, targetDays, achievedDays);
          },
          color: Color(0xFFF09182),
        ),
        SizedBox(width: 20),
        _buildNeumorphicButton(
          label: 'LOSE',
          onPressed: () async {
            await _homeService.handleLoseButtonPressed(context);
          },
        ),
      ],
    );
  }

  Widget _buildNeumorphicButton({
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Color(0xFFE0E5EC),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white,
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
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}

class RoundedProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;
  final double cornerRadius;

  RoundedProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - strokeWidth / 2,
    );

    // 背景を描画
    canvas.drawArc(rect, 0, 2 * 3.14159, false, backgroundPaint);

    // 進捗を描画
    canvas.drawArc(rect, -3.14159 / 2, progress * 2 * 3.14159, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class OuterCirclePainterNoShadow extends CustomPainter {
  final double strokeWidth;
  final Color color;

  OuterCirclePainterNoShadow({
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Rect rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // 外側円
    canvas.drawArc(rect, 0, 2 * 3.14159, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class GradientProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final LinearGradient gradient;
  final double strokeWidth;

  GradientProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.gradient,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Paint progressPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - strokeWidth / 2,
    );

    // トラックの背景を描画
    canvas.drawArc(rect, 0, 2 * 3.14159, false, backgroundPaint);

    // プログレスバーを描画
    canvas.drawArc(rect, -3.14159 / 2, progress * 2 * 3.14159, false, progressPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ThickDonutPainter extends CustomPainter {
  final double thickness;
  final Color color;

  ThickDonutPainter({
    required this.thickness,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;

    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - thickness / 2,
    );

    // ドーナツ状の円を描画
    canvas.drawArc(rect, 0, 2 * 3.14159, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class NeumorphicDonutPainter extends CustomPainter {
  final double thickness;
  final Color baseColor;
  final Color shadowColor;
  final Color highlightColor;

  NeumorphicDonutPainter({
    required this.thickness,
    required this.baseColor,
    required this.shadowColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;

    final Paint shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10); // シャドウをさらにぼかす

    final Paint highlightPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30); // ハイライトを強調

    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - thickness / 2,
    );

    // シャドウを描画
    canvas.drawArc(
      rect,
      3.14159 / 3, // シャドウ位置
      2 * 3.14159, // 全周
      false,
      shadowPaint,
    );

    // ハイライトを描画
    canvas.drawArc(
      rect,
      -3.14159 / 3, // ハイライト位置
      2 * 3.14159, // 全周
      false,
      highlightPaint,
    );

    // ドーナツ本体を描画
    canvas.drawArc(rect, 0, 2 * 3.14159, false, basePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
