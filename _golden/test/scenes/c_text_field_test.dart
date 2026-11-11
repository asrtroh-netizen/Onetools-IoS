import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

void main() {
  setUp(() {
    EditableText.debugDeterministicCursor = true;
  });
  tearDown(() {
    EditableText.debugDeterministicCursor = false;
  });
  goldenScene('text_field', () => const TextFieldScene());
}

/// Empty, focused, and error [TextField]s under [OneTheme].
class TextFieldScene extends StatefulWidget {
  const TextFieldScene({super.key});

  @override
  State<TextFieldScene> createState() => _TextFieldSceneState();
}

class _TextFieldSceneState extends State<TextFieldScene> {
  final _focused = TextEditingController(text: 'Ada 12');

  @override
  void dispose() {
    _focused.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return bFrame(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: 'Empty',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _focused,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Focus'),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Code',
              errorText: 'Required',
            ),
          ),
        ],
      ),
      width: 320,
    );
  }
}
