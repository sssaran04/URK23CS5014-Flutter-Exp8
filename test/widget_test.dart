import 'package:book_search_firestore/models/book.dart';
import 'package:book_search_firestore/screens/book_search_screen.dart';
import 'package:book_search_firestore/services/book_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _DeniedService extends BookService {
  _DeniedService() : super(firestore: FakeFirebaseFirestore());

  @override
  Future<List<Book>> searchBooksByTitle(String input) async {
    throw FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied');
  }
}

Future<FakeFirebaseFirestore> _seeded() async {
  final db = FakeFirebaseFirestore();
  final books = db.collection('books');
  await books.doc('9780134685991').set(
      {'title': 'Effective Java', 'author': 'Joshua Bloch', 'copies': 5});
  await books.doc('9780132350884').set(
      {'title': 'Clean Code', 'author': 'Robert C. Martin', 'copies': 0});
  return db;
}

Future<void> _pump(WidgetTester tester, BookService service) {
  return tester.pumpWidget(
    MaterialApp(home: BookSearchScreen(service: service)),
  );
}

Future<void> _search(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.tap(find.widgetWithText(FilledButton, 'Search'));
  await tester.pumpAndSettle();
}

void main() {
  const warning = 'Not Available – All Copies Issued';

  testWidgets('exact title shows the required line without a warning',
      (tester) async {
    await _pump(tester, BookService(firestore: await _seeded()));
    await _search(tester, 'Effective Java');
    expect(find.text('Effective Java – Joshua Bloch – 5'), findsOneWidget);
    expect(find.text(warning), findsNothing);
  });

  testWidgets('lower-case partial input finds the book through the fallback',
      (tester) async {
    await _pump(tester, BookService(firestore: await _seeded()));
    await _search(tester, 'java');
    expect(find.text('Effective Java – Joshua Bloch – 5'), findsOneWidget);
  });

  testWidgets('copies == 0 shows the warning in red', (tester) async {
    await _pump(tester, BookService(firestore: await _seeded()));
    await _search(tester, 'Clean Code');
    expect(find.text('Clean Code – Robert C. Martin – 0'), findsOneWidget);
    expect(tester.widget<Text>(find.text(warning)).style?.color, Colors.red);
  });

  testWidgets('no match shows Book not found', (tester) async {
    await _pump(tester, BookService(firestore: await _seeded()));
    await _search(tester, 'Harry Potter');
    expect(find.text('Book not found'), findsOneWidget);
  });

  testWidgets('empty input shows a message and does not search', (tester) async {
    await _pump(tester, _DeniedService());
    await _search(tester, '   ');
    expect(find.text('Please enter a book title'), findsOneWidget);
  });

  testWidgets('pressing Enter also searches', (tester) async {
    await _pump(tester, BookService(firestore: await _seeded()));
    await tester.enterText(find.byType(TextField), 'Clean Code');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Clean Code – Robert C. Martin – 0'), findsOneWidget);
  });

  testWidgets('a Firestore error shows a readable message', (tester) async {
    await _pump(tester, _DeniedService());
    await _search(tester, 'Clean Code');
    expect(
      find.text('Permission denied. You cannot read the books collection.'),
      findsOneWidget,
    );
  });
}
