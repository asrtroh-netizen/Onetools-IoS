import 'package:flutter/material.dart';
import 'package:onewifi_android/design/widgets/metric_card.dart';
import 'package:onewifi_android/design/widgets/ow_accent.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

void main() {
  goldenScene('metric_card', () => const MetricCardScene());
}

/// Three [MetricCard] tones in a [MetricRow]. Width under 360 keeps one column.
class MetricCardScene extends StatelessWidget {
  const MetricCardScene({super.key});

  @override
  Widget build(BuildContext context) {
    return bFrame(
      const MetricRow(
        children: [
          MetricCard(
            label: 'Modules',
            value: '12',
            sub: 'Online slots',
            icon: Icons.devices_other_outlined,
            tone: MetricTone.blue,
          ),
          MetricCard(
            label: 'Contacts',
            value: '4',
            sub: 'All devices',
            icon: Icons.sms_outlined,
            tone: MetricTone.green,
          ),
          MetricCard(
            label: 'Session',
            value: 'A1',
            sub: 'Peer 24',
            icon: Icons.smartphone_outlined,
            tone: MetricTone.purple,
          ),
        ],
      ),
    );
  }
}
