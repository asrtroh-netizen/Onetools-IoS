import 'package:flutter/material.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

void main() {
  goldenScene('checkbox_list_tile', () => const CheckboxListTileScene());
}

class CheckboxListTileScene extends StatelessWidget {
  const CheckboxListTileScene({super.key});

  @override
  Widget build(BuildContext context) {
    return bFrame(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            title: const Text('Keep 12'),
            value: true,
            onChanged: (_) {},
          ),
          CheckboxListTile(
            title: const Text('Share'),
            value: false,
            onChanged: (_) {},
          ),
        ],
      ),
      width: 340,
    );
  }
}
