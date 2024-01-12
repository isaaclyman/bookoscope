import 'package:bookoscope/theme/colors.dart';
import 'package:flutter/material.dart';

class CThemeText {
  final TextStyle accordionInnerLabel = TextStyle(
    color: bkThemeColors.text,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  final TextStyle entryCategory = TextStyle(
    color: bkThemeColors.muted,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  final TextStyle entryChip = TextStyle(
    color: bkThemeColors.mutedContrast,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  final TextStyle entryListHeader = TextStyle(
    color: bkThemeColors.text,
    fontSize: 18,
  );

  final TextStyle entryMainHeader = TextStyle(
    color: bkThemeColors.accent,
    fontSize: 20,
    fontWeight: FontWeight.w300,
  );

  final TextStyle filterChip = TextStyle(
    color: bkThemeColors.text,
    fontSize: 12,
  );

  final TextStyle highlight = const TextStyle(
    backgroundColor: Colors.yellow,
  );

  final TextStyle legal = const TextStyle(
    fontSize: 8,
  );

  final TextStyle link = TextStyle(
    color: bkThemeColors.accent,
    decoration: TextDecoration.underline,
    decorationColor: bkThemeColors.accent,
  );

  final TextStyle mapHorizontalTableCellBordered = TextStyle(
    color: bkThemeColors.accent,
    fontWeight: FontWeight.bold,
  );

  final TextStyle mapHorizontalTableCellSolidColor = TextStyle(
    color: bkThemeColors.accentContrast,
    fontWeight: FontWeight.bold,
  );

  final TextStyle mapVerticalTableCellBordered = TextStyle(
    color: bkThemeColors.text,
    fontWeight: FontWeight.bold,
  );

  final TextStyle mapVerticalTableCellSolidColor = TextStyle(
    color: bkThemeColors.accentContrast,
    fontWeight: FontWeight.bold,
  );

  final TextStyle pageHeader = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.normal,
  );

  final TextStyle resultCategoryHeader = TextStyle(
    color: bkThemeColors.muted,
    fontSize: 12,
  );

  final TextStyle resultEntryHeader = TextStyle(
    color: bkThemeColors.accent,
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
