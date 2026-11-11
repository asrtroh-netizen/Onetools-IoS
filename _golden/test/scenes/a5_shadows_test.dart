import 'package:flutter/material.dart';
import 'package:onewifi_android/design/one/glass.dart';

import '../support/scene.dart';

void main() {
  goldenScene('a5_shadows', () => const A5Shadows());
}

/// Normal and strong [Glass.shadow], on [Glass.fillStrong] so the lift is visible.
class A5Shadows extends StatelessWidget {
  const A5Shadows({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    final label = theme.textTheme.titleSmall;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final strong in const <bool>[false, true])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
            child: Container(
              width: 220,
              height: 108,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Glass.fillStrong(scheme, dark),
                borderRadius: BorderRadius.circular(Glass.radiusCard),
                boxShadow: Glass.shadow(dark, strong: strong),
              ),
              child: Text(strong ? 'strong' : 'shadow', style: label),
            ),
          ),
      ],
    );
  }
}
