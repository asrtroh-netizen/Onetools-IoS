import 'package:flutter/material.dart';
import 'package:onewifi_android/design/one/glass.dart';
import 'package:onewifi_android/design/widgets/glass_tile.dart';
import 'package:onewifi_android/design/widgets/ow_accent.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

void main() {
  goldenScene('glass_tile', () => const GlassTileScene());
}

/// [GlassTile] plain, toned, and selected. Width stays inside the 48px glow.
class GlassTileScene extends StatelessWidget {
  const GlassTileScene({super.key});

  @override
  Widget build(BuildContext context) {
    return bFrame(
      const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassTile(child: Text('Plain')),
          SizedBox(height: Glass.space16),
          GlassTile(tone: PlateTone.blue, child: Text('Blue')),
          SizedBox(height: Glass.space16),
          GlassTile(
            selected: true,
            semanticLabel: 'Selected',
            child: Text('Selected'),
          ),
        ],
      ),
      width: 250,
    );
  }
}
