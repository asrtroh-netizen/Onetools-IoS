import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onewifi_android/design/one/glass.dart';
import 'package:onewifi_android/design/one/ultra_glass_dock.dart';

import 'scene.dart';

/// `_slideDuration` in ultra_glass_dock.dart. The checker re-reads that line.
const Duration dockSlideDuration = Duration(milliseconds: 480);

const int dockTabCount = 4;

const List<NavigationDestination> dockDestinations = <NavigationDestination>[
  NavigationDestination(
    icon: Icon(Icons.dashboard_outlined),
    selectedIcon: Icon(Icons.dashboard, key: ValueKey<String>('dock-on-0')),
    label: 'Home',
    tooltip: '',
  ),
  NavigationDestination(
    icon: Icon(Icons.router_outlined),
    selectedIcon: Icon(Icons.router),
    label: 'Device',
    tooltip: '',
  ),
  NavigationDestination(
    icon: Icon(Icons.sms_outlined),
    selectedIcon: Icon(Icons.sms),
    label: 'Mail',
    tooltip: '',
  ),
  NavigationDestination(
    icon: Icon(Icons.public_outlined),
    selectedIcon: Icon(Icons.public),
    label: 'Proxy',
    tooltip: '',
  ),
];

class DockScene extends StatefulWidget {
  const DockScene({super.key, required this.selected});

  final int selected;

  @override
  State<DockScene> createState() => DockSceneState();
}

class DockSceneState extends State<DockScene> {
  late int index = widget.selected;

  void go(int next) => setState(() => index = next);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: GlassDock(
          selectedIndex: index,
          onDestinationSelected: go,
          destinations: dockDestinations,
        ),
      ),
    );
  }
}

void dockGolden(
  String name, {
  required int selected,
  int? slideTo,
  double slideT = 1,
  bool pressed = false,
  Size size = const Size(390, 844),
}) {
  goldenScene(
    name,
    () => DockScene(selected: selected),
    size: size,
    afterSettle: (tester) async {
      final state = tester.state<DockSceneState>(find.byType(DockScene));
      final to = slideTo ?? selected;
      if (slideTo != null) {
        state.go(slideTo);
        await tester.pump();
        final ms = (dockSlideDuration.inMilliseconds * slideT).round();
        if (ms > 0) {
          await tester.pump(Duration(milliseconds: ms));
        }
      }
      if (pressed) {
        final gesture = await tester.startGesture(
          tester.getCenter(find.byKey(const ValueKey<String>('dock-on-0'))),
        );
        addTearDown(() async {
          await gesture.up();
        });
        // Tap wins at kPressTimeout and the splash is born on that frame.
        // The next pump is the unconfirmed ripple age. pumpAndSettle would
        // run it out to _kUnconfirmedRippleDuration.
        await tester.pump(kPressTimeout);
        await tester.pump(const Duration(milliseconds: 200));
      }
      _expectIndicator(tester, from: selected, to: to, t: slideTo == null ? 1 : slideT);
      _record(tester, name);
    },
  );
}

void _expectIndicator(
  WidgetTester tester, {
  required int from,
  required int to,
  required double t,
}) {
  final dock = tester.getRect(find.byType(GlassDock));
  final indicator = tester.getRect(find.byKey(kGlassDockIndicatorKey));
  final inset = MediaQuery.viewPaddingOf(tester.element(find.byType(GlassDock))).bottom;
  expect(dock.height, Glass.dockHeight + Glass.dockBottomGap + inset);
  final inner = dock.width - Glass.pageMargin * 2;
  final edges = glassDockTabEdges(
    from: from.toDouble(),
    to: to.toDouble(),
    t: t,
    count: dockTabCount,
  );
  final tabW = (inner - Glass.dockTabInset * 2) / dockTabCount;
  final left = dock.left + Glass.pageMargin + Glass.dockTabInset + edges.left * tabW;
  final width = (edges.right - edges.left) * tabW;
  expect(indicator.left, closeTo(left, 0.05));
  expect(indicator.width, closeTo(width, 0.05));
  expect(indicator.height, closeTo(Glass.dockIndicatorHeight, 0.05));
}

void _record(WidgetTester tester, String name) {
  final dockFinder = find.byType(GlassDock);
  final brightness = Theme.of(tester.element(dockFinder)).brightness.name;
  final dock = tester.getRect(dockFinder);
  final indicator = tester.getRect(find.byKey(kGlassDockIndicatorKey));
  final dir = Directory('${Directory.systemTemp.path}${Platform.pathSeparator}onetools-a9-dock');
  dir.createSync(recursive: true);
  final payload = <String, Object>{
    'name': name,
    'brightness': brightness,
    'dock': _rectMap(dock),
    'indicator': _rectMap(indicator),
    'constants': <String, double>{
      'height': Glass.dockHeight,
      'radius': Glass.radiusDock,
      'bottomGap': Glass.dockBottomGap,
      'blur': Glass.blurDock,
      'tabInset': Glass.dockTabInset,
      'indicatorHeight': Glass.dockIndicatorHeight,
      'slideMs': dockSlideDuration.inMilliseconds.toDouble(),
    },
  };
  File('${dir.path}${Platform.pathSeparator}$name.$brightness.json').writeAsStringSync(
    jsonEncode(payload),
  );
}

Map<String, double> _rectMap(Rect rect) => <String, double>{
  'left': rect.left,
  'top': rect.top,
  'width': rect.width,
  'height': rect.height,
};
