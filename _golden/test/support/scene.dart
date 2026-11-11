import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onewifi_android/design/one/glass.dart';
import 'package:onewifi_android/design/theme/one_theme.dart';

/// 每个场景出深浅两张图：goldens/<name>.light.png 和 goldens/<name>.dark.png。
///
/// [afterSettle] 在主题安静 500ms 之后、截图之前跑。水波纹要在这里按下并再 pump，
/// 否则那 500ms 会把动画推过取样点。
void goldenScene(
  String name,
  Widget Function() build, {
  Size size = const Size(390, 844),
  Future<void> Function(WidgetTester tester)? afterSettle,
}) {
  for (final brightness in Brightness.values) {
    testWidgets('$name ${brightness.name}', (tester) async {
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = size * 3.0;
      addTearDown(tester.view.reset);
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      debugDisableShadows = false;
      try {
        final dark = brightness == Brightness.dark;
        final theme = dark ? OneTheme.dark() : OneTheme.light();
        await tester.pumpWidget(MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: DecoratedBox(
            decoration: BoxDecoration(gradient: Glass.backdrop(theme.colorScheme, dark)),
            child: Scaffold(body: Center(child: build())),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 500));
        if (afterSettle != null) {
          await afterSettle(tester);
        }
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../../goldens/$name.${brightness.name}.png'),
        );
      } finally {
        debugDisableShadows = true;
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }
}
