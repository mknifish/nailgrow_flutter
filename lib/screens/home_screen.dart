import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nailgrow_mobile_app_dev/services/home_service.dart';
import 'package:nailgrow_mobile_app_dev/state/progress_provider.dart';
import 'set_goal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeService _homeService = HomeService();

  @override
  void initState() {
    super.initState();
    _homeService.loadPreferences(
      onLoaded: (loadedTargetDays, loadedAchievedGoals, loadedAchievedDays) {
        // ここでProgressProviderを更新
        Provider.of<ProgressProvider>(context, listen: false).loadProgress();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        double progress = progressProvider.progress.progress;
        // remainingDaysをProviderの値に基づいて計算
        int remainingDays = (progressProvider.progress.targetDays) - progressProvider.progress.achievedDays;
        
        // ローカルの状態変数は不要になるため削除
        // int remainingDays = (targetDays ?? 0) - achievedDays;

        return Scaffold(
          backgroundColor: const Color(0xFFE0E5EC),
          appBar: _buildAppBar(context),
          body: _buildBody(context, progressProvider, progress, remainingDays),
        );
      },
    );
  }

  // AppBarのビルド
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFE0E5EC),
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 72,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: _buildNeumorphicIconButton(
            icon: Icons.settings,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SetGoalScreen(isFirstTime: false),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // メインボディのビルド
  Widget _buildBody(BuildContext context, ProgressProvider progressProvider, double progress, int remainingDays) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProgressIndicator(progressProvider, progress),
            const SizedBox(height: 16),
            _buildActionButtons(context, progressProvider),
            const SizedBox(height: 60),
            Text(
              '目標まで${(remainingDays / 10).toStringAsFixed(1)}mm、残り$remainingDays 日です！',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ニューモーフィズム風ドーナツ型プログレスインジケータ
  Widget _buildProgressIndicator(ProgressProvider progressProvider, double progress) {
    const double outerRadius = 330;
    const double outerStrokeWidth = 33;
    const double progressStrokeWidth = 33;
    const double innerRadius = 230;

    return SizedBox(
      width: outerRadius,
      height: outerRadius,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 外側のドーナツ
          SizedBox(
            width: outerRadius,
            height: outerRadius,
            child: CustomPaint(
              painter: NeumorphicInsetDonutPainter(
                thickness: outerStrokeWidth,
                baseColor: const Color(0xFFE0E5EC),
                shadowColor: Colors.black,
                highlightColor: Colors.white,
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
                backgroundColor: const Color(0xFFD1D9E6),
                gradient: const LinearGradient(
                  colors: [Color.fromARGB(255, 245, 233, 224), Color.fromARGB(255, 241, 168, 165)],
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
              color: const Color(0xFFE0E5EC),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  offset: const Offset(-5, -5),
                  blurRadius: 8,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(5, 5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          // 中央のテキスト
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'DAY',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(120, 124, 130, 1),
                  ),
                ),
                Text(
                  '${progressProvider.progress.achievedDays}',
                  style: const TextStyle(
                    fontSize: 115,
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

  // WIN/LOSEボタンの行
  Widget _buildActionButtons(BuildContext context, ProgressProvider progressProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNeumorphicButton(
          label: 'WIN',
          onPressed: () async {
            await _homeService.handleWinButtonPressed(context, progressProvider.progress.targetDays, progressProvider.progress.achievedDays);
          },
          color: const Color(0xFFF09182),
        ),
        const SizedBox(width: 101),
        _buildNeumorphicButton(
          label: 'LOSE',
          onPressed: () async {
            await _homeService.handleLoseButtonPressed(context);
          },
        ),
      ],
    );
  }

  // ニューモーフィックなアイコンボタン
  Widget _buildNeumorphicIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E5EC),
          shape: BoxShape.circle,
          boxShadow: [
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-3, -3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 46,
            color: color ?? Colors.grey[700],
          ),
        ),
      ),
    );
  }

  // ニューモーフィックな丸ボタン
  Widget _buildNeumorphicButton({
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E5EC),
          shape: BoxShape.circle,
          boxShadow: [
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-3, -3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 20,
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

class NeumorphicInsetDonutPainter extends CustomPainter {
  final double thickness;
  final Color baseColor;
  final Color shadowColor;
  final Color highlightColor;

  NeumorphicInsetDonutPainter({
    required this.thickness,
    required this.baseColor,
    required this.shadowColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - thickness / 2,
    );

    // 内側シャドウ
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [shadowColor.withOpacity(0.18), Colors.transparent],
        stops: const [0.7, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;

    // 内側ハイライト
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [highlightColor.withOpacity(0.35), Colors.transparent],
        stops: const [0.0, 0.8],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;

    // ベース
    final basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;

    // 1. ベース
    canvas.drawArc(rect, 0, 2 * 3.14159, false, basePaint);
    // 2. シャドウ（下側）
    canvas.saveLayer(rect, Paint());
    canvas.drawArc(rect, 0, 2 * 3.14159, false, shadowPaint);
    canvas.restore();
    // 3. ハイライト（上側）
    canvas.saveLayer(rect, Paint());
    canvas.drawArc(rect, 0, 2 * 3.14159, false, highlightPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
