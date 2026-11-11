import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // 路径相对于 _golden/。两个字体在 T1.1 里复制进来，这个包不依赖别的目录怎么摆。
  await _load('Montserrat', 'fonts/Montserrat-Regular.ttf');
  await _load('MaterialIcons', 'fonts/MaterialIcons-Regular.otf');
  await testMain();
}

Future<void> _load(String family, String path) async {
  final bytes = await File(path).readAsBytes();
  final loader = FontLoader(family)..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}
