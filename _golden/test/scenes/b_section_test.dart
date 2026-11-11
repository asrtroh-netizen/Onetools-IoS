import 'package:flutter/material.dart';
import 'package:onewifi_android/design/widgets/ow_accent.dart';
import 'package:onewifi_android/design/widgets/section.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

void main() {
  goldenScene('section', () => const SectionScene());
}

/// [OwSection]: toned title icon, description, trailing slot, body.
class SectionScene extends StatelessWidget {
  const SectionScene({super.key});

  @override
  Widget build(BuildContext context) {
    return bFrame(
      const OwSection(
        title: 'Devices',
        desc: '4 modules online',
        icon: Icons.devices_other_outlined,
        tone: PlateTone.teal,
        semanticLabel: 'Devices',
        actions: Text('Edit'),
        child: Text('Slot A 01'),
      ),
    );
  }
}
