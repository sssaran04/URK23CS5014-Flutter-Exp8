"""One-time script that fills the Firestore "books" collection outside the Flutter app.

The ISBN is the Document ID, so rerunning skips existing books and creates no duplicates.
It only works while the temporary open books rule is deployed.
"""
import requests

PROJECT = "urk23cs5014-flutter-exp7"
URL = (
    f"https://firestore.googleapis.com/v1/projects/{PROJECT}"
    "/databases/(default)/documents/books"
)

BOOKS = [
    ("9780134685991", "Effective Java", "Joshua Bloch", 5),
    ("9780132350884", "Clean Code", "Robert C. Martin", 0),
    ("9780596007126", "Head First Design Patterns", "Eric Freeman", 3),
    ("9781617294136", "Flutter in Action", "Eric Windmill", 2),
    ("9780262033848", "Introduction to Algorithms", "Thomas H. Cormen", 0),
    ("9781491950357", "Building Microservices", "Sam Newman", 4),
]


def create_book(isbn, title, author, copies):
    fields = {
        "title": {"stringValue": title},
        "author": {"stringValue": author},
        # Firestore REST sends 64-bit integers as strings; it is stored as a number.
        "copies": {"integerValue": str(copies)},
    }
    response = requests.post(
        URL, params={"documentId": isbn}, json={"fields": fields}, timeout=30
    )
    if response.status_code == 409:  # ALREADY_EXISTS
        print(f"skipped {isbn} (already exists)")
        return
    response.raise_for_status()
    print(f"created {isbn} {title}")


if __name__ == "__main__":
    for book in BOOKS:
        create_book(*book)
