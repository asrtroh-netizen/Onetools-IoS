import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/scene.dart';

void main() {
  goldenScene(
    'snack_bar',
    () => const SizedBox.shrink(),
    afterSettle: (tester) async {
      ScaffoldMessenger.of(tester.element(find.byType(Scaffold))).showSnackBar(
        SnackBar(
          content: const Text('Saved 12'),
          action: SnackBarAction(label: 'Undo', onPressed: () {}),
        ),
      );
      // Entrance is 250ms. pumpAndSettle would also fire the 4s dismiss timer.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
    },
  );
}
