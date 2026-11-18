import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onewifi_android/design/one/glass.dart';
import 'package:onewifi_android/design/one/one_palette.dart';
import 'package:onewifi_android/design/one/ultra_glass_dock.dart';
import 'package:onewifi_android/design/theme/one_theme.dart';
import 'package:onewifi_android/design/tokens/one_tokens.dart';

import '../scenes/a1_typography_test.dart';

void main() {
  testWidgets('export tokens and typography', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      final light = await _readTheme(tester, dark: false);
      final dark = await _readTheme(tester, dark: true);
      expect(light.scheme, oneBlackWhiteLight);
      expect(dark.scheme, oneBlackWhiteDark);
      _write('fixtures/tokens.json', _tokens(light.scheme, dark.scheme));
      _write('fixtures/typography.json', _typography(light.text, dark.text));
      _write('fixtures/dock_edges.json', _dockEdges());
      _write(
        'fixtures/ripple.json',
        _ripple(lightSplash: light.splashAlpha, darkSplash: dark.splashAlpha),
      );
      _write('fixtures/icons.json', _icons());
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

Future<({ColorScheme scheme, TextTheme text, int splashAlpha})> _readTheme(
  WidgetTester tester, {
  required bool dark,
}) async {
  late ColorScheme scheme;
  late TextTheme text;
  late int splashAlpha;
  await tester.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: OneTheme.light(),
    darkTheme: OneTheme.dark(),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    // AnimatedTheme would otherwise keep the previous brightness for a frame.
    themeAnimationDuration: Duration.zero,
    home: Builder(builder: (context) {
      final theme = Theme.of(context);
      scheme = theme.colorScheme;
      text = theme.textTheme;
      splashAlpha = (theme.splashColor.a * 255.0).round();
      return const SizedBox.shrink();
    }),
  ));
  await tester.pump();
  return (scheme: scheme, text: text, splashAlpha: splashAlpha);
}

Map<String, Object?> _tokens(ColorScheme light, ColorScheme dark) {
  return {
    'schemes': {
      'oneBlackWhiteLight': _scheme(light),
      'oneBlackWhiteDark': _scheme(dark),
    },
    'glass': _glass(),
    'resolved': {
      'light': _resolved(light, false),
      'dark': _resolved(dark, true),
    },
  };
}

Map<String, Object?> _scheme(ColorScheme scheme) {
  final colors = <String, Color>{
    'primary': scheme.primary,
    'onPrimary': scheme.onPrimary,
    'primaryContainer': scheme.primaryContainer,
    'onPrimaryContainer': scheme.onPrimaryContainer,
    'primaryFixed': scheme.primaryFixed,
    'primaryFixedDim': scheme.primaryFixedDim,
    'onPrimaryFixed': scheme.onPrimaryFixed,
    'onPrimaryFixedVariant': scheme.onPrimaryFixedVariant,
    'secondary': scheme.secondary,
    'onSecondary': scheme.onSecondary,
    'secondaryContainer': scheme.secondaryContainer,
    'onSecondaryContainer': scheme.onSecondaryContainer,
    'secondaryFixed': scheme.secondaryFixed,
    'secondaryFixedDim': scheme.secondaryFixedDim,
    'onSecondaryFixed': scheme.onSecondaryFixed,
    'onSecondaryFixedVariant': scheme.onSecondaryFixedVariant,
    'tertiary': scheme.tertiary,
    'onTertiary': scheme.onTertiary,
    'tertiaryContainer': scheme.tertiaryContainer,
    'onTertiaryContainer': scheme.onTertiaryContainer,
    'tertiaryFixed': scheme.tertiaryFixed,
    'tertiaryFixedDim': scheme.tertiaryFixedDim,
    'onTertiaryFixed': scheme.onTertiaryFixed,
    'onTertiaryFixedVariant': scheme.onTertiaryFixedVariant,
    'error': scheme.error,
    'onError': scheme.onError,
    'errorContainer': scheme.errorContainer,
    'onErrorContainer': scheme.onErrorContainer,
    'surface': scheme.surface,
    'onSurface': scheme.onSurface,
    'surfaceVariant': scheme.surfaceVariant,
    'surfaceDim': scheme.surfaceDim,
    'surfaceBright': scheme.surfaceBright,
    'surfaceContainerLowest': scheme.surfaceContainerLowest,
    'surfaceContainerLow': scheme.surfaceContainerLow,
    'surfaceContainer': scheme.surfaceContainer,
    'surfaceContainerHigh': scheme.surfaceContainerHigh,
    'surfaceContainerHighest': scheme.surfaceContainerHighest,
    'onSurfaceVariant': scheme.onSurfaceVariant,
    'outline': scheme.outline,
    'outlineVariant': scheme.outlineVariant,
    'shadow': scheme.shadow,
    'scrim': scheme.scrim,
    'inverseSurface': scheme.inverseSurface,
    'onInverseSurface': scheme.onInverseSurface,
    'inversePrimary': scheme.inversePrimary,
    'surfaceTint': scheme.surfaceTint,
    'background': scheme.background,
    'onBackground': scheme.onBackground,
  };
  return {
    'brightness': scheme.brightness.name,
    for (final entry in colors.entries) entry.key: _argb(entry.value),
  };
}

