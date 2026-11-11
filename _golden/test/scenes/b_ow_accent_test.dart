import 'package:flutter/material.dart';
import 'package:onewifi_android/design/one/glass.dart' hide GlassPanel;
import 'package:onewifi_android/design/widgets/ow_accent.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

void main() {
  goldenScene('ow_accent', () => const OwAccentScene());
}

/// Plate tones, metric tones, selected edge, and plate shadow from [OwAccent].
class OwAccentScene extends StatelessWidget {
  const OwAccentScene({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    return bFrame(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final tone in PlateTone.values)
                _swatch(OwAccent.of(tone, scheme), tone.name, dark),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final tone in MetricTone.values)
                _swatch(OwAccent.ofMetric(tone), tone.name, dark),
            ],
          ),
          const SizedBox(height: 20),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Glass.radiusCard),
              border: OwAccent.selectedBorder(OwAccent.green, dark),
              boxShadow: OwAccent.selectedShadow(OwAccent.green),
              gradient: OwAccent.selectedSheen(OwAccent.green, dark),
            ),
            child: SelectedEdgeLight(
              accent: OwAccent.green,
              radius: Glass.radiusCard,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Text(
                  'Selected',
                  style: TextStyle(color: OwAccent.ink(OwAccent.green, dark)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(Glass.radiusTile),
              boxShadow: OwAccent.plateShadow(OwAccent.teal),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Plate'),
            ),
          ),
        ],
      ),
      width: 280,
    );
  }
}

Widget _swatch(Color color, String label, bool dark) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: OwAccent.dotGlow(color, dark),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(fontSize: 11, color: OwAccent.ink(color, dark)),
      ),
    ],
  );
}
