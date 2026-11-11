import 'package:flutter_test/flutter_test.dart';
import 'package:onewifi_android/design/one/one_status_hero.dart';

import '../support/platform_views.dart';
import '../support/scene.dart';
import '../support/status_hero_scene.dart';

void main() {
  setUp(installEmptyPlatformViews);
  goldenScene(
    'status_hero_busy',
    () => statusHeroScene(OneChannelState.activating),
  );
}