Map<String, double> _glass() {
  return {
    'radiusCard': Glass.radiusCard,
    'radiusTile': Glass.radiusTile,
    'radiusChip': Glass.radiusChip,
    'radiusHero': Glass.radiusHero,
    'dockHeight': Glass.dockHeight,
    'radiusDock': Glass.radiusDock,
    'dockBottomGap': Glass.dockBottomGap,
    'blurDock': Glass.blurDock,
    'dockTabInset': Glass.dockTabInset,
    'dockIndicatorHeight': Glass.dockIndicatorHeight,
    'space2': Glass.space2,
    'space4': Glass.space4,
    'space6': Glass.space6,
    'space8': Glass.space8,
    'space12': Glass.space12,
    'space16': Glass.space16,
    'space20': Glass.space20,
    'space24': Glass.space24,
    'pageMargin': Glass.pageMargin,
    'cardGap': Glass.cardGap,
    'padCard': Glass.padCard,
    'blurPanel': Glass.blurPanel,
    'blurBar': Glass.blurBar,
    'blurLiquid': Glass.blurLiquid,
    'liquidRefraction': Glass.liquidRefraction,
    'strokeWidth': Glass.strokeWidth,
    'barAlpha': Glass.barAlpha,
    'modalAlpha': Glass.modalAlpha,
    'dialogAlpha': Glass.dialogAlpha,
  };
}

Map<String, Object?> _resolved(ColorScheme scheme, bool dark) {
  final backdrop = Glass.backdrop(scheme, dark);
  return {
    'fill': _paint(Glass.fill(scheme, dark)),
    'fillStrong': _paint(Glass.fillStrong(scheme, dark)),
    'barFill': _paint(Glass.barFill(scheme, dark)),
    'modalFill': _paint(Glass.modalFill(scheme, dark)),
    'dialogFill': _paint(Glass.dialogFill(scheme, dark)),
    'stroke': _paint(Glass.stroke(scheme, dark)),
    'shadow': {
      'normal': [for (final shadow in Glass.shadow(dark)) _shadow(shadow)],
      'strong': [
        for (final shadow in Glass.shadow(dark, strong: true)) _shadow(shadow),
      ],
    },
    'backdrop': {
      'begin': _alignment(backdrop.begin),
      'end': _alignment(backdrop.end),
      'top': _paint(backdrop.colors.first),
      'bottom': _paint(backdrop.colors.last),
    },
    'accent': _paint(Glass.accent(scheme)),
  };
}

Map<String, Object?> _typography(TextTheme light, TextTheme dark) {
  return {
    'sample': A1Typography.sample,
    'light': _textTheme(light),
    'dark': _textTheme(dark),
  };
}

