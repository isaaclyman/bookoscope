import 'package:bookoscope/navigation/nav_config.dart';
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
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: BKRouterConfig().config,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: Colors.teal,
          onPrimary: Colors.white,
          secondary: Colors.grey[600]!,
          onSecondary: Colors.white,
          error: Colors.red[800]!,
          onError: Colors.white,
          background: Colors.grey[850]!,
          onBackground: Colors.white70,
          surface: Colors.grey[850]!,
          onSurface: Colors.white,
        ),
      ),
    );
  }
}
