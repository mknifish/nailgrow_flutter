import 'package:flutter/material.dart';

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
