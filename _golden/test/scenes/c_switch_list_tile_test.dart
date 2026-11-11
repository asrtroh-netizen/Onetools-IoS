import 'package:flutter/material.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

void main() {
  goldenScene('switch_list_tile', () => const SwitchListTileScene());
}

class SwitchListTileScene extends StatelessWidget {
  const SwitchListTileScene({super.key});

  @override
  Widget build(BuildContext context) {
    return bFrame(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Wi Fi'),
            value: true,
            onChanged: (_) {},
          ),
          SwitchListTile(
            title: const Text('Notify'),
            value: false,
            onChanged: (_) {},
          ),
        ],
      ),
      width: 340,
    );
  }
}
