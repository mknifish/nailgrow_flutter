import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'data_screen.dart';
import 'set_goal_screen.dart';
import 'notifications_screen.dart';
import 'test_data_screen.dart';
import 'package:nailgrow_mobile_app_dev/theme.dart'; // テーマをインポート

class MyHomePage extends StatefulWidget {
  final int initialIndex;

  MyHomePage({this.initialIndex = 0, Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex;

  _MyHomePageState() : _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    HomeScreen(),
    DataScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _currentIndex == 1 ? Color(0xFFFFCDC5) : AppTheme.primaryColor,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: _currentIndex == 1 ? Color(0xFFFFCDC5) : AppTheme.primaryColor,
        selectedItemColor: _currentIndex == 1 ? Color(0xFFE0E5EC) : AppTheme.accentColor,
        unselectedItemColor: const Color(0xFFB0BEC5),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.data_usage,
              size: 48,
              color: _currentIndex == 0 ? Color(0xFFF09182) : AppTheme.shadowDarkColor,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/img/icon_gray.png',
              width: 40,
              height: 40,
            ),
            activeIcon: Image.asset(
              'assets/img/icon_white.png',
              width: 36,
              height: 36,
            ),
            label: '',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.white),
                  SizedBox(width: 10),
                ],
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor, // テーマの色を使用
              ),
            ),
            ListTile(
              leading: Icon(Icons.flag),
              title: Text('目標値を設定する'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SetGoalScreen(isFirstTime: false)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('お知らせを見る'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('テストデータ'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TestDataScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
