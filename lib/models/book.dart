class Book {
  final String key; // Open Library key e.g. /works/OL45804W
  final String title;
  final List<String> authors;
  final String? coverId; // numeric cover id from Open Library
  final int? firstPublishYear;
  final String? description;

  const Book({
    required this.key,
    required this.title,
    required this.authors,
    this.coverId,
    this.firstPublishYear,
    this.description,
  });

  /// Parse from Open Library search result doc JSON.
  factory Book.fromSearchJson(Map<String, dynamic> json) {
    final authorNames = (json['author_name'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final coverId = json['cover_i']?.toString();
    return Book(
      key: json['key'] as String,
      title: json['title'] as String? ?? 'Unknown Title',
      authors: authorNames,
      coverId: coverId,
      firstPublishYear: json['first_publish_year'] as int?,
    );
  }

  /// Parse from Open Library works detail JSON.
  factory Book.fromWorksJson(Map<String, dynamic> json) {
    String? desc;
    final rawDesc = json['description'];
    if (rawDesc is String) {
      desc = rawDesc;
    } else if (rawDesc is Map) {
      desc = rawDesc['value'] as String?;
    }
    final covers = (json['covers'] as List<dynamic>?);
    final coverId = covers != null && covers.isNotEmpty
        ? covers.first.toString()
        : null;
    return Book(
      key: json['key'] as String,
      title: json['title'] as String? ?? 'Unknown Title',
      authors: [], // authors fetched separately in detail view
      coverId: coverId,
      description: desc,
    );
  }

  String get coverUrl {
    if (coverId == null) return '';
    return 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
  }
}
