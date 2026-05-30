import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/messages_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/constant/routes.dart';
import '../../../widget/Home/bottom_nav_custom.dart';
import '../../../widget/Home/custom_app_bar.dart';

class ConversationsListView extends GetView<MessagesController> {
  const ConversationsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: CustomAppBar(title: 'messages_title'.tr),
      bottomNavigationBar: const BottomNavCustom(),
      body: Obx(() {
        if (controller.conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.forum_outlined, size: 64,
                    color: AppColors.grey.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text('messages_no_conversations'.tr,
                    style: const TextStyle(color: AppColors.grey, fontSize: 15)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.conversations.length,
          separatorBuilder: (_, __) => Divider(
            indent: 80,
            endIndent: 16,
            height: 1,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
          ),
          itemBuilder: (_, i) {
            final conv = controller.conversations[i];
            return _ConversationTile(
              conv: conv,
              isDark: isDark,
              onTap: () {
                controller.openConversation(conv.id);
                Get.toNamed(AppRoutes.CONVERSATION);
              },
            );
          },
        );
      }),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final dynamic conv;
  final bool isDark;
  final VoidCallback onTap;
  const _ConversationTile({
    required this.conv,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(conv.color as int);
    final hasUnread   = conv.unreadCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Exhibition avatar
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor, accentColor.withOpacity(0.65)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        conv.exhibitionInitials as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  if (hasUnread)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.darkPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.darkBg : AppColors.lightBg,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${conv.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conv.exhibitionName as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          conv.lastTime as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: hasUnread
                                ? accentColor
                                : AppColors.grey,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conv.lastMessage as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: hasUnread
                            ? (isDark ? Colors.white70 : Colors.black54)
                            : AppColors.grey,
                        fontWeight: hasUnread
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grey.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}