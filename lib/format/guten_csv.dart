class GCSVRow {
  int id;
  String title;
  String? issued;
  String? language;
  List<String>? authors;
  List<String>? subjects;
  List<String>? bookshelves;

  GCSVRow({
    required this.id,
    required this.title,
    this.issued,
    this.language,
    this.authors,
    this.subjects,
    this.bookshelves,
  });
}
