import 'package:flutter/material.dart';

import '../support/scene.dart';

void main() {
  goldenScene('filter_chip', () => const FilterChipScene());
}

class FilterChipScene extends StatelessWidget {
  const FilterChipScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('All'),
          selected: true,
          onSelected: (_) {},
        ),
        FilterChip(
          label: const Text('Slot 12'),
          selected: false,
          onSelected: (_) {},
        ),
        const FilterChip(
          label: Text('Off'),
          selected: false,
          onSelected: null,
        ),
      ],
    );
  }
}
