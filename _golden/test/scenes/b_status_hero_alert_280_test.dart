import 'package:flutter/widgets.dart';
import 'package:onewifi_android/design/one/one_status_hero.dart';

import '../support/scene.dart';
import '../support/status_hero_scene.dart';

void main() {
  goldenScene(
    'status_hero_alert_280',
    () => statusHeroScene(OneChannelState.inactive),
    size: const Size(280, 844),
  );
}
