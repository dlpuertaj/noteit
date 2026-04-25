import 'package:flutter/material.dart';

class SearchResultItem extends StatelessWidget {
  const SearchResultItem({
    super.key,
    required this.title,
    required this.folderName,
    required this.onTap,
  });

  final String title;
  final String folderName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title.isEmpty ? 'Untitled' : title),
      subtitle: Text(folderName),
      onTap: onTap,
    );
  }
}
