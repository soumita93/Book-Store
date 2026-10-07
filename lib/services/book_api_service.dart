import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

/// Wraps the Open Library public REST API.
/// Base URL: https://openlibrary.org
/// No API key required.
class BookApiService {
  static const _base = 'https://openlibrary.org';

  final http.Client _client;

  BookApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Search books by [query]. Returns up to [limit] results.
  Future<List<Book>> searchBooks(String query, {int limit = 20}) async {
    final uri = Uri.parse(
      '$_base/search.json?q=${Uri.encodeQueryComponent(query)}&limit=$limit&fields=key,title,author_name,cover_i,first_publish_year',
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Search failed: HTTP ${response.statusCode}');
    }
    final body = json.decode(response.body) as Map<String, dynamic>;
    final docs = (body['docs'] as List<dynamic>?) ?? [];
    return docs
        .map((d) => Book.fromSearchJson(d as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a single book's detail from its works key, e.g. /works/OL45804W.
  Future<Book> fetchBookDetail(String worksKey) async {
    final uri = Uri.parse('$_base$worksKey.json');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Fetch detail failed: HTTP ${response.statusCode}');
    }
    final body = json.decode(response.body) as Map<String, dynamic>;
    return Book.fromWorksJson(body);
  }
}
