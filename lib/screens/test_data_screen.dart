import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestDataScreen extends StatefulWidget {
  @override
  _TestDataScreenState createState() => _TestDataScreenState();
}

class _TestDataScreenState extends State<TestDataScreen> {
  Map<String, dynamic> preferences = {};
  final List<int> dropdownValues = [10, 20, 30, 40, 50]; // 例としてのドロップダウンの値
  final List<DateTime> goalSetDateOptions = [
    DateTime.now().subtract(Duration(days: 20)),
    DateTime.now().subtract(Duration(days: 2))
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      preferences = {
        'targetDays': prefs.getInt('targetDays') ?? 10,
        'achievedDays': prefs.getInt('achievedDays') ?? 0,
        'achievedGoals': prefs.getInt('achievedGoals') ?? 0,
        'goalSetDate': prefs.getString('goalSetDate') != null
            ? DateTime.parse(prefs.getString('goalSetDate')!)
            : null,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('テストデータ'),
      ),
      body: preferences.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ...preferences.entries.map((entry) {
                  return _buildPreferenceRow(entry.key, entry.value);
                }).toList(),
                SizedBox(height: 20),
                _buildCurrentSettings(),
              ],
            ),
    );
  }

  Widget _buildPreferenceRow(String key, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(key),
        if (key == 'targetDays' || key == 'achievedDays' || key == 'achievedGoals')
          DropdownButton<int>(
            value: dropdownValues.contains(value) ? value : dropdownValues.first,
            items: dropdownValues.map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
            onChanged: (int? newValue) async {
              if (newValue != null) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                setState(() {
                  preferences[key] = newValue;
                });
                prefs.setInt(key, newValue);
              }
            },
          )
        else if (key == 'goalSetDate')
          DropdownButton<DateTime>(
            value: goalSetDateOptions.contains(value) ? value : goalSetDateOptions.first,
            items: goalSetDateOptions.map((DateTime date) {
              return DropdownMenuItem<DateTime>(
                value: date,
                child: Text(date.toIso8601String()),
              );
            }).toList(),
            onChanged: (DateTime? newValue) async {
              if (newValue != null) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                setState(() {
                  preferences[key] = newValue;
                });
                prefs.setString(key, newValue.toIso8601String());
              }
            },
          )
        else
          Text(value != null ? value.toString() : 'NULL'), // NULLの表示
      ],
    );
  }

  Widget _buildCurrentSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Settings:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ...preferences.entries.map((entry) {
          return Text(
            '${entry.key}: ${entry.value != null ? entry.value.toString() : 'NULL'}',
            style: TextStyle(fontSize: 16),
          );
        }).toList(),
      ],
    );
  }
}