Map<String, Object?> _textTheme(TextTheme theme) {
  final styles = <String, TextStyle>{
    'displayLarge': theme.displayLarge!,
    'displayMedium': theme.displayMedium!,
    'displaySmall': theme.displaySmall!,
    'headlineLarge': theme.headlineLarge!,
    'headlineMedium': theme.headlineMedium!,
    'headlineSmall': theme.headlineSmall!,
    'titleLarge': theme.titleLarge!,
    'titleMedium': theme.titleMedium!,
    'titleSmall': theme.titleSmall!,
    'bodyLarge': theme.bodyLarge!,
    'bodyMedium': theme.bodyMedium!,
    'bodySmall': theme.bodySmall!,
    'labelLarge': theme.labelLarge!,
    'labelMedium': theme.labelMedium!,
    'labelSmall': theme.labelSmall!,
  };
  return {
    for (final entry in styles.entries) entry.key: _style(entry.value),
  };
}

Map<String, Object?> _style(TextStyle style) {
  return {
    'fontSize': style.fontSize,
    'fontWeight': style.fontWeight?.value,
    'height': style.height,
    'letterSpacing': style.letterSpacing,
    'measuredHeight': _measure(style),
    'fontFamily': style.fontFamily,
  };
}

double _measure(TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: A1Typography.sample, style: style),
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.noScaling,
    maxLines: 1,
  )..layout();
  final height = painter.height;
  painter.dispose();
  return height;
}

Map<String, Object> _shadow(BoxShadow shadow) {
  return {
    'argb': _argb(shadow.color),
    'alpha': _alpha(shadow.color),
    'blurRadius': shadow.blurRadius,
    'offsetX': shadow.offset.dx,
    'offsetY': shadow.offset.dy,
    'spreadRadius': shadow.spreadRadius,
  };
}

Map<String, String> _paint(Color color) {
  return {'argb': _argb(color), 'alpha': _alpha(color)};
}

String _argb(Color color) {
  return color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
}

String _alpha(Color color) => color.a.toStringAsFixed(4);

String _alignment(AlignmentGeometry alignment) {
  if (alignment == Alignment.topCenter) return 'topCenter';
  if (alignment == Alignment.bottomCenter) return 'bottomCenter';
  if (alignment is Alignment) return '${alignment.x},${alignment.y}';
  return alignment.toString();
}

void _write(String path, Object value) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');
  file.writeAsStringSync('${encoder.convert(value)}\n');
}

Map<String, Object> _dockEdges() {
  const transitions = <(int, int)>[(0, 1), (0, 3), (3, 0)];
  return {
    'count': 4,
    'transitions': [
      for (final transition in transitions)
        {
          'from': transition.$1,
          'to': transition.$2,
          'samples': [
            for (var step = 0; step <= 10; step++)
              _dockSample(transition.$1, transition.$2, step / 10),
          ],
        },
    ],
  };
}

Map<String, double> _dockSample(int from, int to, double t) {
  final edges = glassDockTabEdges(
    from: from.toDouble(),
    to: to.toDouble(),
    t: t,
    count: 4,
  );
  return {'t': t, 'left': edges.left, 'right': edges.right};
}

