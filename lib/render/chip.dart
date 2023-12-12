import 'package:bookoscope/theme/colors.dart';
import 'package:bookoscope/theme/text.dart';
import 'package:flutter/material.dart';

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
