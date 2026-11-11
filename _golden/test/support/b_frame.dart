import 'package:flutter/widgets.dart';

/// Fixed width, unbounded height, so cards shrink-wrap instead of filling 844.
Widget bFrame(Widget child, {double width = 300}) {
  return UnconstrainedBox(
    constrainedAxis: Axis.horizontal,
    child: SizedBox(width: width, child: child),
  );
}
