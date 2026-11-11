import 'package:flutter/material.dart';

import '../support/scene.dart';

void main() {
  goldenScene('filled_button', () => const FilledButtonScene());
}

class FilledButtonScene extends StatelessWidget {
  const FilledButtonScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton(onPressed: () {}, child: const Text('Continue')),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.check),
          label: const Text('Confirm 3'),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(onPressed: () {}, child: const Text('Tonal')),
        const SizedBox(height: 12),
        const FilledButton(onPressed: null, child: Text('Disabled')),
      ],
    );
  }
}
