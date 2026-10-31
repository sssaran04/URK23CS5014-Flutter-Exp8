import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.copies,
  });

  final String id; // Firestore Document ID (the ISBN)
  final String title;
  final String author;
  final int copies;

  factory Book.fromMap(String id, Map<String, dynamic> data) {
    return Book(
      id: id,
      title: data['title'] as String? ?? '',
      author: data['author'] as String? ?? '',
      copies: (data['copies'] as num?)?.toInt() ?? 0,
    );
  }

  factory Book.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Book.fromMap(doc.id, doc.data() ?? const {});
  }

  bool get isAvailable => copies > 0;

  /// The required display format: Title – Author – Copies Available.
  String get displayLine => '$title – $author – $copies';
}
