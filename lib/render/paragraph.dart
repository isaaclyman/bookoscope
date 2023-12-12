import 'package:bookoscope/theme/colors.dart';
import 'package:bookoscope/theme/text.dart';
import 'package:flutter/material.dart';

class CRenderParagraph extends StatelessWidget {
  final String text;

  const CRenderParagraph(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}

class CRenderLabeledParagraph extends StatelessWidget {
  final String label;
  final String text;

  const CRenderLabeledParagraph({
    super.key,
    required this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: context.colors.accent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          color: context.colors.accentContrast,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: context.text.accordionInnerLabel,
            ),
            Text(text),
          ],
        ),
      ),
    );
  }
}
