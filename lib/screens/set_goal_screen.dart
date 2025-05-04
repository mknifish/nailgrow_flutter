import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_home_page.dart';

class SetGoalScreen extends StatefulWidget {
  final bool isFirstTime;

  SetGoalScreen({required this.isFirstTime});

  @override
  _SetGoalScreenState createState() => _SetGoalScreenState();
}

class _SetGoalScreenState extends State<SetGoalScreen> {
  int targetDays = 10; // 初期目標日数

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('目標値を設定する'),
        automaticallyImplyLeading: !widget.isFirstTime,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '目標日数を選択してください',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            DropdownButton<int>(
              value: targetDays,
              items: [10, 20, 30].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value日'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  targetDays = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // 目標日数をShared Preferencesに保存するロジック
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('targetDays', targetDays);
                await prefs.setString('goalSetDate', DateTime.now().toIso8601String());
                // 目標日数を設定した後、HomeScreenの再描画を促す
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(
                      initialIndex: 0,
                      key: UniqueKey(), // 再読み込みを確実にするためのUniqueKey
                    ),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text('START'),
            )
          ],
        ),
      ),
    );
  }
}
