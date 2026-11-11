import 'package:flutter/material.dart';

import '../support/scene.dart';

void main() {
  goldenScene('a1_typography', () => const A1Typography());
}

/// Ten M3 roles OneWIFI design widgets actually reference, type-scale order.
/// Sizes come from ThemeData(useMaterial3) → _M3Typography.englishLike.
class A1Typography extends StatelessWidget {
  const A1Typography({super.key});

  static const sample = 'Hamburgefonstiv 0123456789';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final styles = <TextStyle?>[
      theme.headlineSmall,
      theme.titleLarge,
      theme.titleMedium,
      theme.titleSmall,
      theme.bodyLarge,
      theme.bodyMedium,
      theme.bodySmall,
      theme.labelLarge,
      theme.labelMedium,
      theme.labelSmall,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final style in styles)
          Text(sample, style: style, maxLines: 1, softWrap: false),
      ],
    );
  }
}
