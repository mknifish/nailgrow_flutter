import 'package:flutter/material.dart';
import 'package:nailgrow_mobile_app_dev/screens/my_home_page.dart';

class MigrationErrorScreen extends StatelessWidget {
  final String errorMessage;

  const MigrationErrorScreen({super.key, this.errorMessage = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('データ移行エラー'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'データの移行に失敗しました',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage.isEmpty 
                    ? '以前のアプリからデータを移行できませんでした。新規データとして始めます。' 
                    : '以前のアプリからデータを移行できませんでした：$errorMessage',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                '対処方法:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '• アプリを再起動してみてください\n'
                '• iOSの設定からストレージ容量を確認してください\n'
                '• 以前のアプリを一度開いてみてください',
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const MyHomePage()),
                    );
                  },
                  child: const Text('アプリを始める'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 