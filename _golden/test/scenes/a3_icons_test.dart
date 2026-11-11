import 'package:flutter/material.dart';

import '../support/scene.dart';

void main() {
  if (A3Icons.icons.length != 119) {
    throw StateError('a3 icon count ${A3Icons.icons.length}');
  }
  goldenScene('a3_icons', () => const A3Icons());
}

/// Material icons named in `_ref/ow_icons.txt` that exist on `Icons`.
/// `Icons.eye` and `Icons.eye_slash` are omitted: those call sites are
/// CupertinoIcons, and Material Icons has neither name.
class A3Icons extends StatelessWidget {
  const A3Icons({super.key});

  static const icons = <IconData>[
    Icons.add,
    Icons.adjust,
    Icons.alt_route,
    Icons.alt_route_outlined,
    Icons.arrow_back,
    Icons.article_outlined,
    Icons.backspace_outlined,
    Icons.backup_outlined,
    Icons.badge_outlined,
    Icons.business,
    Icons.calendar_today,
    Icons.call,
    Icons.call_end,
    Icons.call_made_rounded,
    Icons.call_outlined,
    Icons.call_received_rounded,
    Icons.call_rounded,
    Icons.cancel_outlined,
    Icons.cell_tower_outlined,
    Icons.check_circle,
    Icons.check_circle_outline,
    Icons.check_circle_rounded,
    Icons.chevron_right,
    Icons.circle,
    Icons.close,
    Icons.content_paste_go,
    Icons.copy,
    Icons.dashboard,
    Icons.dashboard_outlined,
    Icons.data_usage,
    Icons.delete,
    Icons.delete_outline,
    Icons.devices_other_outlined,
    Icons.dialpad_outlined,
    Icons.dialpad_rounded,
    Icons.dns,
    Icons.download,
    Icons.download_outlined,
    Icons.edit_location_alt_outlined,
    Icons.edit_outlined,
    Icons.emergency_outlined,
    Icons.error,
    Icons.error_outline,
    Icons.event,
    Icons.event_available,
    Icons.extension_outlined,
    Icons.favorite_border,
    Icons.file_copy,
    Icons.filter_alt_outlined,
    Icons.fingerprint,
    Icons.forum_outlined,
    Icons.forward_to_inbox_outlined,
    Icons.history,
    Icons.history_rounded,
    Icons.hub_outlined,
    Icons.insights_outlined,
    Icons.ios_share_outlined,
    Icons.ios_share_rounded,
    Icons.key,
    Icons.key_outlined,
    Icons.link,
    Icons.link_off_outlined,
    Icons.link_outlined,
    Icons.lock_outlined,
    Icons.logout,
    Icons.memory,
    Icons.memory_outlined,
    Icons.mic_none_rounded,
    Icons.more_horiz,
    Icons.notifications_active_outlined,
    Icons.notifications_none,
    Icons.notifications_outlined,
    Icons.password,
    Icons.phone_forwarded,
    Icons.phone_iphone_rounded,
    Icons.pin_outlined,
    Icons.play_arrow,
    Icons.power_settings_new,
    Icons.public,
    Icons.public_outlined,
    Icons.receipt_long_outlined,
    Icons.refresh,
    Icons.refresh_rounded,
    Icons.replay,
    Icons.ring_volume_outlined,
    Icons.router,
    Icons.router_outlined,
    Icons.save_outlined,
    Icons.schedule,
    Icons.science_outlined,
    Icons.security_outlined,
    Icons.send_outlined,
    Icons.settings,
    Icons.settings_backup_restore_outlined,
    Icons.settings_outlined,
    Icons.shield,
    Icons.shield_outlined,
    Icons.sim_card_outlined,
    Icons.smartphone_outlined,
    Icons.sms,
    Icons.sms_outlined,
    Icons.source,
    Icons.speed,
    Icons.stop_circle_outlined,
    Icons.storage_outlined,
    Icons.swap_horiz,
    Icons.sync,
    Icons.translate,
    Icons.tune,
    Icons.tune_rounded,
    Icons.update,
    Icons.upload_file_outlined,
    Icons.verified_user_outlined,
    Icons.visibility_off_outlined,
    Icons.visibility_outlined,
    Icons.warning,
    Icons.warning_rounded,
    Icons.wifi_off_outlined,
    Icons.wifi_tethering,
  ];

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    const columns = 7;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < icons.length ~/ columns; row++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var col = 0; col < columns; col++)
                _Sizes(icon: icons[row * columns + col], color: color),
            ],
          ),
      ],
    );
  }
}

class _Sizes extends StatelessWidget {
  const _Sizes({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        Icon(icon, size: 24, color: color),
      ],
    );
  }
}
