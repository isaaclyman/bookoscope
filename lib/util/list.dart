extension BKDistinct<T, V> on Iterable<T> {
  List<T> distinct() {
    return toSet().toList();
  }

  List<T> distinctBy(V Function(T element) selectComparable) {
    final comparables = <V>{};
    final mutableList = List<T>.from(this);
    mutableList.retainWhere(
      (element) => comparables.add(selectComparable(element)),
    );
    return mutableList;
  }
}
