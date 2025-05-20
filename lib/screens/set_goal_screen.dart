import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_home_page.dart';

class SetGoalScreen extends StatefulWidget {
  final bool isFirstTime;

  const SetGoalScreen({super.key, required this.isFirstTime});

  @override
  _SetGoalScreenState createState() => _SetGoalScreenState();
}

class _SetGoalScreenState extends State<SetGoalScreen> {
  int targetLength = 1; // 初期目標長さ (mm)

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
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('targetLength', targetLength);
                  await prefs.setString('goalSetDate', DateTime.now().toIso8601String());
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
                  '$targetLength',
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
                  value: targetLength,
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
                                fontWeight: value == targetLength ? FontWeight.bold : FontWeight.w400,
                                color: const Color.fromRGBO(120, 124, 130, 1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'mm',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: value == targetLength ? FontWeight.bold : FontWeight.w400,
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
                      targetLength = newValue!;
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
