import 'package:flutter/material.dart';

import '../support/scene.dart';

void main() {
  goldenScene('icon_button', () => const IconButtonScene());
}

class IconButtonScene extends StatelessWidget {
  const IconButtonScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
      ],
    );
  }
}
