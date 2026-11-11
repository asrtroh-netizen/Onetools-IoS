import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onewifi_android/design/widgets/obscurable_field.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

void main() {
  setUp(() {
    EditableText.debugDeterministicCursor = true;
  });
  tearDown(() {
    EditableText.debugDeterministicCursor = false;
  });
  goldenScene(
    'obscurable_field',
    () => const ObscurableFieldScene(),
    afterSettle: (tester) async {
      await tester.tap(find.byType(IconButton).at(1));
      await tester.pump();
    },
  );
}

/// Hidden, revealed, and empty [ObscurableField].
class ObscurableFieldScene extends StatefulWidget {
  const ObscurableFieldScene({super.key});

  @override
  State<ObscurableFieldScene> createState() => _ObscurableFieldSceneState();
}

class _ObscurableFieldSceneState extends State<ObscurableFieldScene> {
  final _hidden = TextEditingController(text: 'Secret12');
  final _shown = TextEditingController(text: 'Open1234');
  final _empty = TextEditingController();

  @override
  void dispose() {
    _hidden.dispose();
    _shown.dispose();
    _empty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return bFrame(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ObscurableField(
            controller: _hidden,
            labelText: 'Password',
            hintText: 'Hidden',
          ),
          const SizedBox(height: 20),
          ObscurableField(
            controller: _shown,
            labelText: 'Token',
            hintText: 'Shown',
          ),
          const SizedBox(height: 20),
          ObscurableField(
            controller: _empty,
            labelText: 'Key',
            hintText: 'Optional',
          ),
        ],
      ),
      width: 320,
    );
  }
}
