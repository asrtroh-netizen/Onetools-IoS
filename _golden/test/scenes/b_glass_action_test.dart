import 'package:flutter/material.dart';
import 'package:onewifi_android/design/widgets/glass_action.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

void main() {
  goldenScene('glass_action', () => const GlassActionScene());
}

/// [GlassActionRow] of enabled, selected, and disabled [GlassActionButton].
/// Busy is off so this scene does not build [SystemSpinner].
class GlassActionScene extends StatelessWidget {
  const GlassActionScene({super.key});

  @override
  Widget build(BuildContext context) {
    return bFrame(
      GlassActionRow(
        children: [
          GlassActionButton(
            label: 'Refresh',
            icon: Icons.refresh,
            onPressed: () {},
          ),
          GlassActionButton(
            label: 'Saved',
            icon: Icons.check_circle,
            selected: true,
            onPressed: () {},
          ),
          GlassActionButton(
            label: 'Off',
            icon: Icons.cancel_outlined,
            onPressed: null,
          ),
        ],
      ),
      width: 320,
    );
  }
}
