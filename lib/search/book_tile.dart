import 'package:auto_size_text/auto_size_text.dart';
import 'package:bookoscope/format/guten/guten_acquisition.dart';
import 'package:bookoscope/format/opds/opds_crawler.dart';
import 'package:bookoscope/render/link.dart';
import 'package:bookoscope/search/search_manager.dart';
import 'package:bookoscope/theme/colors.dart';
import 'package:bookoscope/util/menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BKBookTile extends StatefulWidget {
  final String? searchText;
  final BKSearchResult result;

  const BKBookTile({
    super.key,
    required this.result,
    required this.searchText,
  });

  @override
  State<BKBookTile> createState() => _BKBookTileState();
}

class _BKBookTileState extends State<BKBookTile> {
  bool isLoadingLinks = false;

  @override
  Widget build(BuildContext context) {
    final searchManager = context.watch<BKSearchManager>();
    final imageUrl = widget.result.imageUrl;

    return GestureDetector(
      onTap: () {
        searchManager.selectResult(context, widget.result);
      },
      child: Card(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, err, ___) {
                            debugPrint(err.toString());
                            return _DefaultBookCover(
                              title: widget.result.title,
                              author: widget.result.author,
                              sourceName: widget.result.sourceName,
                            );
                          },
                        )
                      : _DefaultBookCover(
                          title: widget.result.title,
                          author: widget.result.author,
                          sourceName: widget.result.sourceName,
                        ),
                  if (widget.result.isNewTitle)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: _NewTitleLabel(),
                    ),
                ],
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.only(
                left: 16,
                right: 2,
              ),
              title: Text(
                widget.result.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                widget.result.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Builder(builder: (context) {
                return IconButton(
                  icon: Icon(isLoadingLinks
                      ? Icons.pending
                      : Icons.download_for_offline_rounded),
                  onPressed: () async {
                    if (isLoadingLinks) {
                      return;
                    }

                    var uris = widget.result.downloadUrls;
                    if (widget.result.isGutenberg) {
                      try {
                        final uriResults = await getGutenbergResourceUris(
                          widget.result.originalId,
                        );

                        uris = uriResults
                            .map((result) => CExternalLink(
                                  OPDSLinkClassifier.getDisplayLabel(
                                    result.label,
                                    result.rel,
                                    result.type,
                                    includeType: false,
                                  ),
                                  uri: result.uri,
                                ))
                            .toList();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Error communicating with Gutenberg Project. Please try again later.",
                              ),
                            ),
                          );
                        }
                        return;
                      }
                    }

                    if (uris.isEmpty && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "No download URLs found.",
                          ),
                        ),
                      );
                      return;
                    }

                    if (uris.length == 1) {
                      try {
                        await launchUrl(Uri.parse(uris.first.uri!));
                        return;
                      } catch (e) {
                        // Swallow error
                        debugPrint(e.toString());
                        return;
                      }
                    }

                    if (!context.mounted) {
                      return;
                    }

                    final selected = await showMenuAtContext(
                      context,
                      uris
                          .map((uri) => PopupMenuItem(
                                value: uri.uri,
                                child: Text(uri.label),
                              ))
                          .toList(),
                    );

                    if (selected == null) {
                      return;
                    }

                    try {
                      await launchUrl(Uri.parse(selected));
                      return;
                    } catch (e) {
                      // Swallow error
                      debugPrint(e.toString());
                      return;
                    }
                  },
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}

class _DefaultBookCover extends StatelessWidget {
  final String title;
  final String author;
  final String sourceName;

  const _DefaultBookCover({
    required this.title,
    required this.author,
    required this.sourceName,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blueGrey[900]!,
            Colors.grey[900]!,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: AutoSizeText(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withAlpha(220),
                  fontSize: 26,
                  fontFamily: 'Titillium',
                ),
              ),
            ),
            Text(
              sourceName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withAlpha(220),
                fontSize: 14,
                fontFamily: 'Titillium',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewTitleLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          color: context.colors.accent.withOpacity(0.9),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            "New",
            style: TextStyle(
              color: Colors.white.withAlpha(220),
              fontFamily: 'Titillium',
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
