import 'package:bookoscope/events/event_handler.dart';
import 'package:bookoscope/render/link.dart';
import 'package:bookoscope/theme/text.dart';
import 'package:bookoscope/util/intersperse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CRenderLinksParagraph extends StatelessWidget {
  final String label;
  final List<CLink> textQueries;

  const CRenderLinksParagraph({
    super.key,
    required this.label,
    required this.textQueries,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BKEventHandler>(
      builder: (_, handler, child) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (child != null) child,
          Expanded(
            child: Text.rich(
              TextSpan(
                children: textQueries
                    .map((item) => TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              if (item is CSearchQueryLink) {
                                handler.setSearchQuery(context, item.query);
                                handler.closeDrawer(context);
                              } else if (item is CResultLink) {
                                handler.goToResult(
                                  context,
                                  item.resultCategory,
                                  item.resultName,
                                );
                              }
                            },
                          style: context.text.backgroundLink,
                          text: item.label,
                        ))
                    .intersperse(const TextSpan(text: ", "))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
      child: Text(
        "$label: ",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
