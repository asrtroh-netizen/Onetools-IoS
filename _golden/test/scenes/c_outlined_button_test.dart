import 'package:flutter/material.dart';

import '../support/scene.dart';

void main() {
  goldenScene('outlined_button', () => const OutlinedButtonScene());
}

class OutlinedButtonScene extends StatelessWidget {
  const OutlinedButtonScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton(onPressed: () {}, child: const Text('Outline')),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.share),
          label: const Text('Share 2'),
        ),
      ],
    );
  }
}
