import 'dart:async';

import 'package:bookoscope/db/source.db.dart';
import 'package:bookoscope/format/crawl_manager.dart';
import 'package:bookoscope/format/opds/opds_events.dart';
import 'package:bookoscope/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BKPageFetchSource extends StatefulWidget {
  static const name = 'Fetch Source';

  const BKPageFetchSource({super.key});

  @override
  State<BKPageFetchSource> createState() => _BKPageFetchSourceState();
}

class _BKPageFetchSourceState extends State<BKPageFetchSource> {
  late Source source;
  late BKCrawlManager crawlManager;
  late StreamSubscription crawlSubscription;

  bool crawlComplete = false;
  List<OPDSCrawlBegin> beginEvents = [];
  int get pagesDiscovered => beginEvents.length;
  List<OPDSCrawlSuccess> successEvents = [];
  int get pagesCrawled => successEvents.length;
  List<OPDSCrawlException> exceptionEvents = [];
  int get pagesWithExceptions => exceptionEvents.length;
  List<OPDSCrawlResourceFound> resourceEvents = [];
  int get resourcesFound => resourceEvents.length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    crawlManager = context.read<BKCrawlManager>();

    final source = GoRouterState.of(context).extra as Source?;
    if (source == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Invalid or missing source. This is a bug.")),
      );
      context.pop();
      return;
    }

    final events = crawlManager.crawlOpdsUri(source);
    crawlSubscription = events.listen(
      (event) {
        if (!mounted) {
          return;
        }

        setState(() {
          if (event is OPDSCrawlBegin) {
            beginEvents.add(event);
            return;
          }

          if (event is OPDSCrawlSuccess) {
            successEvents.add(event);
            return;
          }

          if (event is OPDSCrawlException) {
            exceptionEvents.add(event);
            return;
          }

          if (event is OPDSCrawlResourceFound) {
            resourceEvents.add(event);
            return;
          }
        });
      },
      onDone: () {
        if (!mounted) {
          return;
        }

        setState(() {
          crawlComplete = true;
        });
      },
    );
  }

  @override
  void dispose() {
    crawlSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                "Crawl endpoint",
                style: context.text.pageHeader,
                textAlign: TextAlign.center,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                "Please leave this page open until the process is complete.",
              ),
            ),
            _TrackerTile(
              header: "$pagesDiscovered pages discovered",
              icon: const Icon(
                Icons.more_horiz,
                color: Colors.grey,
              ),
              details: beginEvents.map((e) => e.uri),
            ),
            _TrackerTile(
              header: "$pagesCrawled pages crawled",
              icon: const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              details: successEvents.map((e) => e.uri),
            ),
            _TrackerTile(
              header: "$pagesWithExceptions pages with errors",
              icon: const Icon(
                Icons.error,
                color: Colors.red,
              ),
              details: exceptionEvents
                  .map((e) => [
                        e.uri,
                        e.exception.toString(),
                      ])
                  .expand((s) => s),
            ),
            _TrackerTile(
              header: "$resourcesFound books found",
              icon: const Icon(
                Icons.book,
                color: Colors.blue,
              ),
              details: resourceEvents.map((e) => e.resource.title),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!crawlComplete) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CircularProgressIndicator(
                        value: pagesDiscovered == 0
                            ? 0
                            : (pagesCrawled + pagesWithExceptions) /
                                pagesDiscovered,
                      ),
                    ),
                    const Text("Crawling in progress...")
                  ] else
                    const Text("Crawl complete.")
                ],
              ),
            ),
            if (crawlComplete)
              ElevatedButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text("Close"),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrackerTile extends StatefulWidget {
  final String header;
  final Widget icon;
  final Iterable<String> details;

  const _TrackerTile({
    required this.header,
    required this.icon,
    required this.details,
  });

  @override
  State<_TrackerTile> createState() => _TrackerTileState();
}

class _TrackerTileState extends State<_TrackerTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      alignment: Alignment.topCenter,
      duration: const Duration(milliseconds: 150),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: widget.icon,
                  ),
                  Expanded(
                    child: Text(
                      widget.header,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  ExpandIcon(
                    isExpanded: isExpanded,
                    onPressed: (value) => setState(() {
                      isExpanded = !value;
                    }),
                  ),
                ],
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widget.details
                        .map(
                          (detail) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              detail,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
