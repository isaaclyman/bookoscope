import 'package:bookoscope/components/future_handler.dart';
import 'package:bookoscope/json_data/read_json.dart';
import 'package:bookoscope/navigation/nav_config.dart';
import 'package:flutter/material.dart';

void main() async {
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
    return CFutureHandler(
      future: readSrdJson(),
      builder: (context, dataRoot) => MaterialApp.router(
        routerConfig: CRouterConfig(dataRoot: dataRoot).config,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
      ),
      errorMessage: "Error loading data file.",
      nullDataMessage: "Data file is empty.",
    );
  }
}
