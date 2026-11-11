import 'package:flutter/material.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

void main() {
  goldenScene('card', () => const CardScene());
}

class CardScene extends StatelessWidget {
  const CardScene({super.key});

  @override
  Widget build(BuildContext context) {
    return bFrame(
      const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Slot 12'),
              SizedBox(height: 8),
              Text('Ready'),
            ],
          ),
        ),
      ),
      width: 280,
    );
  }
}
