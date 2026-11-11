import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onewifi_android/design/one/glass.dart';
import 'package:onewifi_android/design/tokens/one_tokens.dart';

/// Sample times from `_golden/fixtures/ripple.json` (`hold` or `confirm`, light).
List<int> rippleSampleMs(String phase) {
  final ripple =
      jsonDecode(File('fixtures/ripple.json').readAsStringSync()) as Map<String, dynamic>;
  final branch = ripple[phase] as Map<String, dynamic>;
  final light = branch['light'] as List<dynamic>;
  return [
    for (final sample in light) (sample as Map<String, dynamic>)['ms'] as int,
  ];
}

/// Five [InkRipple] wells. Each well is [OneSizes.minimumTarget] square, the
/// reference box `ripple.json` was computed from.
class RippleSamples extends StatelessWidget {
  const RippleSamples({super.key, required this.prefix, required this.samples});

  final String prefix;
  final List<int> samples;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final fill = Glass.fillStrong(theme.colorScheme, dark);
    final label = theme.textTheme.labelSmall;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < samples.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: fill,
                child: InkWell(
                  key: ValueKey('$prefix-${samples[i]}'),
                  splashFactory: InkRipple.splashFactory,
                  // Pressed highlight is InkHighlight, not the ripple samples.
                  highlightColor: Colors.transparent,
                  onTap: () {},
                  child: const SizedBox(
                    width: OneSizes.minimumTarget,
                    height: OneSizes.minimumTarget,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text('${samples[i]}', style: label),
            ],
          ),
        ],
      ],
    );
  }
}

/// Drive real [InkWell] splashes to the fixture ages.
///
/// Hold: pointer stays down. [TapGestureRecognizer] waits [kPressTimeout]
/// before `onTapDown`, and the ticker's first frame reports elapsed 0, so each
/// birth pump ends exactly when that splash is created.
/// Confirm: pointer up in the same turn as pointer down, which creates and
/// confirms the splash together; a zero-duration pump then arms the ticker.
Future<void> driveRipples(
  WidgetTester tester, {
  required String prefix,
  required List<int> ages,
  required bool confirmed,
}) async {
  final box = tester.getSize(find.byKey(ValueKey('$prefix-${ages.first}')));
  if (box != const Size(OneSizes.minimumTarget, OneSizes.minimumTarget)) {
    throw StateError('ripple reference box is $box');
  }
  if (confirmed) {
    await _driveConfirmed(tester, prefix, ages);
  } else {
    await _driveHeld(tester, prefix, ages);
  }
}

Future<void> _driveConfirmed(WidgetTester tester, String prefix, List<int> ages) async {
  final snapshot = ages.reduce((a, b) => a > b ? a : b);
  final times = ages.map((age) => snapshot - age).toSet().toList()..sort();
  var clock = 0;
  var pointer = 1;
  for (final t in times) {
    if (t > clock) {
      await tester.pump(Duration(milliseconds: t - clock));
      clock = t;
    }
    final age = snapshot - t;
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(ValueKey('$prefix-$age'))),
      pointer: pointer,
    );
    pointer += 1;
    await gesture.up();
    await tester.pump(Duration.zero);
  }
}

Future<void> _driveHeld(WidgetTester tester, String prefix, List<int> ages) async {
  final press = kPressTimeout.inMilliseconds;
  final snapshot = ages.reduce((a, b) => a > b ? a : b) + press;
  final marks = <int>{0, snapshot};
  for (final age in ages) {
    final down = snapshot - age - press;
    if (down < 0) {
      throw StateError('hold age $age starts before t=0');
    }
    marks
      ..add(down)
      ..add(down + press);
  }
  final times = marks.toList()..sort();
  var pointer = 1;
  final started = <int>{};
  for (var i = 0; i < times.length - 1; i++) {
    final t = times[i];
    for (final age in ages) {
      if (snapshot - age - press == t && started.add(age)) {
        await tester.startGesture(
          tester.getCenter(find.byKey(ValueKey('$prefix-$age'))),
          pointer: pointer,
        );
        pointer += 1;
      }
    }
    await tester.pump(Duration(milliseconds: times[i + 1] - t));
  }
}
