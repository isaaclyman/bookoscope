import 'dart:async';

void Function() bkDebounce(
  Duration duration,
  Function() action, {
  Duration? maxDuration,
}) {
  Timer? timer;
  Timer? maxTimer;

  return () {
    timer?.cancel();
    timer = Timer(duration, action);

    if (maxDuration != null && (maxTimer == null || !maxTimer!.isActive)) {
      maxTimer = Timer(maxDuration, () {
        timer?.cancel();
        action();
      });
    }
  };
}
