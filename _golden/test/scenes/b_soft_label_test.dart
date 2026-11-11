import 'package:flutter/widgets.dart';
import 'package:onewifi_android/design/widgets/soft_label.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

void main() {
  goldenScene('soft_label', () => const SoftLabelScene());
}

/// [SoftLabelGrid]: two columns, last odd cell on its own row. No monospace font.
class SoftLabelScene extends StatelessWidget {
  const SoftLabelScene({super.key});

  @override
  Widget build(BuildContext context) {
    return bFrame(
      const SoftLabelGrid(
        children: [
          SoftLabel(title: 'ICCID', value: '8901 2345'),
          SoftLabel(title: 'Number', value: '1380000', sub: 'Tail 0000'),
          SoftLabel(title: 'State', value: 'Down', danger: true),
        ],
      ),
    );
  }
}
