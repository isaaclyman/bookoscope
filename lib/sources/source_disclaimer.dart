import 'package:flutter/material.dart';

class BKSourceDisclaimer extends StatelessWidget {
  const BKSourceDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Tooltip(
      showDuration: Duration(seconds: 10),
      triggerMode: TooltipTriggerMode.tap,
      message: "Bookoscope is not a traditional OPDS navigator. It crawls "
          "the entire OPDS tree provided by the endpoint, which may "
          "involve thousands of sequential HTTP requests. Please be "
          "mindful of the library size and license agreement of any "
          "endpoints you crawl.",
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "Please confirm you own this endpoint or "
                  "have permission to use it without rate limits.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            WidgetSpan(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 1,
                ),
                child: Icon(
                  Icons.help,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
