import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/notifications_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/notification/notification_model.dart';
import '../../controllers/web_nav_controller.dart';

class WebNotificationsPage extends StatelessWidget {
  const WebNotificationsPage({super.key});

  NotificationsController get _c {
    try { return Get.find<NotificationsController>(); }
    catch (_) { return Get.put(NotificationsController()); }
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: WebNavController.to.closeDetail,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: WebTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: WebTheme.border),
                        ),
                        child: Icon(Icons.arrow_forward_rounded, color: WebTheme.text, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text('رجوع', style: TextStyle(color: AppColors.grey, fontSize: 14)),
                    ]),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: c.markAllRead,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: WebTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: WebTheme.primary.withOpacity(0.3)),
                      ),
                      child: Text('تعليم الكل كمقروء',
                          style: TextStyle(color: WebTheme.pink, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(children: [
                Container(width: 5, height: 28, decoration: BoxDecoration(gradient: AppColors.favoriteGradient, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 10),
                Text('الإشعارات', style: TextStyle(color: WebTheme.text, fontSize: 24, fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 20),

              Obx(() {
                final list = c.notifications.toList();
                if (c.isLoading.value) {
                  return Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: WebTheme.primary)));
                }
                if (list.isEmpty) {
                  return Container(
                    width: double.infinity, padding: const EdgeInsets.all(50), alignment: Alignment.center,
                    decoration: BoxDecoration(color: WebTheme.surface, borderRadius: BorderRadius.circular(16)),
                    child: Column(children: [
                      Icon(Icons.notifications_off_outlined, size: 50, color: AppColors.grey.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      Text('لا توجد إشعارات', style: TextStyle(color: AppColors.grey)),
                    ]),
                  );
                }
                return Column(children: list.map((n) => _NotifCard(n: n, onTap: () => c.markRead(n.id))).toList());
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final NotificationModel n;
  final VoidCallback onTap;
  const _NotifCard({required this.n, required this.onTap});

  IconData get _icon {
    switch (n.type) {
      case 'booking_accepted': return Icons.check_circle_outline;
      case 'new_exhibition':   return Icons.storefront_outlined;
      case 'campaign_active':  return Icons.campaign_outlined;
      case 'new_message':      return Icons.chat_bubble_outline;
      case 'report_ready':     return Icons.bar_chart_rounded;
      default:                 return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: n.isRead ? WebTheme.surface : WebTheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: n.isRead ? WebTheme.border : WebTheme.primary.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: WebTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(_icon, color: WebTheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.title, style: TextStyle(color: WebTheme.text, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(n.body, style: TextStyle(color: AppColors.grey, fontSize: 13, height: 1.5)),
                  const SizedBox(height: 6),
                  Text(n.time, style: TextStyle(color: AppColors.grey.withOpacity(0.7), fontSize: 11)),
                ],
              ),
            ),
            if (!n.isRead)
              Container(
                width: 10, height: 10, margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(color: WebTheme.secondary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
