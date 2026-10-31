import 'package:book_search_firestore/models/book.dart';
import 'package:book_search_firestore/services/book_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Book.fromMap', () {
    test('reads every field', () {
      final book = Book.fromMap('9780134685991', {
        'title': 'Effective Java',
        'author': 'Joshua Bloch',
        'copies': 5,
      });
      expect(book.id, '9780134685991');
      expect(book.title, 'Effective Java');
      expect(book.author, 'Joshua Bloch');
      expect(book.copies, 5);
      expect(book.isAvailable, isTrue);
      expect(book.displayLine, 'Effective Java – Joshua Bloch – 5');
    });

    test('treats missing fields as empty and zero copies as unavailable', () {
      final book = Book.fromMap('x', const {});
      expect(book.title, '');
      expect(book.copies, 0);
      expect(book.isAvailable, isFalse);
    });
  });

  group('BookService.filterByTitle', () {
    const books = [
      Book(id: '1', title: 'Effective Java', author: 'A', copies: 1),
      Book(id: '2', title: 'Clean Code', author: 'B', copies: 0),
      Book(id: '3', title: 'Head First Design Patterns', author: 'C', copies: 3),
    ];

    List<String> titles(String query) =>
        BookService.filterByTitle(books, query).map((b) => b.title).toList();

    test('ignores case', () {
      expect(titles('clean code'), ['Clean Code']);
      expect(titles('CLEAN CODE'), ['Clean Code']);
    });

    test('matches part of a title', () {
      expect(titles('java'), ['Effective Java']);
      expect(titles('head first'), ['Head First Design Patterns']);
    });

    test('trims the query and returns nothing when there is no match', () {
      expect(titles('  java  '), ['Effective Java']);
      expect(titles('Harry Potter'), isEmpty);
    });
  });
}
