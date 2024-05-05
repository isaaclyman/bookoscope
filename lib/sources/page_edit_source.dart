import 'package:bookoscope/db/source.db.dart';
import 'package:bookoscope/format/opds/opds_extractor.dart';
import 'package:bookoscope/sources/page_fetch_source.dart';
import 'package:bookoscope/sources/source_disclaimer.dart';
import 'package:bookoscope/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BKPageEditSource extends StatefulWidget {
  static const name = 'Edit Source';

  const BKPageEditSource({super.key});

  @override
  State<BKPageEditSource> createState() => _BKPageEditSourceState();
}

class _BKPageEditSourceState extends State<BKPageEditSource> {
  Source source = Source(
    label: '',
    url: 'https://',
    description: null,
    username: '',
    password: '',
    isEditable: true,
    isEnabled: true,
  );
  bool isNew = false;

  String? _urlFieldError;
  String? _nameFieldError;
  bool confirmedOwnership = false;
  bool useBasicAuth = false;

  bool? endpointTestStatus;
  String? endpointTestError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final editingSource = GoRouterState.of(context).extra as Source?;
    isNew = editingSource == null;

    if (editingSource != null) {
      source = editingSource;
    }

    confirmedOwnership = !isNew;
    useBasicAuth = (source.username?.isNotEmpty ?? false) &&
        (source.password?.isNotEmpty ?? false);
  }

  bool formIsValid() {
    return source.label.trim().isNotEmpty &&
        urlIsValid(source.url) &&
        confirmedOwnership;
  }

  bool urlIsValid(String url) {
    return url.trim().isNotEmpty &&
        (Uri.tryParse(url)?.host.isNotEmpty ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final dbSources = context.watch<DBSources>();

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    isNew ? "Add Source" : "Edit Source",
                    style: context.text.pageHeader,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    initialValue: source.url,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      errorText: _urlFieldError,
                      labelText: "Source URL",
                    ),
                    onChanged: (value) {
                      source.url = value;
                      endpointTestStatus = null;
                      endpointTestError = null;

                      final canParse =
                          Uri.tryParse(value)?.host.isNotEmpty ?? false;
                      _urlFieldError = !canParse ? 'Not a valid URL' : null;

                      setState(() {});
                    },
                  ),
                ),
                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) {
                    setState(() {
                      useBasicAuth = value ?? false;
                      if (!useBasicAuth) {
                        source.username = null;
                        source.password = null;
                      }
                    });
                  },
                  title: const Text("Use Basic Authentication"),
                  value: useBasicAuth,
                ),
                if (useBasicAuth) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      initialValue: source.username,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Username",
                      ),
                      onChanged: (value) => setState(() {
                        source.username = value;
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      initialValue: source.password,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Password",
                      ),
                      onChanged: (value) => setState(() {
                        source.password = value;
                      }),
                    ),
                  ),
                ],
                if (urlIsValid(source.url)) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    child: BKSourceDisclaimer(),
                  ),
                  CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (value) {
                      setState(() {
                        confirmedOwnership = value ?? false;
                      });
                    },
                    title: const Text("Yes, I have permission"),
                    value: confirmedOwnership,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: OutlinedButton.icon(
                      onPressed: !confirmedOwnership
                          ? null
                          : () async {
                              endpointTestStatus = null;
                              endpointTestError = null;

                              final extractor = OPDSExtractor()
                                ..useBasicAuth(
                                  source.username,
                                  source.password,
                                );

                              try {
                                await extractor.getFeed(Uri.parse(source.url));
                                endpointTestStatus = true;
                              } catch (e) {
                                endpointTestStatus = false;
                                endpointTestError = e.toString();
                              } finally {
                                setState(() {});
                              }
                            },
                      icon: const Icon(Icons.bolt),
                      label: const Text("Test endpoint"),
                    ),
                  ),
                  if (endpointTestStatus != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: endpointTestStatus!
                          ? const Text("Valid feed detected.")
                          : Text("Invalid endpoint.\n\n$endpointTestError"),
                    ),
                  const Divider(),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    initialValue: source.label,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      errorText: _nameFieldError,
                      labelText: "Name this source",
                    ),
                    onChanged: (value) {
                      source.label = value;
                      _nameFieldError =
                          value.trim().isEmpty ? 'Please enter a name' : null;

                      setState(() {});
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: !formIsValid()
                      ? null
                      : () {
                          dbSources.upsert(source);
                          context.goNamed(
                            BKPageFetchSource.name,
                            extra: source,
                          );
                        },
                  child: const Text("Save and crawl"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
