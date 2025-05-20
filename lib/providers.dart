import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nailgrow_mobile_app_dev/state/progress_provider.dart';
import 'package:nailgrow_mobile_app_dev/state/data_provider.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProgressProvider()),
        ChangeNotifierProvider(create: (context) => DataProvider()),
      ],
      child: child,
    );
  }
}
