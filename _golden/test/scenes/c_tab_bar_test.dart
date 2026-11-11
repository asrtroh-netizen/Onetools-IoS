import 'package:flutter/material.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

void main() {
  goldenScene('tab_bar', () => const TabBarScene());
}

class TabBarScene extends StatelessWidget {
  const TabBarScene({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: bFrame(
        const TabBar(
          tabs: [
            Tab(text: 'One'),
            Tab(text: 'Two'),
            Tab(text: '12'),
          ],
        ),
        width: 340,
      ),
    );
  }
}
