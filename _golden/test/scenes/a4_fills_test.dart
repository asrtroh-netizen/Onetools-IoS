import 'package:flutter/material.dart';
import 'package:onewifi_android/design/one/glass.dart';

import '../support/scene.dart';

void main() {
  goldenScene('a4_fills', () => const A4Fills());
}

/// Five fills plus the hairline stroke, sitting on [Glass.backdrop].
class A4Fills extends StatelessWidget {
  const A4Fills({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    final stroke = Glass.stroke(scheme, dark);
    final fills = <(String, Color)>[
      ('fill', Glass.fill(scheme, dark)),
      ('fillStrong', Glass.fillStrong(scheme, dark)),
      ('barFill', Glass.barFill(scheme, dark)),
      ('modalFill', Glass.modalFill(scheme, dark)),
      ('dialogFill', Glass.dialogFill(scheme, dark)),
    ];
    final label = theme.textTheme.labelLarge;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (name, color) in fills) ...[
          if (name != fills.first.$1) const SizedBox(height: Glass.cardGap),
          Container(
            width: 300,
            height: 72,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: Glass.padCard),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(Glass.radiusCard),
              border: Border.all(color: stroke, width: Glass.strokeWidth),
            ),
            child: Text(name, style: label),
          ),
        ],
      ],
    );
  }
}
