class GCSVRow {
  int id;
  String title;
  String? issued;
  String? language;
  List<String>? authors;
  List<String>? subjects;
  List<String>? bookshelves;

  GCSVRow.fromMap(Map<String, dynamic> map)
      : id = map['Text#'] as int,
        title = map['Title'] as String,
        issued = map['Issued'] as String?,
        language = map['Language'] as String?,
        authors = (map['Authors'] as String)
            .split(';')
            .map((author) => author.trim())
            .toList(),
        subjects = (map['Subjects'] as String)
            .split(';')
            .map((subject) => subject.trim())
            .toList(),
        bookshelves = (map['Bookshelves'] as String)
            .split(';')
            .map((shelf) => shelf.trim())
            .toList();
}
