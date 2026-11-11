import 'package:flutter/widgets.dart';
import 'package:onewifi_android/design/widgets/stage_row.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

void main() {
  goldenScene('stage_row', () => const StageRowScene());
}

/// [StageRow] with ready, active, failed, and pending bars.
class StageRowScene extends StatelessWidget {
  const StageRowScene({super.key});

  @override
  Widget build(BuildContext context) {
    return bFrame(
      const StageRow(
        semanticLabel: 'Progress',
        stages: [
          ('SIM', StageState.ready),
          ('Link', StageState.active),
          ('IMS', StageState.failed),
          ('Card', StageState.pending),
        ],
      ),
      width: 320,
    );
  }
}
