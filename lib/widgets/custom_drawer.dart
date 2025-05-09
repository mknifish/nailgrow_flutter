import 'package:flutter/material.dart';
import 'package:nailgrow_mobile_app_dev/screens/edit_profile_screen.dart';
import 'package:nailgrow_mobile_app_dev/screens/set_goal_screen.dart';
import 'package:nailgrow_mobile_app_dev/screens/notifications_screen.dart';
import 'package:nailgrow_mobile_app_dev/screens/test_data_screen.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            leading: Icon(Icons.settings), // 適切なアイコンを使用
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
    );
  }
}
