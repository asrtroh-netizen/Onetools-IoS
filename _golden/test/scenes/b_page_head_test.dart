import 'package:flutter/widgets.dart';
import 'package:onewifi_android/design/widgets/page_head.dart';

import '../support/scene.dart';

void main() {
  goldenScene('page_head', () => const PageHeadScene());
}

/// [OwPageHead] with a description and a trailing action.
class PageHeadScene extends StatelessWidget {
  const PageHeadScene({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 320,
      height: 180,
      child: OwPageHead(
        title: 'Devices',
        desc: '12 online',
        actions: Text('Edit'),
      ),
    );
  }
}
