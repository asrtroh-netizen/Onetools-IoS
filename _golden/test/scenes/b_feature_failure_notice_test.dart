import 'package:flutter/widgets.dart';
import 'package:onewifi_android/core/state/state_failure.dart';
import 'package:onewifi_android/design/widgets/feature_failure_notice.dart';

import '../support/scene.dart';

void main() {
  goldenScene(
    'feature_failure_notice',
    () => const FeatureFailureNoticeScene(),
  );
}

/// Unavailable tile and the error line from [FeatureFailureNotice].
class FeatureFailureNoticeScene extends StatelessWidget {
  const FeatureFailureNoticeScene({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 140,
            child: FeatureFailureNotice(
              failure: null,
              feature: 'SMS',
              hint: 'Mode required',
            ),
          ),
          SizedBox(height: 24),
          FeatureFailureNotice(
            failure: StateFailure(StateFailureKind.timeout),
            feature: 'SMS',
            hint: 'Mode required',
          ),
        ],
      ),
    );
  }
}
