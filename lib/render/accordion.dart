import 'package:accordion/accordion.dart';
import 'package:bookoscope/theme/colors.dart';
import 'package:bookoscope/theme/text.dart';
import 'package:flutter/material.dart';

class CRenderAccordion extends StatelessWidget {
  final String label;
  final Widget content;

  const CRenderAccordion({
    super.key,
    required this.label,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Accordion(
      disableScrolling: true,
      headerBackgroundColor: Colors.white,
      headerBorderColor: context.colors.text,
      headerBorderColorOpened: context.colors.text,
      headerBorderWidth: 1,
      headerPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      openAndCloseAnimation: false,
      paddingBetweenClosedSections: 0,
      paddingBetweenOpenSections: 0,
      paddingListBottom: 0,
      paddingListHorizontal: 0,
      paddingListTop: 0,
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
          content: content,
        )
      ],
    );
  }
}
