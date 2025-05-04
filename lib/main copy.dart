import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Firebaseの設定オプションを含むファイルをインポート
import 'package:shared_preferences/shared_preferences.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutterアプリケーションが初期化されたことを確認
  await Firebase.initializeApp( // Firebaseの初期化を待機
    options: DefaultFirebaseOptions.currentPlatform, // Firebaseのオプションを指定
  );
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp()); // Flutterアプリケーションを実行
}

//Flutterアプリケーションのエントリーポイントであり、アプリケーションを起動するためのもの
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bottom Tabs with Drawer Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
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
      appBar: AppBar(),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_usage),
            label: 'Data',
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
                  Text(
                    'Settings',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('プロフィールを編集する'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.flag),
              title: Text('目標値を設定する'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SetGoalScreen()),
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
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int targetDays = 0; // 初期値は0
  int achievedDays = 0; // 初期値は0

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  // Shared Preferencesから値を読み込む
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      targetDays = prefs.getInt('targetDays') ?? 30; // 目標日数が保存されていない場合はデフォルト値30を使用
      achievedDays = prefs.getInt('achievedDays') ?? 10; // 達成日数が保存されていない場合はデフォルト値10を使用
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = achievedDays / targetDays;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        color: Colors.blue,
                        strokeWidth: 15,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'DAY',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                        ),
                        Text(
                          '$achievedDays',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '/ $targetDays',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showWinDialog(context);
                  },
                  child: Text('WIN'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    _showLoseDialog(context);
                  },
                  child: Text('LOSE'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              '${(progress * 100).toStringAsFixed(1)}% complete',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _showWinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You have won!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLoseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Try Again'),
          content: Text('You have lost. Better luck next time!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}


class DataScreen extends StatelessWidget {
  final int achievedGoals = 15; // 達成回数（例）

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Achieved Goals',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: List.generate(achievedGoals, (index) {
                return CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.blue,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            Text(
              '$achievedGoals times',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('プロフィールを編集する'),
      ),
      body: Center(
        child: Text('プロフィールを編集する画面'),
      ),
    );
  }
}

class SetGoalScreen extends StatefulWidget {
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
                  // 目標日数を設定した後、HomeScreenに遷移して更新を反映
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
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


class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('お知らせを見る'),
      ),
      body: Center(
        child: Text('お知らせを見る画面'),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/splash/splash.png',
          fit: BoxFit.fitWidth, // 画像を画面全体に引き伸ばす
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
