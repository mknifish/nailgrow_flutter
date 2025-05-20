import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'data_screen.dart';
import 'set_goal_screen.dart';
import 'notifications_screen.dart';
import 'test_data_screen.dart';
import 'package:nailgrow_mobile_app_dev/theme.dart'; // テーマをインポート

class MyHomePage extends StatefulWidget {
  final int initialIndex;

  const MyHomePage({this.initialIndex = 0, Key? key}) : super(key: key);

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
    const HomeScreen(),
    const DataScreen(),
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
        backgroundColor: _currentIndex == 1 ? const Color(0xFFFFCDC5) : AppTheme.primaryColor,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: _currentIndex == 1 ? const Color(0xFFFFCDC5) : AppTheme.primaryColor,
        selectedItemColor: _currentIndex == 1 ? const Color(0xFFE0E5EC) : AppTheme.accentColor,
        unselectedItemColor: const Color(0xFFB0BEC5),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.data_usage,
              size: 48,
              color: _currentIndex == 0 ? const Color(0xFFF09182) : AppTheme.shadowDarkColor,
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
            const DrawerHeader(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor, // テーマの色を使用
              ),
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.white),
                  SizedBox(width: 10),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('目標値を設定する'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SetGoalScreen(isFirstTime: false)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('お知らせを見る'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('テストデータ'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TestDataScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
