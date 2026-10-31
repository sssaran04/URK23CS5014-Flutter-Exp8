import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/book.dart';
import '../services/book_service.dart';
import '../widgets/book_result_card.dart';
import '../widgets/message_view.dart';
import '../widgets/search_input.dart';

enum _SearchState { idle, emptyInput, loading, results, notFound, error }

class BookSearchScreen extends StatefulWidget {
  const BookSearchScreen({super.key, this.service});

  /// Lets tests supply a service backed by a fake Firestore.
  final BookService? service;

  @override
  State<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final _controller = TextEditingController();
  late final BookService _service = widget.service ?? BookService();

  _SearchState _state = _SearchState.idle;
  List<Book> _books = const [];
  String _error = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_state == _SearchState.loading) return;

    final input = _controller.text.trim();
    if (input.isEmpty) {
      setState(() => _state = _SearchState.emptyInput);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _state = _SearchState.loading);

    try {
      // Firestore READ: runs the title query (and the fallback if needed).
      final books = await _service.searchBooksByTitle(input);
      if (!mounted) return;
      setState(() {
        _books = books;
        _state = books.isEmpty ? _SearchState.notFound : _SearchState.results;
      });
    } on FirebaseException catch (e) {
      _showError(_messageFor(e));
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _state = _SearchState.error;
    });
  }

  String _messageFor(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Permission denied. You cannot read the books collection.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'No internet connection. Please check it and try again.';
      default:
        return 'Could not fetch books (${e.code}). Please try again.';
    }
  }

  void _clear() {
    _controller.clear();
    setState(() => _state = _SearchState.idle);
  }

  Widget _buildBody() {
    switch (_state) {
      case _SearchState.idle:
        return const MessageView(
          icon: Icons.menu_book_outlined,
          message: 'Enter a title and tap Search',
        );
      case _SearchState.emptyInput:
        return const MessageView(
          icon: Icons.info_outline,
          message: 'Please enter a book title',
        );
      case _SearchState.loading:
        return const Center(child: CircularProgressIndicator());
      case _SearchState.results:
        return ListView.builder(
          itemCount: _books.length,
          itemBuilder: (context, index) => BookResultCard(book: _books[index]),
        );
      case _SearchState.notFound:
        return const MessageView(
          icon: Icons.search_off,
          message: 'Book not found',
        );
      case _SearchState.error:
        return MessageView(
          icon: Icons.error_outline,
          message: _error,
          isError: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library Book Search')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchInput(
              controller: _controller,
              onSubmitted: _search,
              onClear: _clear,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _state == _SearchState.loading ? null : _search,
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }
}
