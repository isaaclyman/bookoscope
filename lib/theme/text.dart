import 'package:bookoscope/theme/colors.dart';
import 'package:flutter/material.dart';

class CThemeText {
  final TextStyle accordionInnerLabel = TextStyle(
    color: cThemeColors.text,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  final TextStyle entryCategory = TextStyle(
    color: cThemeColors.muted,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  final TextStyle entryChip = TextStyle(
    color: cThemeColors.mutedContrast,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  final TextStyle entryListHeader = TextStyle(
    color: cThemeColors.text,
    fontSize: 18,
  );

  final TextStyle entryMainHeader = TextStyle(
    color: cThemeColors.accent,
    fontSize: 20,
    fontWeight: FontWeight.w300,
  );

  final TextStyle filterChip = TextStyle(
    color: cThemeColors.text,
    fontSize: 12,
  );

  final TextStyle highlight = const TextStyle(
    backgroundColor: Colors.yellow,
  );

  final TextStyle legal = const TextStyle(
    fontSize: 8,
  );

  final TextStyle link = TextStyle(
    color: cThemeColors.accent,
    decoration: TextDecoration.underline,
    decorationColor: cThemeColors.accent,
  );

  final TextStyle mapHorizontalTableCellBordered = TextStyle(
    color: cThemeColors.accent,
    fontWeight: FontWeight.bold,
  );

  final TextStyle mapHorizontalTableCellSolidColor = TextStyle(
    color: cThemeColors.accentContrast,
    fontWeight: FontWeight.bold,
  );

  final TextStyle mapVerticalTableCellBordered = TextStyle(
    color: cThemeColors.text,
    fontWeight: FontWeight.bold,
  );

  final TextStyle mapVerticalTableCellSolidColor = TextStyle(
    color: cThemeColors.accentContrast,
    fontWeight: FontWeight.bold,
  );

  final TextStyle resultCategoryHeader = TextStyle(
    color: cThemeColors.muted,
    fontSize: 12,
  );

  final TextStyle resultEntryHeader = TextStyle(
    color: cThemeColors.accent,
    fontSize: 16,
  );

  final TextStyle small = const TextStyle(
    fontSize: 10,
  );
}

final cThemeText = CThemeText();

extension CThemeTextEx on BuildContext {
  CThemeText get text => cThemeText;
}
