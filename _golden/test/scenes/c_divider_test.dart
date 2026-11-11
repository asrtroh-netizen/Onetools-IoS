import 'package:flutter/material.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

void main() {
  goldenScene('divider', () => const DividerScene());
}

class DividerScene extends StatelessWidget {
  const DividerScene({super.key});

  @override
  Widget build(BuildContext context) {
    return bFrame(
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Above'),
          Divider(),
          Text('Below 12'),
        ],
      ),
      width: 280,
    );
  }
}
