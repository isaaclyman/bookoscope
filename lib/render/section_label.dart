import 'package:bookoscope/theme/text.dart';
import 'package:flutter/material.dart';

class CRenderSectionLabel extends StatelessWidget {
  final String label;

  const CRenderSectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.text.accordionInnerLabel,
    );
  }
}
