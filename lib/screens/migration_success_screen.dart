import 'package:flutter/material.dart';
import 'package:nailgrow_mobile_app_dev/screens/my_home_page.dart';

class MigrationSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> migratedData;

  const MigrationSuccessScreen({super.key, required this.migratedData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('データ移行完了'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'データ移行が完了しました',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '以前のアプリからデータが正常に移行されました。これまでの記録を引き続き活用できます。',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                '移行されたデータ:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildMigratedDataList(),
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

  Widget _buildMigratedDataList() {
    return Expanded(
      child: ListView(
        children: [
          if (migratedData.containsKey('targetDays'))
            _buildDataItem('目標日数', '${migratedData['targetDays']}日'),
          if (migratedData.containsKey('achievedDays'))
            _buildDataItem('達成日数', '${migratedData['achievedDays']}日'),
          if (migratedData.containsKey('goalSetDate'))
            _buildDataItem('開始日', _formatDate(migratedData['goalSetDate'] as DateTime)),
          if (migratedData.containsKey('legacy_my_goal'))
            _buildDataItem('以前の目標', migratedData['legacy_my_goal']),
        ],
      ),
    );
  }

  Widget _buildDataItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
} 