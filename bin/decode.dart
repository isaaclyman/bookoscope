import 'dart:convert';
import 'dart:io';

import 'package:bookoscope/json_data/json_types.dart';
import 'package:path/path.dart';

void main(List<String> arguments) async {
  final jsonFile = File(join("assets", "CSRD.json"));
  final jsonString = await jsonFile.readAsString();
  var decoded = CJsonRoot.fromJson(jsonDecode(jsonString));
  print('JSON successfully decoded.');
  print(decoded);
}
