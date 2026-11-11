import 'package:flutter/material.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

void main() {
  goldenScene('progress', () => const ProgressScene());
}

class ProgressScene extends StatelessWidget {
  const ProgressScene({super.key});

  @override
  Widget build(BuildContext context) {
    return bFrame(
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('40'),
          SizedBox(height: 8),
          SizedBox(
            height: 4,
            child: LinearProgressIndicator(value: 0.40),
          ),
          SizedBox(height: 24),
          Text('65'),
          SizedBox(height: 8),
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(value: 0.65),
          ),
        ],
      ),
      width: 240,
    );
  }
}
