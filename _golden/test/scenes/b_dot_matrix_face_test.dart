import 'package:flutter/material.dart';
import 'package:onewifi_android/design/one/dot_matrix_face.dart';
import 'package:onewifi_android/design/widgets/ow_accent.dart';

import '../support/scene.dart';

void main() {
  goldenScene('dot_matrix_face', () => const DotMatrixFaceScene());
}

/// Smile and frown [DotMatrixFace], small and large.
class DotMatrixFaceScene extends StatelessWidget {
  const DotMatrixFaceScene({super.key});

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onSurface;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DotMatrixFace(
              mood: DotMatrixMood.smile,
              color: ink,
              size: 36,
              semanticLabel: 'Ready',
            ),
            const SizedBox(width: 24),
            DotMatrixFace(
              mood: DotMatrixMood.frown,
              color: ink,
              size: 36,
              semanticLabel: 'Down',
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DotMatrixFace(
              mood: DotMatrixMood.smile,
              color: OwAccent.green,
              size: 72,
              semanticLabel: 'Ready',
            ),
            SizedBox(width: 28),
            DotMatrixFace(
              mood: DotMatrixMood.frown,
              color: OwAccent.red,
              size: 72,
              semanticLabel: 'Down',
            ),
          ],
        ),
      ],
    );
  }
}
