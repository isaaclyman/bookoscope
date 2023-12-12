import 'package:bookoscope/render/name_description.dart';
import 'package:bookoscope/theme/colors.dart';
import 'package:bookoscope/theme/text.dart';
import 'package:flutter/material.dart';

class CRenderHorizontalKeyValues extends StatelessWidget {
  final List<CNameDescription> items;
  final double row1FontSize;
  final double row2FontSize;

  const CRenderHorizontalKeyValues(
    this.items, {
    super.key,
    this.row1FontSize = 12,
    this.row2FontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.accent,
        border: Border.all(
          color: context.colors.accent,
          strokeAlign: BorderSide.strokeAlignOutside,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Table(
        border: TableBorder(
          verticalInside: BorderSide(
            color: context.colors.accentContrast,
            width: 1,
          ),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: context.colors.accent,
            ),
            children: items
                .map((item) => _MapTableCell(
                      text: item.name,
                      style: context.text.mapHorizontalTableCellSolidColor
                          .copyWith(fontSize: row1FontSize),
                    ))
                .toList(),
          ),
          TableRow(
            decoration: BoxDecoration(
              color: context.colors.accentContrast,
            ),
            children: items
                .map((item) => _MapTableCell(
                    text: item.description,
                    style: context.text.mapHorizontalTableCellBordered.copyWith(
                      fontSize: row2FontSize,
                    )))
                .toList(),
          )
        ],
      ),
    );
  }
}

class _MapTableCell extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _MapTableCell({
    required this.text,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: style,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
