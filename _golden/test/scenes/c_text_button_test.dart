import 'package:flutter/material.dart';

import '../support/scene.dart';

void main() {
  goldenScene('text_button', () => const TextButtonScene());
}

class TextButtonScene extends StatelessWidget {
  const TextButtonScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(onPressed: () {}, child: const Text('Save')),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Add 12'),
        ),
      ],
    );
  }
}
