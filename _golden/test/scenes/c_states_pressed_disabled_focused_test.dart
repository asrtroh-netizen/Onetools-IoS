import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/b_frame.dart';
import '../support/scene.dart';

const ValueKey<String> _holdKey = ValueKey<String>('hold');

void main() {
  setUp(() {
    EditableText.debugDeterministicCursor = true;
  });
  tearDown(() {
    EditableText.debugDeterministicCursor = false;
  });

  goldenScene('text_field_pressed', () => const TextFieldPressedScene(), afterSettle: _holdKeyed);
  goldenScene('text_field_disabled', () => const TextFieldDisabledScene());
  goldenScene('text_field_focused', () => const TextFieldFocusedScene());

  goldenScene('text_button_pressed', () => const TextButtonPressedScene(), afterSettle: _holdKeyed);
  goldenScene('text_button_disabled', () => const TextButtonDisabledScene());
  goldenScene('text_button_focused', () => const TextButtonFocusedScene());

  goldenScene('icon_button_pressed', () => const IconButtonPressedScene(), afterSettle: _holdKeyed);
  goldenScene('icon_button_disabled', () => const IconButtonDisabledScene());
  goldenScene('icon_button_focused', () => const IconButtonFocusedScene());

  goldenScene('filled_button_pressed', () => const FilledButtonPressedScene(), afterSettle: _holdKeyed);
  goldenScene('filled_button_disabled', () => const FilledButtonDisabledScene());
  goldenScene('filled_button_focused', () => const FilledButtonFocusedScene());

  goldenScene('outlined_button_pressed', () => const OutlinedButtonPressedScene(), afterSettle: _holdKeyed);
  goldenScene('outlined_button_disabled', () => const OutlinedButtonDisabledScene());
  goldenScene('outlined_button_focused', () => const OutlinedButtonFocusedScene());
}

Future<void> _holdKeyed(WidgetTester tester) async {
  final gesture = await tester.startGesture(tester.getCenter(find.byKey(_holdKey)));
  addTearDown(() async {
    await gesture.up();
  });
  await tester.pump(kPressTimeout);
  await tester.pump(const Duration(milliseconds: 200));
}

class TextFieldPressedScene extends StatefulWidget {
  const TextFieldPressedScene({super.key});

  @override
  State<TextFieldPressedScene> createState() => _TextFieldPressedSceneState();
}

class _TextFieldPressedSceneState extends State<TextFieldPressedScene> {
  final _text = TextEditingController(text: 'Tap 9');

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return bFrame(
      TextField(
        key: _holdKey,
        controller: _text,
        decoration: const InputDecoration(labelText: 'Hold'),
      ),
      width: 320,
    );
  }
}

class TextFieldDisabledScene extends StatelessWidget {
  const TextFieldDisabledScene({super.key});

  @override
  Widget build(BuildContext context) {
    return bFrame(
      const TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Disabled',
          hintText: 'Off',
        ),
      ),
      width: 320,
    );
  }
}

class TextFieldFocusedScene extends StatefulWidget {
  const TextFieldFocusedScene({super.key});

  @override
  State<TextFieldFocusedScene> createState() => _TextFieldFocusedSceneState();
}

class _TextFieldFocusedSceneState extends State<TextFieldFocusedScene> {
  final _text = TextEditingController(text: 'Ada 12');

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return bFrame(
      TextField(
        controller: _text,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Focus'),
      ),
      width: 320,
    );
  }
}

class TextButtonPressedScene extends StatelessWidget {
  const TextButtonPressedScene({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(key: _holdKey, onPressed: () {}, child: const Text('Hold'));
  }
}

class TextButtonDisabledScene extends StatelessWidget {
  const TextButtonDisabledScene({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextButton(onPressed: null, child: Text('Disabled'));
  }
}

class TextButtonFocusedScene extends StatelessWidget {
  const TextButtonFocusedScene({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(autofocus: true, onPressed: () {}, child: const Text('Focus'));
  }
}

class IconButtonPressedScene extends StatelessWidget {
  const IconButtonPressedScene({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(key: _holdKey, onPressed: () {}, icon: const Icon(Icons.settings));
  }
}

class IconButtonDisabledScene extends StatelessWidget {
  const IconButtonDisabledScene({super.key});

  @override
  Widget build(BuildContext context) {
    return const IconButton(onPressed: null, icon: Icon(Icons.settings));
  }
}

class IconButtonFocusedScene extends StatelessWidget {
  const IconButtonFocusedScene({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(autofocus: true, onPressed: () {}, icon: const Icon(Icons.edit));
  }
}

class FilledButtonPressedScene extends StatelessWidget {
  const FilledButtonPressedScene({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(key: _holdKey, onPressed: () {}, child: const Text('Hold'));
  }
}

class FilledButtonDisabledScene extends StatelessWidget {
  const FilledButtonDisabledScene({super.key});

  @override
  Widget build(BuildContext context) {
    return const FilledButton(onPressed: null, child: Text('Disabled'));
  }
}

class FilledButtonFocusedScene extends StatelessWidget {
  const FilledButtonFocusedScene({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(autofocus: true, onPressed: () {}, child: const Text('Focus'));
  }
}

class OutlinedButtonPressedScene extends StatelessWidget {
  const OutlinedButtonPressedScene({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(key: _holdKey, onPressed: () {}, child: const Text('Hold'));
  }
}

class OutlinedButtonDisabledScene extends StatelessWidget {
  const OutlinedButtonDisabledScene({super.key});

  @override
  Widget build(BuildContext context) {
    return const OutlinedButton(onPressed: null, child: Text('Disabled'));
  }
}

class OutlinedButtonFocusedScene extends StatelessWidget {
  const OutlinedButtonFocusedScene({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(autofocus: true, onPressed: () {}, child: const Text('Focus'));
  }
}
