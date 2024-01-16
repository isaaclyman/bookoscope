import 'package:bookoscope/db/book.db.dart';
import 'package:bookoscope/db/endpoint.db.dart';
import 'package:bookoscope/db/source.db.dart';
import 'package:bookoscope/format/crawl_manager.dart';
import 'package:bookoscope/search/search_manager.dart';
import 'package:bookoscope/sources/page_edit_source.dart';
import 'package:bookoscope/sources/page_fetch_source.dart';
import 'package:bookoscope/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BKPageSources extends StatefulWidget {
  static const name = 'Sources';

  const BKPageSources({super.key});

  @override
  State<BKPageSources> createState() => _BKPageSourcesState();
}

class _BKPageSourcesState extends State<BKPageSources> {
  @override
  Widget build(BuildContext context) {
    final dbSources = context.watch<DBSources>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              "Sources",
              style: context.text.pageHeader,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final source = dbSources.sources[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.only(
                    bottom: 4,
                    left: 16,
                    right: 4,
                    top: 4,
                  ),
                  title: Text(
                    source.label,
                    style: TextStyle(
                      decoration: source.isEnabled
                          ? TextDecoration.none
                          : TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: source.isEnabled
                      ? Text(
                          source.description ?? source.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : const Text("Disabled"),
                  trailing: _SourceActions(
                    source: source,
                  ),
                ),
              );
            },
            itemCount: dbSources.sources.length,
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ElevatedButton.icon(
            onPressed: () {
              context.pushNamed(BKPageEditSource.name);
            },
            icon: const Icon(Icons.add),
            label: const Text("Add source"),
          ),
        ),
      ],
    );
  }
}

enum _SourceAction {
  refresh,
  edit,
  disable,
  enable,
  delete,
}

class _SourceActions extends StatelessWidget {
  final Source source;

  const _SourceActions({
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    final searchManager = context.watch<BKSearchManager>();
    final dbSources = context.watch<DBSources>();
    final dbEndpoints = context.watch<DBEndpoints>();
    final dbBooks = context.watch<DBBooks>();

    return PopupMenuButton<_SourceAction>(
      onSelected: (action) async {
        await Future.delayed(const Duration(milliseconds: 500));

        switch (action) {
          case _SourceAction.refresh:
            if (context.mounted) {
              if (source.url == bkFakeGutenbergUrl) {
                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(const SnackBar(
                  content: Text("Refreshing Gutenberg database..."),
                ));
                await Future.delayed(const Duration(milliseconds: 500));

                await dbBooks.overwriteEntireSource(source.id, []);
                source.isCompletelyCrawled = false;
                await dbSources.upsert(source);

                if (context.mounted) {
                  messenger.clearSnackBars();
                  messenger.showSnackBar(const SnackBar(
                    content: Text("Gutenberg database refreshed."),
                  ));
                }
              } else {
                context.pushNamed(BKPageFetchSource.name, extra: source);
              }
            }
            break;
          case _SourceAction.edit:
            if (context.mounted) {
              context.pushNamed(BKPageEditSource.name, extra: source);
            }
            break;
          case _SourceAction.disable:
            source.isEnabled = false;
            await dbSources.upsert(source);
            searchManager.refreshSources(dbSources, dbBooks);
            break;
          case _SourceAction.enable:
            source.isEnabled = true;
            await dbSources.upsert(source);
            searchManager.refreshSources(dbSources, dbBooks);
            break;
          case _SourceAction.delete:
            await dbBooks.deleteAllBySourceId(source.id);
            await dbEndpoints.deleteAllBySourceId(source.id);
            await dbSources.delete(source);
            searchManager.refreshSources(dbSources, dbBooks);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _SourceAction.refresh,
          child: Text("Refresh"),
        ),
        if (source.isEditable)
          const PopupMenuItem(
            value: _SourceAction.edit,
            child: Text("Edit"),
          ),
        if (source.isEditable)
          const PopupMenuItem(
            value: _SourceAction.delete,
            child: Text("Delete"),
          ),
        if (source.isEnabled)
          const PopupMenuItem(
            value: _SourceAction.disable,
            child: Text("Disable"),
          ),
        if (!source.isEnabled)
          const PopupMenuItem(
            value: _SourceAction.enable,
            child: Text("Enable"),
          ),
      ],
    );
  }
}
