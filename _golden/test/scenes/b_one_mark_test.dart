import 'package:flutter/widgets.dart';
import 'package:onewifi_android/design/widgets/one_mark.dart';
import 'package:onewifi_android/design/widgets/ow_accent.dart';

import '../support/scene.dart';

void main() {
  goldenScene('one_mark', () => const OneMarkScene());
}

/// [OneMark] at three sizes. The middle mark uses the theme icon color.
class OneMarkScene extends StatelessWidget {
  const OneMarkScene({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OneMark(size: 72),
        SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OneMark(size: 24),
            SizedBox(width: 20),
            OneMark(size: 40, color: OwAccent.green),
            SizedBox(width: 20),
            OneMark(size: 40, color: OwAccent.red),
          ],
        ),
      ],
    );
  }
}
