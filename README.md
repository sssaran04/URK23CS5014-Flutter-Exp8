# Experiment 8: Firestore Data Retrieval

24CS2016 - Building Applications using Flutter | URK23CS5014

## Aim

To design and implement a Flutter application that retrieves book details from Google Cloud Firestore based on the title entered by the user and displays the matching records dynamically.

## Requirements

- The app only reads the `books` collection. It never adds, updates or deletes books.
- A text field and a Search button. Pressing Enter also searches.
- An exact `where('title', isEqualTo: ...)` query runs first. If it returns nothing, the app fetches the collection and matches titles case-insensitively, because Firestore queries are case-sensitive and do not support "contains".
- Each match is shown as `Title – Author – Copies Available`.
- `copies == 0` shows `Not Available – All Copies Issued` in red below the book.
- No match shows `Book not found`. Empty input shows `Please enter a book title` and does not query.
- A progress indicator while fetching, and readable messages for errors such as permission denied or no internet.

## How the books collection was filled

The books were added outside the Flutter app, in the existing `urk23cs5014-flutter-exp7` Firebase project:

1. A temporary rule allowing writes to `books` was deployed.
2. `tools/seed_books.py` was run once. It calls the Firestore REST API, uses the ISBN as the Document ID, and skips books that already exist.
3. The rule was changed to read-only straight away (`allow read: if true; allow write: if false;`) and deployed again. The script can no longer write, and neither can any client.

| ISBN (Document ID) | Title | Author | Copies |
| --- | --- | --- | --- |
| 9780134685991 | Effective Java | Joshua Bloch | 5 |
| 9780132350884 | Clean Code | Robert C. Martin | 0 |
| 9780596007126 | Head First Design Patterns | Eric Freeman | 3 |
| 9781617294136 | Flutter in Action | Eric Windmill | 2 |
| 9780262033848 | Introduction to Algorithms | Thomas H. Cormen | 0 |
| 9781491950357 | Building Microservices | Sam Newman | 4 |

`firestore.rules` also holds the Experiment 7 `employees` rule, because both apps share one project and deploying replaces the whole rules file. Keep it the same as `firestore.rules` in the Experiment 7 repo.

## How to run

```
flutter pub get
flutter run
flutter test
```

## Screenshots

| Search screen | Empty input | Book found |
| --- | --- | --- |
| ![Search screen](screenshots/1_search_screen.png) | ![Empty input](screenshots/2_empty_input_message.png) | ![Book found](screenshots/3_book_found.png) |

| Case-insensitive partial search | Not available | Book not found |
| --- | --- | --- |
| ![Partial search](screenshots/4_partial_case_insensitive.png) | ![Not available](screenshots/5_not_available.png) | ![Book not found](screenshots/6_book_not_found.png) |
