import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:nailgrow_mobile_app_dev/state/progress_provider.dart';
import 'package:nailgrow_mobile_app_dev/state/data_provider.dart';
import 'package:nailgrow_mobile_app_dev/services/dialog_service.dart';
import 'package:nailgrow_mobile_app_dev/screens/data_screen.dart';
import 'my_home_page.dart';

class SetGoalScreen extends StatefulWidget {
  final bool isFirstTime;
  final bool fromAchievement;

  const SetGoalScreen({
    super.key, 
    required this.isFirstTime, 
    this.fromAchievement = false
  });

  @override
  _SetGoalScreenState createState() => _SetGoalScreenState();
}

class _SetGoalScreenState extends State<SetGoalScreen> {
  int targetDays = 1; // 初期目標日数
  final DialogService _dialogService = DialogService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              const Text(
                '今回はどのくらい爪を伸ばしますか？',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(120, 124, 130, 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              _buildNeumorphicDropdown(),
              Expanded(child: Container()),
              _buildNeumorphicButton(
                label: 'START',
                onPressed: () async {
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    
                    // 1mmあたり10日として計算
                    final newTargetDays = targetDays * 10;
                    
                    // 現在の設定を取得
                    final oldGoalSetDate = prefs.getString('goalSetDate');
                    final oldAchievedDays = prefs.getInt('achievedDays') ?? 0;
                    final oldTargetDays = prefs.getInt('targetDays') ?? 0;
                    
                    print('### 処理前の状態 ###');
                    print('isFirstTime（引数）: ${widget.isFirstTime}');
                    print('fromAchievement（引数）: ${widget.fromAchievement}');
                    print('目標設定日: $oldGoalSetDate');
                    print('達成日数: $oldAchievedDays');
                    print('目標日数: $oldTargetDays');
                    
                    // 初めての設定かどうかを判断
                    final bool isNewSetup = oldGoalSetDate == null;
                    
                    // 新しい目標設定日を準備
                    final now = DateTime.now();
                    final newGoalSetDate = now.toIso8601String();
                    
                    // 新規設定または達成後の再設定の場合（達成判定はスキップ）
                    if (isNewSetup || widget.isFirstTime || widget.fromAchievement) {
                      print('新規設定または達成後の再設定を実行（達成判定はスキップ）');
                      
                      // 達成日数を0に、目標設定日を現在時刻に更新
                      await prefs.setInt('achievedDays', 0);
                      await prefs.setString('goalSetDate', newGoalSetDate);
                      await prefs.setInt('targetDays', newTargetDays);
                      
                      // 念のため再度読み込んで確認
                      final checkDate = prefs.getString('goalSetDate');
                      print('更新直後の目標設定日: $checkDate');
                      
                      // ProgressProviderを更新して確実に最新データを取得
                      if (context.mounted) {
                        final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
                        await progressProvider.loadProgress();
                        
                        // ホーム画面に遷移
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyHomePage(
                              initialIndex: 0,
                              key: UniqueKey(),
                            ),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      }
                      return; // 新規設定や達成後の再設定の場合は、以降の達成判定処理をスキップ
                    } else {
                      // 目標変更の場合（途中で目標のみ変更するケース）
                      print('目標変更を実行（達成判定あり）');
                      
                      // 経過日数を計算
                      int currentAchievedDays = 0;
                      final DateTime parsedDate = DateTime.parse(oldGoalSetDate);
                      currentAchievedDays = DateTime.now().difference(parsedDate).inDays;
                      currentAchievedDays = currentAchievedDays < 0 ? 0 : currentAchievedDays;
                                          print('経過日数（計算）: $currentAchievedDays');
                      
                      // 目標日数を更新
                      await prefs.setInt('targetDays', newTargetDays);
                      
                      // 現在の経過日数が新しい目標日数を上回っていれば達成
                      if (currentAchievedDays >= newTargetDays) {
                        print('目標変更で即時達成を判定');
                        
                        // 達成済みならAchievedGoalsをインクリメント
                        int achievedGoals = prefs.getInt('achievedGoals') ?? 0;
                        achievedGoals++;
                        await prefs.setInt('achievedGoals', achievedGoals);
                        
                        // 達成日数を0に、目標設定日を現在時刻に更新
                        await prefs.setInt('achievedDays', 0);
                        await prefs.setString('goalSetDate', newGoalSetDate);
                        
                        // 念のため再度読み込んで確認
                        final checkDate = prefs.getString('goalSetDate');
                        print('達成処理後の目標設定日: $checkDate');
                        
                        // Providerを更新して達成ダイアログを表示
                        if (context.mounted) {
                          // ProgressProviderを更新
                          await Provider.of<ProgressProvider>(context, listen: false).loadProgress();
                          // DataProviderも更新して達成回数を反映
                          await Provider.of<DataProvider>(context, listen: false).loadAchievedGoals();
                          
                          // 達成ダイアログを表示
                          await _dialogService.showWinDialog(context, () async {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DataScreen(fromAchievement: true),
                              ),
                            );
                          });
                          return; // ダイアログを表示後は終了
                        }
                      } else {
                        // 達成していない場合、最新の設定を反映してホーム画面に遷移
                        // ProgressProviderを更新して確実に最新データを取得
                        if (context.mounted) {
                          final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
                          await progressProvider.loadProgress();
                          
                          // ホーム画面に遷移
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyHomePage(
                                initialIndex: 0,
                                key: UniqueKey(),
                              ),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        }
                        return;
                      }
                    }
                    
                    // 設定が最終的に正しく保存されたか確認（このコードは通常実行されません）
                    final verifyGoalSetDate = prefs.getString('goalSetDate');
                    final verifyAchievedDays = prefs.getInt('achievedDays') ?? -1;
                    final verifyTargetDays = prefs.getInt('targetDays') ?? -1;
                    
                    print('### 処理後の最終状態 ###');
                    print('目標設定日: $verifyGoalSetDate');
                    print('達成日数: $verifyAchievedDays');
                    print('目標日数: $verifyTargetDays');
                  } catch (e) {
                    print('設定保存エラー: $e');
                    // エラーが発生した場合でもUIが固まらないように
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('設定の保存中にエラーが発生しました: $e')),
                      );
                    }
                  }
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeumorphicDropdown() {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E5EC),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-3, -3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$targetDays',
                  style: const TextStyle(
                    color: Color.fromRGBO(120, 124, 130, 1),
                    fontSize: 72,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'mm',
                  style: TextStyle(
                    color: Color.fromRGBO(120, 124, 130, 0.7),
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const Positioned(
              right: 0,
              child: Icon(
                Icons.arrow_drop_down,
                color: Color.fromRGBO(120, 124, 130, 0.7),
                size: 36,
              ),
            ),
            Positioned.fill(
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: const Color(0xFFF5F9FC),
                  shadowColor: Colors.transparent,
                  highlightColor: const Color(0xFFE0E5EC).withOpacity(0.3),
                  dividerColor: Colors.transparent,
                  popupMenuTheme: PopupMenuThemeData(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                child: DropdownButton<int>(
                  value: targetDays,
                  icon: const SizedBox.shrink(), // アイコンを非表示にする
                  elevation: 8,
                  underline: Container(height: 0),
                  isExpanded: true,
                  itemHeight: 70,
                  alignment: Alignment.center,
                  dropdownColor: const Color(0xFFF5F9FC),
                  style: const TextStyle(
                    color: Color.fromRGBO(120, 124, 130, 1),
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                  ),
                  items: [1, 2, 3, 4, 5].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFE0E5EC),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$value',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: value == targetDays ? FontWeight.bold : FontWeight.w400,
                                color: const Color.fromRGBO(120, 124, 130, 1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'mm',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: value == targetDays ? FontWeight.bold : FontWeight.w400,
                                color: const Color.fromRGBO(120, 124, 130, 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return [1, 2, 3, 4, 5].map<Widget>((int value) {
                      return Container();
                    }).toList();
                  },
                  onChanged: (int? newValue) {
                    setState(() {
                      targetDays = newValue!;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeumorphicButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E5EC),
            shape: BoxShape.circle,
            boxShadow: [
              const BoxShadow(
                color: Colors.white,
                offset: Offset(-4, -4),
                blurRadius: 8,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(4, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(120, 124, 130, 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
