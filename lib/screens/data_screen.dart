import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nailgrow_mobile_app_dev/state/data_provider.dart';
import 'set_goal_screen.dart';

class DataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SetGoalScreen(isFirstTime: false),
          ),
        );
      },
      child: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          return Scaffold(
            backgroundColor: Color(0xFFFFCDC5),
            body: SafeArea(
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Color(0xFFFFCDC5),
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 0.0,
                          runSpacing: MediaQuery.of(context).size.height * 0.025,
                          children: List.generate(dataProvider.achievedGoals, (index) {
                            return Container(
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
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(fontSize: 20, color: Colors.grey[700],),
                            children: <TextSpan>[
                              TextSpan(text: 'これまで'),
                              TextSpan(
                                text: '${dataProvider.achievedGoals}',
                                style: TextStyle(
                                  fontSize: 84,
                                  fontWeight: FontWeight.bold,
                                  color:Colors.grey[700],
                                ),
                              ),
                              TextSpan(text: ' 回達成！'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
