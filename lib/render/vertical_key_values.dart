import 'package:bookoscope/render/name_description.dart';
import 'package:bookoscope/theme/colors.dart';
import 'package:bookoscope/theme/text.dart';
import 'package:flutter/material.dart';

class CRenderVerticalKeyValues extends StatelessWidget {
  final List<CNameDescription> items;

  const CRenderVerticalKeyValues(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(
          color: context.colors.accent,
          strokeAlign: BorderSide.strokeAlignOutside,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(
            color: Colors.grey[400]!,
            width: 1,
          ),
        ),
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(),
        },
        children: items
            .map((item) => TableRow(
                  decoration: BoxDecoration(
                    color: context.colors.accent,
                  ),
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.colors.accent,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          item.name,
                          style: context.text.mapVerticalTableCellSolidColor,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.colors.accentContrast,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          item.description,
                          style: context.text.mapVerticalTableCellBordered,
                        ),
                      ),
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
