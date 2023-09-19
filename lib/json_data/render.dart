import 'package:accordion/accordion.dart';
import 'package:cypher_system_srd_lookup/theme/colors.dart';
import 'package:cypher_system_srd_lookup/theme/text.dart';
import 'package:flutter/material.dart';

class CRenderHorizontalKeyValues extends StatelessWidget {
  final Map<String, String> map;
  final double row1FontSize;
  final double row2FontSize;

  const CRenderHorizontalKeyValues(
    this.map, {
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
            children: map.keys
                .map((key) => _MapTableCell(
                      text: key,
                      style: context.text.mapHorizontalTableCellSolidColor
                          .copyWith(fontSize: row1FontSize),
                    ))
                .toList(),
          ),
          TableRow(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            children: map.values
                .map((value) => _MapTableCell(
                    text: value,
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

class CRenderLabeledList extends StatelessWidget {
  final String label;
  final Iterable<MapEntry<String, String>> listItems;

  const CRenderLabeledList(this.listItems, {super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Accordion(
      disableScrolling: true,
      headerBackgroundColor: Colors.transparent,
      headerBorderColor: context.colors.text,
      headerBorderColorOpened: context.colors.text,
      headerBorderWidth: 1,
      headerPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      openAndCloseAnimation: false,
      paddingListHorizontal: 0,
      rightIcon: Icon(
        Icons.keyboard_arrow_down,
        color: context.colors.text,
      ),
      scaleWhenAnimating: false,
      children: [
        AccordionSection(
          header: Text(
            label,
            style: context.text.entryListHeader,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: listItems.map((it) => _LabeledListItem(it)).toList(),
          ),
        )
      ],
    );
  }
}

class _LabeledListItem extends StatelessWidget {
  final MapEntry<String, String> listItem;

  const _LabeledListItem(this.listItem);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: CRenderChip(listItem.key),
          ),
          Text(listItem.value),
        ],
      ),
    );
  }
}

class CRenderChip extends StatelessWidget {
  final String text;

  const CRenderChip(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: context.colors.muted,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 2,
        ),
        child: Text(
          text,
          style: context.text.entryChip,
        ),
      ),
    );
  }
}

class CRenderParagraph extends StatelessWidget {
  final String text;

  const CRenderParagraph(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}

class CRenderVerticalKeyValues extends StatelessWidget {
  final Map<String, String> map;

  const CRenderVerticalKeyValues(this.map, {super.key});

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
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(),
        },
        children: map.entries
            .map((kvp) => TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.colors.accent,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: Text(
                          kvp.key,
                          style: context.text.mapVerticalTableCellSolidColor,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          kvp.value,
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