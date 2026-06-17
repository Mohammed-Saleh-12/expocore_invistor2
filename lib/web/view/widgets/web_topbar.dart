import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/notifications_controller.dart';
import '../../../core/constant/app_globals.dart';
import '../../../core/constant/appcolors.dart';
import '../../../core/services/services.dart';
import '../../controllers/web_nav_controller.dart';

class WebTopbar extends StatelessWidget {
  const WebTopbar({super.key});

  @override
  Widget build(BuildContext context) {
    final notif = _notifCtrl();

    return Obx(() {
      appLang.value;

      String company = 'topbar_guest'.tr;
      try {
        final name = Get.find<Services>().companyName;
        if (name.isNotEmpty) company = name;
      } catch (_) {}

      return Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          color: WebTheme.topbar,
          border: const Border(bottom: BorderSide(color: Color(0x18FFFFFF))),
        ),
        child: Row(
          children: [
            const Spacer(),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: WebNavController.to.openNotifications,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _circleBtn(Icons.notifications_outlined),
                    if (notif != null)
                      Obx(() {
                        final count = notif.unreadCount;
                        if (count == 0) return const SizedBox.shrink();
                        return Positioned(
                          top: -2,
                          right: -2,
                          child: IgnorePointer(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              decoration: BoxDecoration(
                                color: WebTheme.secondary,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  color: WebTheme.onGradient,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            GestureDetector(
              onTap: () => WebNavController.to.select(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: WebTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: WebTheme.primary,
                      child: Text(
                        company.isNotEmpty ? company[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: WebTheme.onGradient,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      company,
                      style: TextStyle(
                        color: WebTheme.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  NotificationsController? _notifCtrl() {
    try {
      return Get.find<NotificationsController>();
    } catch (_) {
      return null;
    }
  }

  Widget _circleBtn(IconData icon) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: WebTheme.surfaceAlt,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: AppColors.grey, size: 20),
  );
}
