import '../support/ripple_scene.dart';
import '../support/scene.dart';

void main() {
  final samples = rippleSampleMs('hold');
  if (samples.join(',') != '0,75,200,500,1000') {
    throw StateError('hold samples $samples');
  }
  goldenScene(
    'a6_ripple_hold',
    () => RippleSamples(prefix: 'hold', samples: samples),
    afterSettle: (tester) => driveRipples(
      tester,
      prefix: 'hold',
      ages: samples,
      confirmed: false,
    ),
  );
}
