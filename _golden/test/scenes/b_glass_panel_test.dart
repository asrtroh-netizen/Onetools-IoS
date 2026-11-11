import 'package:flutter/material.dart';
import 'package:onewifi_android/design/one/glass.dart' hide GlassPanel;
import 'package:onewifi_android/design/widgets/glass_panel.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

void main() {
  goldenScene('glass_panel', () => const GlassPanelScene());
}

/// [GlassPanel] strong fill and the lighter fill, both real frosted panels.
class GlassPanelScene extends StatelessWidget {
  const GlassPanelScene({super.key});

  @override
  Widget build(BuildContext context) {
    return bFrame(
      const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassPanel(semanticLabel: 'Strong', child: Text('Strong')),
          SizedBox(height: Glass.space24),
          GlassPanel(
            strong: false,
            semanticLabel: 'Fill',
            child: Text('Fill'),
          ),
        ],
      ),
      width: 280,
    );
  }
}
