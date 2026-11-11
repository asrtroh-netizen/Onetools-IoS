import 'package:flutter/material.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

void main() {
  goldenScene('list_tile', () => const ListTileScene());
}

class ListTileScene extends StatelessWidget {
  const ListTileScene({super.key});

  @override
  Widget build(BuildContext context) {
    return bFrame(
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.wifi),
            title: Text('Network'),
            subtitle: Text('Slot 12'),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            title: Text('Plain'),
            subtitle: Text('Line 2'),
          ),
        ],
      ),
      width: 340,
    );
  }
}
