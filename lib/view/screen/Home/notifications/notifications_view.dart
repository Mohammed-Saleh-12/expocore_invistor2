import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/notifications_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../widget/Home/custom_app_bar.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  IconData _icon(String type) {
    switch (type) {
      case 'booking_accepted': return Icons.check_circle_outline;
      case 'new_exhibition':   return Icons.store_outlined;
      case 'campaign_active':  return Icons.campaign_outlined;
      case 'new_message':      return Icons.message_outlined;
      case 'report_ready':     return Icons.bar_chart_outlined;
      case 'event_reminder':   return Icons.notifications_active_outlined;
      case 'favorite_update':  return Icons.favorite_border;
      default: return Icons.notifications_outlined;
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'booking_accepted': return AppColors.success;
      case 'new_exhibition':   return AppColors.info;
      case 'campaign_active':  return AppColors.orange;
      case 'new_message':      return AppColors.darkSecondary;
      case 'report_ready':     return AppColors.darkPrimary;
      case 'event_reminder':   return AppColors.darkAccent;
      case 'favorite_update':  return AppColors.darkSecondary;
      default: return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(title: 'الإشعارات', actions: [
        TextButton(
          onPressed: controller.markAllRead,
          child: const Text('قراءة الكل', style: TextStyle(color: AppColors.darkPrimary, fontSize: 12)),
        ),
      ]),
      body: Obx(() => ListView.separated(
        itemCount: controller.notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final n = controller.notifications[i];
          return GestureDetector(
            onTap: () {
              controller.markRead(n.id);
              if (n.route != null) Get.toNamed(n.route!);
            },
            child: Container(
              color: n.isRead ? Colors.transparent : AppColors.darkPrimary.withOpacity(0.05),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(color: _iconColor(n.type).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(_icon(n.type), color: _iconColor(n.type), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(n.title, style: TextStyle(fontSize: 14, fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700))),
                    if (!n.isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.darkSecondary, shape: BoxShape.circle)),
                  ]),
                  const SizedBox(height: 3),
                  Text(n.body, style: const TextStyle(fontSize: 12, color: AppColors.grey, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(n.time, style: const TextStyle(fontSize: 10, color: AppColors.grey)),
                ])),
              ]),
            ),
          );
        },
      )),
    );
  }
}
