import 'package:flutter/material.dart';

class NoteSearchBar extends StatefulWidget {
  const NoteSearchBar({super.key, required this.onChanged});

  final void Function(String query) onChanged;

  @override
  State<NoteSearchBar> createState() => _NoteSearchBarState();
}

class _NoteSearchBarState extends State<NoteSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('search_field'),
      controller: _controller,
      focusNode: _focusNode,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search notes...',
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: widget.onChanged,
    );
  }
}
