extension BKCoalesce on String {
  String coalesce(String other) {
    return trim().isNotEmpty ? this : other;
  }
}

extension BKCoalesceNullable on String? {
  String? coalesce(String? other) {
    return (this?.trim().isNotEmpty ?? false) ? this : other;
  }
}
