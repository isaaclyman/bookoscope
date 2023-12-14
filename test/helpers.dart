import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

void expectNotNull(Object? target) {
  expect(target != null, true);
}

void expectContains<T>(
  Iterable<T>? iterable,
  bool Function(T element) matcher,
) {
  expect(iterable != null, true, reason: 'Iterable was null');
  final result = iterable?.firstWhereOrNull((element) => matcher(element));
  expect(
    result != null,
    true,
    reason: 'Iterable contained no matching element',
  );
}
