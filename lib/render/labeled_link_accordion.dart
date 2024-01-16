import 'package:bookoscope/events/event_handler.dart';
import 'package:bookoscope/render/accordion.dart';
import 'package:bookoscope/render/link.dart';
import 'package:bookoscope/theme/colors.dart';
import 'package:bookoscope/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
                onTap: () async {
                  if (link is CSearchQueryLink) {
                    handler.setSearchQuery(context, link.query);
                    handler.closeDrawer(context);
                  } else if (link is CResultLink) {
                    handler.goToResult(
                      context,
                      link.resultCategory,
                      link.resultName,
                    );
                  } else if (link is CExternalLink) {
                    try {
                      await launchUrl(Uri.parse(link.uri));
                    } catch (e) {
                      debugPrint(e.toString());
                      // Swallow error
                    }
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.link,
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        link.label,
                        style: context.text.accentLink,
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
