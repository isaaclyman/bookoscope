import 'package:bookoscope/db/source.db.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final editingSource = GoRouterState.of(context).extra as Source?;
    isNew = editingSource == null;

    if (editingSource != null) {
      source = editingSource;
    }

    confirmedOwnership = !isNew;
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

    return SingleChildScrollView(
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

                  final canParse =
                      Uri.tryParse(value)?.host.isNotEmpty ?? false;
                  _urlFieldError = !canParse ? 'Not a valid URL' : null;

                  setState(() {});
                },
              ),
            ),
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
                  onPressed: !confirmedOwnership ? null : () {},
                  icon: const Icon(Icons.bolt),
                  label: const Text("Test endpoint"),
                ),
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
            //
            // AUTHENTICATION IS NOT YET IMPLEMENTED
            //
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 8),
            //   child: TextFormField(
            //     initialValue: source.username,
            //     decoration: const InputDecoration(
            //       border: OutlineInputBorder(),
            //       labelText: "Username (if required)",
            //     ),
            //     onChanged: (value) => setState(() {
            //       source.username = value;
            //     }),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 8),
            //   child: TextFormField(
            //     initialValue: source.password,
            //     decoration: const InputDecoration(
            //       border: OutlineInputBorder(),
            //       labelText: "Password (if required)",
            //     ),
            //     onChanged: (value) => setState(() {
            //       source.password = value;
            //     }),
            //   ),
            // ),
            ElevatedButton(
              onPressed: !formIsValid()
                  ? null
                  : () {
                      dbSources.upsert(source);
                      context.goNamed(BKPageFetchSource.name, extra: source);
                    },
              child: const Text("Save and crawl"),
            ),
          ],
        ),
      ),
    );
  }
}
