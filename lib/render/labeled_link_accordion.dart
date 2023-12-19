import 'package:bookoscope/events/event_handler.dart';
import 'package:bookoscope/render/accordion.dart';
import 'package:bookoscope/render/link.dart';
import 'package:bookoscope/theme/colors.dart';
import 'package:bookoscope/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CRenderLabeledResultLinkAccordion extends StatelessWidget {
  final String label;
  final String? innerLabel;
  final List<CLink> links;

  const CRenderLabeledResultLinkAccordion({
    super.key,
    required this.label,
    this.innerLabel,
    required this.links,
  });

  @override
  Widget build(BuildContext context) {
    return CRenderAccordion(
      label: label,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (innerLabel != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                innerLabel!,
                style: context.text.accordionInnerLabel,
              ),
            ),
          ...links.map(
            (link) => Consumer<BKEventHandler>(
              builder: (_, handler, ___) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (link is CSearchQueryLink) {
                    handler.setSearchQuery(context, link.query);
                    handler.closeDrawer(context);
                  } else if (link is CResultLink) {
                    handler.goToResult(
                      context,
                      link.resultCategory,
                      link.resultName,
                    );
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.link,
                        color: bkThemeColors.accent,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        link.label,
                        style: context.text.link,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
