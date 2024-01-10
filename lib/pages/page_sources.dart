import 'package:bookoscope/db/book.db.dart';
import 'package:bookoscope/db/source.db.dart';
import 'package:bookoscope/search/search_manager.dart';
import 'package:bookoscope/theme/text.dart';
import 'package:flutter/material.dart';
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
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              "Sources",
              style: TextStyle(
                fontSize: 24,
              ),
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
            onPressed: () {},
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
    final dbBooks = context.watch<DBBooks>();

    return PopupMenuButton<_SourceAction>(
      onSelected: (action) async {
        await Future.delayed(const Duration(milliseconds: 500));

        switch (action) {
          case _SourceAction.refresh:
            // TODO: Handle this case.
            break;
          case _SourceAction.edit:
            // TODO: Handle this case.
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
