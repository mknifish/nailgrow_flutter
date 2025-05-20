import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nailgrow_mobile_app_dev/state/data_provider.dart';
import 'set_goal_screen.dart';

class DataScreen extends StatefulWidget {
  final bool fromAchievement;
  
  const DataScreen({super.key, this.fromAchievement = false});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  @override
  void initState() {
    super.initState();
    // 画面表示時に強制的にDataProviderを更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataProvider>(context, listen: false).loadAchievedGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFCDC5),
          body: SafeArea(
            child: Stack(
              children: [
                _buildContentBody(context, dataProvider),
                if (widget.fromAchievement)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SetGoalScreen(
                              isFirstTime: false,
                              fromAchievement: true,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildContentBody(BuildContext context, DataProvider dataProvider) {
    return Column(
      children: [
        // アイコン表示領域（スクロール可能）
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: const Color(0xFFFFCDC5),
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 上部のパディング
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  // アイコン
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 0.0,
                      runSpacing: MediaQuery.of(context).size.height * 0.025,
                      children: List.generate(dataProvider.achievedGoals, (index) {
                        return SizedBox(
                          width: (MediaQuery.of(context).size.width * 0.9) / 5,
                          child: Image.asset(
                            'assets/img/icon_white.png',
                            width: 45,
                            height: 45,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // テキスト表示領域（固定）
        Container(
          width: MediaQuery.of(context).size.width,
          color: const Color(0xFFFFCDC5),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.08,
            top: 20
          ),
          child: Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                children: <TextSpan>[
                  const TextSpan(text: 'これまで'),
                  TextSpan(
                    text: '${dataProvider.achievedGoals}',
                    style: TextStyle(
                      fontSize: 84,
                      fontWeight: FontWeight.bold,
                      color:Colors.grey[700],
                    ),
                  ),
                  const TextSpan(text: ' 回達成！'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
