import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onewifi_android/design/one/one_status_hero.dart';

import '../support/platform_views.dart';
import '../support/scene.dart';
import '../support/status_hero_scene.dart';
import 'b_choice_toggle_test.dart' show ChoiceToggleScene;
import 'b_dot_matrix_face_test.dart' show DotMatrixFaceScene;
import 'b_feature_failure_notice_test.dart' show FeatureFailureNoticeScene;
import 'b_glass_action_test.dart' show GlassActionScene;
import 'b_glass_dialog_test.dart' show GlassDialogScene;
import 'b_glass_panel_test.dart' show GlassPanelScene;
import 'b_glass_tile_test.dart' show GlassTileScene;
import 'b_metric_card_test.dart' show MetricCardScene;
import 'b_nameplate_test.dart' show NameplateScene;
import 'b_obscurable_field_test.dart' show ObscurableFieldScene;
import 'b_one_mark_test.dart' show OneMarkScene;
import 'b_ow_accent_test.dart' show OwAccentScene;
import 'b_page_head_test.dart' show PageHeadScene;
import 'b_section_test.dart' show SectionScene;
import 'b_soft_label_test.dart' show SoftLabelScene;
import 'b_stage_row_test.dart' show StageRowScene;

const List<int> _widths = <int>[320, 430];

void main() {
  setUp(() {
    EditableText.debugDeterministicCursor = true;
    installEmptyPlatformViews();
  });
  tearDown(() {
    EditableText.debugDeterministicCursor = false;
  });

  _pair('nameplate', () => const NameplateScene());
  _pair('section', () => const SectionScene());
  _pair('glass_tile', () => const GlassTileScene());
  _pair('glass_panel', () => const GlassPanelScene());
  _pair('metric_card', () => const MetricCardScene());
  _pair('stage_row', () => const StageRowScene());
  _pair('soft_label', () => const SoftLabelScene());
  _pair('glass_action', () => const GlassActionScene());
  _pair('page_head', () => const PageHeadScene());
  _pair('ow_accent', () => const OwAccentScene());
  _pair('one_mark', () => const OneMarkScene());
  _pair('choice_toggle', () => const ChoiceToggleScene());
  _pair('obscurable_field', () => const ObscurableFieldScene(), afterSettle: _revealSecond);
  _pair('feature_failure_notice', () => const FeatureFailureNoticeScene());
  _pair('glass_dialog', () => const GlassDialogScene());
  _pair('dot_matrix_face', () => const DotMatrixFaceScene());
  _pair('status_hero_ready', () => statusHeroScene(OneChannelState.ready));
  _pair('status_hero_busy', () => statusHeroScene(OneChannelState.activating));
  _pair('status_hero_alert', () => statusHeroScene(OneChannelState.inactive));
  _pair('status_hero_ready_280', () => statusHeroScene(OneChannelState.ready));
  _pair('status_hero_busy_280', () => statusHeroScene(OneChannelState.activating));
  _pair('status_hero_alert_280', () => statusHeroScene(OneChannelState.inactive));
}

void _pair(
  String name,
  Widget Function() build, {
  Future<void> Function(WidgetTester tester)? afterSettle,
}) {
  for (final width in _widths) {
    goldenScene(
      '${name}_w$width',
      build,
      size: Size(width.toDouble(), 844),
      afterSettle: afterSettle,
    );
  }
}

Future<void> _revealSecond(WidgetTester tester) async {
  await tester.tap(find.byType(IconButton).at(1));
  await tester.pump();
}
