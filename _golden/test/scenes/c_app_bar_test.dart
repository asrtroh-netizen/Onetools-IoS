import 'package:flutter/material.dart';

import '../support/scene.dart';

void main() {
  goldenScene('app_bar', () => const AppBarScene());
}

class AppBarScene extends StatelessWidget {
  const AppBarScene({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 390,
      height: kToolbarHeight,
      child: AppBar(
        primary: false,
        title: const Text('Tools'),
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
    );
  }
}
