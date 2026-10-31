import 'package:flutter/material.dart';

import '../models/book.dart';

class BookResultCard extends StatelessWidget {
  const BookResultCard({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.displayLine,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (!book.isAvailable) ...[
              const SizedBox(height: 8),
              const Text(
                'Not Available – All Copies Issued',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