Map<String, Object?> _ripple({required int lightSplash, required int darkSplash}) {
  final lines = File(
    '../_ref/flutter-3.44.9/material/ink_ripple.dart',
  ).readAsLinesSync();
  final themeLines = File(
    '../_ref/flutter-3.44.9/material/theme_data.dart',
  ).readAsLinesSync();
  final unconfirmed = _durationMs(lines, '_kUnconfirmedRippleDuration');
  final fadeIn = _durationMs(lines, '_kFadeInDuration');
  final radiusDuration = _durationMs(lines, '_kRadiusDuration');
  final fadeOut = _durationMs(lines, '_kFadeOutDuration');
  final cancel = _durationMs(lines, '_kCancelDuration');
  final intervalLine = _line(lines, '_kFadeOutIntervalStart =');
  final interval = _divide(lines[intervalLine - 1]);
  final radiusLine = _line(lines, '_targetRadius *');
  final factors = _radiusFactors(lines[radiusLine - 1]);
  final easeLine = _line(lines, 'Curves.ease');
  final side = OneSizes.minimumTarget;
  final box = Size(side, side);
  final target = _targetRadius(box);
  final radiusTween = Tween<double>(
    begin: target * factors.$1,
    end: target + factors.$2,
  ).chain(CurveTween(curve: Curves.ease));
  final splashLine = _line(themeLines, '0x66C8C8C8');

  List<Map<String, Object>> samples({
    required int splash,
    required List<int> times,
    required int radiusMs,
    required bool confirmed,
  }) {
    final fadeInTween = IntTween(begin: 0, end: splash);
    final fadeOutTween = IntTween(begin: splash, end: 0).chain(
      CurveTween(curve: Interval(interval, 1.0)),
    );
    return [
      for (final ms in times)
        () {
          final alpha = _rippleAlpha(
            ms: ms,
            fadeInMs: fadeIn.ms,
            fadeOutMs: fadeOut.ms,
            confirmed: confirmed,
            fadeInTween: fadeInTween,
            fadeOutTween: fadeOutTween,
          );
          return <String, Object>{
            'ms': ms,
            'radius': radiusTween.transform((ms / radiusMs).clamp(0.0, 1.0)),
            'alpha': alpha,
            'opacity': alpha / 255.0,
          };
        }(),
    ];
  }

  final holdMs = <int>[0, fadeIn.ms, 200, 500, unconfirmed.ms];
  final confirmMs = <int>[0, fadeIn.ms, radiusDuration.ms, 400, 600];
  return {
    'source': '_ref/flutter-3.44.9/material/ink_ripple.dart',
    'constants': [
      unconfirmed.entry(),
      fadeIn.entry(),
      radiusDuration.entry(),
      fadeOut.entry(),
      cancel.entry(),
      {
        'name': '_kFadeOutIntervalStart',
        'line': intervalLine,
        'value': interval,
      },
      {'name': 'radiusBeginFactor', 'line': radiusLine, 'value': factors.$1},
      {'name': 'radiusEndExtra', 'line': radiusLine, 'value': factors.$2},
      {'name': 'easeCurve', 'line': easeLine, 'value': 'Curves.ease'},
    ],
    'referenceBox': {
      'width': side,
      'height': side,
      'source': 'OneSizes.minimumTarget',
    },
    'targetRadius': target,
    'splashAlpha': {
      'light': lightSplash,
      'dark': darkSplash,
      'line': splashLine,
      'file': '_ref/flutter-3.44.9/material/theme_data.dart',
    },
    'hold': {
      'light': samples(
        splash: lightSplash,
        times: holdMs,
        radiusMs: unconfirmed.ms,
        confirmed: false,
      ),
      'dark': samples(
        splash: darkSplash,
        times: holdMs,
        radiusMs: unconfirmed.ms,
        confirmed: false,
      ),
    },
    'confirm': {
      'light': samples(
        splash: lightSplash,
        times: confirmMs,
        radiusMs: radiusDuration.ms,
        confirmed: true,
      ),
      'dark': samples(
        splash: darkSplash,
        times: confirmMs,
        radiusMs: radiusDuration.ms,
        confirmed: true,
      ),
    },
  };
}

int _rippleAlpha({
  required int ms,
  required int fadeInMs,
  required int fadeOutMs,
  required bool confirmed,
  required IntTween fadeInTween,
  required Animatable<int> fadeOutTween,
}) {
  if (ms < fadeInMs) {
    return fadeInTween.transform(ms / fadeInMs);
  }
  if (!confirmed) return fadeOutTween.transform(0);
  return fadeOutTween.transform((ms / fadeOutMs).clamp(0.0, 1.0));
}

double _targetRadius(Size size) {
  final d1 = size.bottomRight(Offset.zero).distance;
  final d2 = (size.topRight(Offset.zero) - size.bottomLeft(Offset.zero)).distance;
  return math.max(d1, d2) / 2.0;
}

