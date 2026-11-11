import '../support/ripple_scene.dart';
import '../support/scene.dart';

void main() {
  final samples = rippleSampleMs('confirm');
  if (samples.join(',') != '0,75,225,400,600') {
    throw StateError('confirm samples $samples');
  }
  goldenScene(
    'a7_ripple_confirm',
    () => RippleSamples(prefix: 'confirm', samples: samples),
    afterSettle: (tester) => driveRipples(
      tester,
      prefix: 'confirm',
      ages: samples,
      confirmed: true,
    ),
  );
}
