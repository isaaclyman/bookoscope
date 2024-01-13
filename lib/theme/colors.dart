import 'package:flutter/material.dart';

class BKThemeColors {
  final Color primary = Colors.blue[900]!;
  final Color primaryContrast = Colors.white;
  final Color accent = Colors.pink[600]!;
  final Color accentContrast = Colors.white;
  final Color muted = Colors.grey[600]!;
  final Color mutedContrast = Colors.white;
  final Color text = Colors.white;
}

final bkThemeColors = BKThemeColors();

extension BKThemeColorsEx on BuildContext {
  BKThemeColors get colors => bkThemeColors;
}
