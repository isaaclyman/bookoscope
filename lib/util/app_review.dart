import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

final InAppReview inAppReview = InAppReview.instance;

const String installedDateKey = 'INSTALLED';
const String requestedDateKey = 'REQUESTED_REVIEW';

Future bkMaybeRequestReview() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  var installed = prefs.getStringWithDefault(
      installedDateKey, DateTime.now().toIso8601String());

  var installedDate = DateTime.tryParse(installed);
  if (installedDate == null) {
    return;
  }

  var requested = prefs.getStringWithDefault(
      requestedDateKey, DateTime.now().toIso8601String());

  var requestedDate = DateTime.tryParse(requested);
  if (requestedDate == null) {
    return;
  }

  var timeSinceInstallation = DateTime.now().difference(installedDate);
  var timeSinceLastRequest = DateTime.now().difference(requestedDate);

  if (timeSinceInstallation.inDays > 7 &&
      timeSinceLastRequest.inDays > 14 &&
      await inAppReview.isAvailable()) {
    await inAppReview.requestReview();
  }
}

extension _BKPrefsWithDefaults on SharedPreferences {
  String getStringWithDefault(String key, String defaultValue) {
    var value = getString(key);
    if (value == null) {
      value = defaultValue;
      setString(key, value);
    }
    return value;
  }
}
