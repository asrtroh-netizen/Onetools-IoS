import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lets iOS [UiKitView] build in a widget test. The view stays blank.
void installEmptyPlatformViews() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform_views, (
        MethodCall call,
      ) async {
        return null;
      });
}
