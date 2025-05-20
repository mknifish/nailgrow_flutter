import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('お知らせを見る'),
      ),
      body: const Center(
        child: Text('お知らせを見る画面'),
      ),
    );
  }
}