({String name, int line, int ms}) _durationMs(List<String> lines, String name) {
  final line = _line(lines, '$name =');
  final text = lines[line - 1];
  final seconds = RegExp(r'Duration\(seconds: (\d+)\)').firstMatch(text);
  if (seconds != null) {
    return (name: name, line: line, ms: int.parse(seconds.group(1)!) * 1000);
  }
  final millis = RegExp(r'Duration\(milliseconds: (\d+)\)').firstMatch(text);
  if (millis == null) {
    throw StateError('$name has no Duration on line $line');
  }
  return (name: name, line: line, ms: int.parse(millis.group(1)!));
}

extension on ({String name, int line, int ms}) {
  Map<String, Object> entry() => {'name': name, 'line': line, 'ms': ms};
}

double _divide(String line) {
  final match = RegExp(r'([0-9.]+) / ([0-9.]+)').firstMatch(line);
  if (match == null) throw StateError(line);
  return double.parse(match.group(1)!) / double.parse(match.group(2)!);
}

(double, double) _radiusFactors(String line) {
  final match = RegExp(
    r'_targetRadius \* ([0-9.]+), end: _targetRadius \+ ([0-9.]+)',
  ).firstMatch(line);
  if (match == null) throw StateError(line);
  return (double.parse(match.group(1)!), double.parse(match.group(2)!));
}

int _line(List<String> lines, String needle) {
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].contains(needle)) return i + 1;
  }
  throw StateError(needle);
}

