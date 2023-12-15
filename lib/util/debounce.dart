import 'dart:async';

void Function() bkDebounce(Duration duration, Function() action) {
  Timer? timer;

  return () {
    timer?.cancel();
    timer = Timer(duration, action);
  };
}
