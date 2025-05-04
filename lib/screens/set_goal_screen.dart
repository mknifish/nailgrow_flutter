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
  int targetLength = 1; // 初期目標長さ (mm)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0E5EC), // ニューモーフィズムの背景色
      appBar: AppBar(
        backgroundColor: Color(0xFFE0E5EC),
        elevation: 0,
        automaticallyImplyLeading: !widget.isFirstTime,
        iconTheme: IconThemeData(
          color: Color.fromRGBO(120, 124, 130, 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '今日はどのくらい爪を伸ばしますか？',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(120, 124, 130, 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 60),
            _buildNeumorphicDropdown(),
            SizedBox(height: 100),
            _buildNeumorphicButton(
              label: 'START',
              onPressed: () async {
                // 目標日数をShared Preferencesに保存するロジック
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('targetLength', targetLength);
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
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNeumorphicDropdown() {
    return Center(
      child: Container(
        width: 200,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFFE0E5EC),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: Offset(-3, -3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '$targetLength',
                  style: TextStyle(
                    color: Color.fromRGBO(120, 124, 130, 1),
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'mm',
                  style: TextStyle(
                    color: Color.fromRGBO(120, 124, 130, 0.7),
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            DropdownButton<int>(
              value: targetLength,
              icon: Icon(
                Icons.arrow_drop_down,
                color: Color.fromRGBO(120, 124, 130, 0.7),
              ),
              iconSize: 24,
              elevation: 16,
              underline: Container(height: 0),
              style: TextStyle(fontSize: 0), // Hide the text as we're using custom text
              items: [1, 2, 3, 4, 5].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  targetLength = newValue!;
                });
              },
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
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Color(0xFFE0E5EC),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                offset: Offset(-4, -4),
                blurRadius: 8,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(4, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFFF09182),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
