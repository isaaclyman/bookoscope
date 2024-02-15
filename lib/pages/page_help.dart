import 'package:bookoscope/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BKPageHelp extends StatelessWidget {
  static const name = "Help";

  const BKPageHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      child: Column(
        children: [
          const Text(
            "Bookoscope",
            style: TextStyle(fontSize: 24),
          ),
          const Text("© 2024 by Isaac Lyman"),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Got a feature request? Found a bug? "
                      "OPDS feed not parsing correctly? "
                      "File an issue in Bookoscope's GitHub repository.",
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ElevatedButton(
                        onPressed: () async {
                          await launchUrl(
                            Uri.parse(
                              "https://github.com/isaaclyman/bookoscope/issues/new/choose",
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.accent.withAlpha(180),
                          foregroundColor: context.colors.accentContrast,
                        ),
                        child: const Text("File an issue"),
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
