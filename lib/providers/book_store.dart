import 'package:flutter/foundation.dart';
import '../models/book.dart';

/// Holds the list of books the user has added to their local store.
class BookStore extends ChangeNotifier {
  final List<Book> _books = [];

  List<Book> get books => List.unmodifiable(_books);

  bool contains(String key) => _books.any((b) => b.key == key);

  /// Add a book if it is not already present. Returns true if added.
  bool addBook(Book book) {
    if (contains(book.key)) return false;
    _books.add(book);
    notifyListeners();
    return true;
  }

  /// Remove a book by its Open Library key.
  void removeBook(String key) {
    _books.removeWhere((b) => b.key == key);
    notifyListeners();
  }
}
