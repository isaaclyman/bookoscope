import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

void expectNotNull(Object? target) {
  expect(target != null, true, reason: 'Value is null.');
}

void expectContains<T>(
  Iterable<T>? iterable, {
  T? literal,
  bool Function(T element)? matcher,
}) {
  assert(
    literal != null || matcher != null,
    'Either a literal element or a matcher must be provided.',
  );

  expect(iterable != null, true, reason: 'Iterable was null');

  final result = iterable?.firstWhereOrNull((element) {
    if (literal != null) {
      return literal == element;
    }

    if (matcher != null) {
      return matcher(element);
    }

    return false;
  });
  expect(
    result != null,
    true,
    reason: 'Iterable contained no matching element',
  );
}

void expectEmpty<T>(Iterable<T>? iterable) {
  expectNotNull(iterable);
  expect(
    iterable!.isEmpty,
    true,
    reason: 'Iterable was not empty; contains ${iterable.length} elements.',
  );
}
