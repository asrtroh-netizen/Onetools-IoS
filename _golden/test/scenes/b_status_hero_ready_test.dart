import 'package:onewifi_android/design/one/one_status_hero.dart';

import '../support/scene.dart';
import '../support/status_hero_scene.dart';

void main() {
  goldenScene(
    'status_hero_ready',
    () => statusHeroScene(OneChannelState.ready),
  );
}
