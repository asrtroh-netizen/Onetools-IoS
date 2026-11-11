import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onewifi_android/design/widgets/glass_dialog.dart';

import '../support/platform_views.dart';
import '../support/scene.dart';

void main() {
  setUp(installEmptyPlatformViews);
  goldenScene('glass_dialog', () => const GlassDialogScene());
}

/// [OneGlassDialog]. On iOS the frame is a blank system glass view.
class GlassDialogScene extends StatelessWidget {
  const GlassDialogScene({super.key});

  @override
  Widget build(BuildContext context) {
    return const OneGlassDialog(
      title: 'Remove',
      message: 'Remove slot 12 now.',
      confirmLabel: 'Remove',
      cancelLabel: 'Cancel',
    );
  }
}
