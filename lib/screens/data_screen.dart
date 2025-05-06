import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nailgrow_mobile_app_dev/state/data_provider.dart';

class DataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(''), // AppBarのタイトルを削除
            backgroundColor: Color(0xFFFFCDC5), // 直接色を指定
          ),
          body: Center(
            child: Container(
              color: Color(0xFFFFCDC5), // 背景色を指定
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: List.generate(dataProvider.achievedGoals, (index) {
                        return Image.asset(
                          'assets/img/icon_white.png',
                          width: 30,
                          height: 30,
                        );
                      }),
                    ),
                    SizedBox(height: 20), // スペース
                    Text(
                      'これまで${dataProvider.achievedGoals} 回達成！', // テキストを修正
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
