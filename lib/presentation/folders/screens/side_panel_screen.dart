import 'package:flutter/material.dart';

class SidePanelScreen extends StatelessWidget {
  const SidePanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surface,
      child: const SafeArea(child: Column(children: [])),
    );
  }
}
