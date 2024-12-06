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

  var timeSinceInstallation = DateTime.now().difference(installedDate);
  if (timeSinceInstallation.inDays < 7) {
    return;
  }

  final requested = prefs.getString(requestedDateKey);
  final requestedDate = requested == null ? null : DateTime.tryParse(requested);
  final shouldRequest = requestedDate == null ||
      DateTime.now().difference(requestedDate).inDays > 14;

  if (shouldRequest && await inAppReview.isAvailable()) {
    await prefs.setString(requestedDateKey, DateTime.now().toIso8601String());
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
