import 'package:flutter/widgets.dart';
import 'package:onewifi_android/design/widgets/choice_toggle.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

void main() {
  goldenScene('choice_toggle', () => const ChoiceToggleScene());
}

/// On, off, and disabled [ChoiceToggle]. Labels are the widget's own strings.
class ChoiceToggleScene extends StatelessWidget {
  const ChoiceToggleScene({super.key});

  @override
  Widget build(BuildContext context) {
    return bFrame(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChoiceToggle(value: true, onChanged: (_) {}),
          const SizedBox(height: 16),
          ChoiceToggle(value: false, onChanged: (_) {}),
          const SizedBox(height: 16),
          const ChoiceToggle(value: false, onChanged: null),
        ],
      ),
      width: 320,
    );
  }
}
