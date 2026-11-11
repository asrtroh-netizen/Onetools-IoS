import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/scene.dart';

void main() {
  goldenScene(
    'popup_menu',
    () => const PopupMenuScene(),
    afterSettle: (tester) async {
      await tester.tap(find.byIcon(Icons.more_vert));
      // PopupMenuRoute transition is 300ms. Do not pumpAndSettle.
      await tester.pump(const Duration(milliseconds: 300));
    },
  );
}

class PopupMenuScene extends StatelessWidget {
  const PopupMenuScene({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => const [
        PopupMenuItem(value: 1, child: Text('Alpha')),
        PopupMenuItem(value: 2, child: Text('Beta 12')),
        PopupMenuItem(value: 3, child: Text('Gamma')),
      ],
    );
  }
}