List<Map<String, Object>> _icons() {
  const catalog = <(String, IconData)>[
    ('add', Icons.add),
    ('adjust', Icons.adjust),
    ('alt_route', Icons.alt_route),
    ('alt_route_outlined', Icons.alt_route_outlined),
    ('arrow_back', Icons.arrow_back),
    ('article_outlined', Icons.article_outlined),
    ('backspace_outlined', Icons.backspace_outlined),
    ('backup_outlined', Icons.backup_outlined),
    ('badge_outlined', Icons.badge_outlined),
    ('business', Icons.business),
    ('calendar_today', Icons.calendar_today),
    ('call', Icons.call),
    ('call_end', Icons.call_end),
    ('call_made_rounded', Icons.call_made_rounded),
    ('call_outlined', Icons.call_outlined),
    ('call_received_rounded', Icons.call_received_rounded),
    ('call_rounded', Icons.call_rounded),
    ('cancel_outlined', Icons.cancel_outlined),
    ('cell_tower_outlined', Icons.cell_tower_outlined),
    ('check_circle', Icons.check_circle),
    ('check_circle_outline', Icons.check_circle_outline),
    ('check_circle_rounded', Icons.check_circle_rounded),
    ('chevron_right', Icons.chevron_right),
    ('circle', Icons.circle),
    ('close', Icons.close),
    ('content_paste_go', Icons.content_paste_go),
    ('copy', Icons.copy),
    ('dashboard', Icons.dashboard),
    ('dashboard_outlined', Icons.dashboard_outlined),
    ('data_usage', Icons.data_usage),
    ('delete', Icons.delete),
    ('delete_outline', Icons.delete_outline),
    ('devices_other_outlined', Icons.devices_other_outlined),
    ('dialpad_outlined', Icons.dialpad_outlined),
    ('dialpad_rounded', Icons.dialpad_rounded),
    ('dns', Icons.dns),
    ('download', Icons.download),
    ('download_outlined', Icons.download_outlined),
    ('edit_location_alt_outlined', Icons.edit_location_alt_outlined),
    ('edit_outlined', Icons.edit_outlined),
    ('emergency_outlined', Icons.emergency_outlined),
    ('error', Icons.error),
    ('error_outline', Icons.error_outline),
    ('event', Icons.event),
    ('event_available', Icons.event_available),
    ('extension_outlined', Icons.extension_outlined),
    ('eye', CupertinoIcons.eye),
    ('eye_slash', CupertinoIcons.eye_slash),
    ('favorite_border', Icons.favorite_border),
    ('file_copy', Icons.file_copy),
    ('filter_alt_outlined', Icons.filter_alt_outlined),
    ('fingerprint', Icons.fingerprint),
    ('forum_outlined', Icons.forum_outlined),
    ('forward_to_inbox_outlined', Icons.forward_to_inbox_outlined),
    ('history', Icons.history),
    ('history_rounded', Icons.history_rounded),
    ('hub_outlined', Icons.hub_outlined),
    ('insights_outlined', Icons.insights_outlined),
    ('ios_share_outlined', Icons.ios_share_outlined),
    ('ios_share_rounded', Icons.ios_share_rounded),
    ('key', Icons.key),
    ('key_outlined', Icons.key_outlined),
    ('link', Icons.link),
    ('link_off_outlined', Icons.link_off_outlined),
    ('link_outlined', Icons.link_outlined),
    ('lock_outlined', Icons.lock_outlined),
    ('logout', Icons.logout),
    ('memory', Icons.memory),
    ('memory_outlined', Icons.memory_outlined),
    ('mic_none_rounded', Icons.mic_none_rounded),
    ('more_horiz', Icons.more_horiz),
    ('notifications_active_outlined', Icons.notifications_active_outlined),
    ('notifications_none', Icons.notifications_none),
    ('notifications_outlined', Icons.notifications_outlined),
    ('password', Icons.password),
    ('phone_forwarded', Icons.phone_forwarded),
    ('phone_iphone_rounded', Icons.phone_iphone_rounded),
    ('pin_outlined', Icons.pin_outlined),
    ('play_arrow', Icons.play_arrow),
    ('power_settings_new', Icons.power_settings_new),
    ('public', Icons.public),
    ('public_outlined', Icons.public_outlined),
    ('receipt_long_outlined', Icons.receipt_long_outlined),
    ('refresh', Icons.refresh),
    ('refresh_rounded', Icons.refresh_rounded),
    ('replay', Icons.replay),
    ('ring_volume_outlined', Icons.ring_volume_outlined),
    ('router', Icons.router),
    ('router_outlined', Icons.router_outlined),
    ('save_outlined', Icons.save_outlined),
    ('schedule', Icons.schedule),
    ('science_outlined', Icons.science_outlined),
    ('security_outlined', Icons.security_outlined),
    ('send_outlined', Icons.send_outlined),
    ('settings', Icons.settings),
    ('settings_backup_restore_outlined', Icons.settings_backup_restore_outlined),
    ('settings_outlined', Icons.settings_outlined),
    ('shield', Icons.shield),
    ('shield_outlined', Icons.shield_outlined),
    ('sim_card_outlined', Icons.sim_card_outlined),
    ('smartphone_outlined', Icons.smartphone_outlined),
    ('sms', Icons.sms),
    ('sms_outlined', Icons.sms_outlined),
    ('source', Icons.source),
    ('speed', Icons.speed),
    ('stop_circle_outlined', Icons.stop_circle_outlined),
    ('storage_outlined', Icons.storage_outlined),
    ('swap_horiz', Icons.swap_horiz),
    ('sync', Icons.sync),
    ('translate', Icons.translate),
    ('tune', Icons.tune),
    ('tune_rounded', Icons.tune_rounded),
    ('update', Icons.update),
    ('upload_file_outlined', Icons.upload_file_outlined),
    ('verified_user_outlined', Icons.verified_user_outlined),
    ('visibility_off_outlined', Icons.visibility_off_outlined),
    ('visibility_outlined', Icons.visibility_outlined),
    ('warning', Icons.warning),
    ('warning_rounded', Icons.warning_rounded),
    ('wifi_off_outlined', Icons.wifi_off_outlined),
    ('wifi_tethering', Icons.wifi_tethering),
  ];
  return [
    for (final (name, icon) in catalog)
      {
        'name': name,
        'codePoint': icon.codePoint,
        'family': icon.fontFamily!,
      },
  ];
}
