import 'package:flutter/material.dart';

import '../support/scene.dart';

void main() {
  goldenScene('a2_weights', () => const A2Weights());
}

/// 400/500/600/700 × 11/12/14/16/22/24.
/// Only Montserrat Regular is loaded, so 600 and 700 are Skia synthetic bold.
class A2Weights extends StatelessWidget {
  const A2Weights({super.key});

  static const weights = <FontWeight>[
    FontWeight.w400,
    FontWeight.w500,
    FontWeight.w600,
    FontWeight.w700,
  ];

  static const sizes = <double>[11, 12, 14, 16, 22, 24];

  static const sample = 'Hamburgefonstiv';

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final size in sizes)
          for (final weight in weights)
            Text(
              '${weight.value} ${size.toInt()} $sample',
              maxLines: 1,
              softWrap: false,
              style: base.copyWith(
                fontWeight: weight,
                fontSize: size,
                height: 1.05,
              ),
            ),
      ],
    );
  }
}
