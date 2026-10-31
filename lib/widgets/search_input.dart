import 'package:flutter/material.dart';

class SearchInput extends StatelessWidget {
  const SearchInput({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    // Rebuilds on each keystroke so the clear button shows only when needed.
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => onSubmitted(),
          decoration: InputDecoration(
            labelText: 'Book title',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.clear),
                    onPressed: onClear,
                  ),
          ),
        );
      },
    );
  }
}
