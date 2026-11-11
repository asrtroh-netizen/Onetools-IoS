import 'package:flutter/material.dart';

import '../support/scene.dart';

void main() {
  goldenScene('alert_dialog', () => const AlertDialogScene());
}

class AlertDialogScene extends StatelessWidget {
  const AlertDialogScene({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text('Remove'),
      content: Text('Remove slot 12 now.'),
      actions: [
        TextButton(onPressed: _noop, child: Text('Cancel')),
        TextButton(onPressed: _noop, child: Text('Remove')),
      ],
    );
  }
}

void _noop() {}
