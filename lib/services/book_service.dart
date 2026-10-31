import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/book.dart';

/// Read-only access to the "books" collection. The app never writes books.
class BookService {
  BookService({FirebaseFirestore? firestore})
      : _books = (firestore ?? FirebaseFirestore.instance).collection('books');

  final CollectionReference<Map<String, dynamic>> _books;

  // Always ask the server: the default get() answers from the empty local cache
  // when offline, which would look like "Book not found" instead of an error.
  static const _serverOnly = GetOptions(source: Source.server);

  Future<List<Book>> searchBooksByTitle(String input) async {
    final title = input.trim();
    if (title.isEmpty) return const [];

    // Firestore READ: exact title match.
    final exact = await _books.where('title', isEqualTo: title).get(_serverOnly);
    if (exact.docs.isNotEmpty) {
      return exact.docs.map(Book.fromFirestore).toList();
    }

    // Fallback: Firestore queries are case-sensitive and do not support
    // "contains", so "clean code" or "java" cannot match with where(). Fetch the
    // collection and match on the client instead.
    // Firestore READ: all documents in the books collection.
    final all = await _books.get(_serverOnly);
    return filterByTitle(all.docs.map(Book.fromFirestore), title);
  }

  /// Case-insensitive "title contains query" matching.
  static List<Book> filterByTitle(Iterable<Book> books, String query) {
    final needle = query.trim().toLowerCase();
    return books.where((b) => b.title.toLowerCase().contains(needle)).toList();
  }
}
