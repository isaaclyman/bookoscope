import 'package:bookoscope/navigation/nav_config.dart';
import 'package:bookoscope/theme/colors.dart';
import 'package:bookoscope/util/app_review.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  Provider.debugCheckInvalidValueType = null;

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    bkMaybeRequestReview();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: BKRouterConfig().config,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: context.colors.primary,
        brightness: Brightness.dark,
      ),
    );
  }
}
