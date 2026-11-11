import 'package:flutter/widgets.dart';

import '../support/dock_scene.dart';

void main() {
  for (final width in const <int>[320, 430]) {
    final size = Size(width.toDouble(), 844);
    final suffix = '_w$width';
    dockGolden('dock_static_0$suffix', selected: 0, size: size);
    dockGolden('dock_static_1$suffix', selected: 1, size: size);
    dockGolden('dock_static_2$suffix', selected: 2, size: size);
    dockGolden('dock_static_3$suffix', selected: 3, size: size);
    dockGolden('dock_slide_t000$suffix', selected: 0, slideTo: 2, slideT: 0, size: size);
    dockGolden('dock_slide_t025$suffix', selected: 0, slideTo: 2, slideT: 0.25, size: size);
    dockGolden('dock_slide_t050$suffix', selected: 0, slideTo: 2, slideT: 0.5, size: size);
    dockGolden('dock_slide_t075$suffix', selected: 0, slideTo: 2, slideT: 0.75, size: size);
    dockGolden('dock_slide_t100$suffix', selected: 0, slideTo: 2, slideT: 1, size: size);
    dockGolden('dock_pressed$suffix', selected: 0, pressed: true, size: size);
  }
}
