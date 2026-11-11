import 'package:flutter/material.dart';
import 'package:onewifi_android/design/one/one_status_hero.dart';

/// [OneStatusHero] for one channel state. Settled hides the subtitle and actions.
Widget statusHeroScene(OneChannelState state) {
  final title = switch (state) {
    OneChannelState.ready => 'Ready',
    OneChannelState.activating => 'Link',
    OneChannelState.inactive => 'Alert',
  };
  final pill = switch (state) {
    OneChannelState.ready => 'On',
    OneChannelState.activating => 'Busy',
    OneChannelState.inactive => 'Down',
  };
  return OneStatusHero(
    state: state,
    eyebrow: 'Channel',
    title: title,
    pill: pill,
    stageLabels: const ['Off', 'Busy', 'Ready'],
    subtitle: 'Step 2 of 3',
    detail: 'Slot 12',
    actionLabel: 'Start',
    actionSub: 'About 4 s',
    onAction: () {},
    secondaryActionLabel: 'Pair',
    onSecondaryAction: () {},
    busyLabel: 'Wait',
    trailing: const Icon(Icons.chevron_right),
  );
}
