import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import './json_types.dart';

Future<CJsonRoot> readJson() async {
  final jsonString = await rootBundle.loadString('assets/CSRD.json');
  return CJsonRoot.fromJson(jsonDecode(jsonString));
}
