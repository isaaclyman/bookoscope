import 'package:bookoscope/theme/text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class CPageAbout extends StatelessWidget {
  static const name = "About";

  const CPageAbout({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ),
      child: DefaultTextStyle.merge(
        style: context.text.small,
        child: Column(
          children: [
            Text(
              "CYPHER SYSTEM SRD LOOKUP",
              style: context.text.entryMainHeader,
            ),
            const Divider(
              height: 24,
            ),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text:
                        "This product is an independent production and is not affiliated with Monte Cook Games, LLC. "
                        "It is published under the Cypher System Open License, found at ",
                  ),
                  CLinkSpan(
                    context: context,
                    url: "http://csol.montecookgames.com",
                  ),
                  const TextSpan(
                    text:
                        ".\n\nCYPHER SYSTEM and its logo are trademarks of Monte Cook Games, LLC in the U.S.A. and other countries. "
                        "All Monte Cook Games characters and character names, and the distinctive likenesses thereof, are "
                        "trademarks of Monte Cook Games, LLC.",
                  ),
                ],
              ),
            ),
            const Divider(
              height: 24,
            ),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                      text:
                          "Aside from the embedded CSRD.json file, presented as data throughout the app and licensed above, "
                          "all app code and assets are released under Creative Commons Attribution-Sharealike 4.0 International "
                          "("),
                  CLinkSpan(
                    context: context,
                    url: "https://creativecommons.org/licenses/by-sa/4.0/",
                  ),
                  const TextSpan(
                    text: ").\n\n"
                        "These materials are publicly available at ",
                  ),
                  CLinkSpan(
                      context: context,
                      url:
                          "https://github.com/isaaclyman/cypher-system-srd-lookup"),
                  const TextSpan(text: "."),
                ],
              ),
            ),
            const Spacer(),
            TextButton(
                onPressed: () {
                  context.pop();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.arrow_back),
                    ),
                    Text("Return"),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class CLinkSpan extends TextSpan {
  factory CLinkSpan({
    required BuildContext context,
    required String url,
  }) {
    return CLinkSpan._(
      style: context.text.link,
      text: url,
      recognizer: TapGestureRecognizer()
        ..onTap = () async {
          try {
            await launchUrl(Uri.parse(url));
          } catch (ex) {
            debugPrint(ex.toString());
          }
        },
    );
  }

  const CLinkSpan._({
    super.text,
    super.style,
    super.recognizer,
  });
}
