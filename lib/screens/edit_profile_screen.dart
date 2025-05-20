import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィールを編集する'),
      ),
      body: const Center(
        child: Text('プロフィールを編集する画面'),
      ),
    );
  }
}
