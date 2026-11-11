import 'package:flutter/material.dart';
import 'package:onewifi_android/design/one/glass.dart';
import 'package:onewifi_android/design/widgets/nameplate.dart';
import 'package:onewifi_android/design/widgets/ow_accent.dart';

import '../support/scene.dart';

void main() {
  goldenScene('nameplate', () => const NameplateScene());
}

/// [Nameplate] flags that change paint: ready, tone, detail, hero, lifted, compact.
class NameplateScene extends StatelessWidget {
  const NameplateScene({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Nameplate(label: 'Online', ready: true),
        SizedBox(height: Glass.space12),
        Nameplate(label: 'Idle'),
        SizedBox(height: Glass.space12),
        Nameplate(label: 'SIM', detail: '8901', tone: PlateTone.teal),
        SizedBox(height: Glass.space12),
        Nameplate(
          label: 'Ready',
          detail: '24 ms',
          hero: true,
          ready: true,
        ),
        SizedBox(height: Glass.space12),
        Nameplate(label: 'CN', lifted: true, tone: PlateTone.blue),
        SizedBox(height: Glass.space12),
        Nameplate(label: 'Tunnel', compact: false, tone: PlateTone.purple),
      ],
    );
  }
}
