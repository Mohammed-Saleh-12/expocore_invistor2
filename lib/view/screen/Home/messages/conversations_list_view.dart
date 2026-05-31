import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/messages_controller.dart';
import '../../../../controller/Home/visitor_messages_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/constant/routes.dart';
import '../../../widget/Home/bottom_nav_custom.dart';

class ConversationsListView extends StatelessWidget {
  const ConversationsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        appBar: _MessagesAppBar(isDark: isDark),
        bottomNavigationBar: const BottomNavCustom(),
        body: TabBarView(
          children: [
            _ExhibitionConversationsTab(isDark: isDark),
            _VisitorConversationsTab(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────── Custom AppBar with TabBar ─────────────────────────

class _MessagesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDark;
  const _MessagesAppBar({required this.isDark});

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        'messages_title'.tr,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      bottom: TabBar(
        indicatorColor: AppColors.darkPrimary,
        indicatorWeight: 3,
        labelColor: AppColors.darkPrimary,
        unselectedLabelColor: AppColors.grey,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'أقسام المعرض'),
          Tab(text: 'الزوار'),
        ],
      ),
    );
  }
}

// ──────────────────────── Tab 1: Exhibition Departments ─────────────────────

class _ExhibitionConversationsTab extends GetView<MessagesController> {
  final bool isDark;
  const _ExhibitionConversationsTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.conversations.isEmpty) {
        return _EmptyState(
          icon: Icons.business_outlined,
          label: 'messages_no_conversations'.tr,
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
            name: conv.exhibitionName,
            initials: conv.exhibitionInitials,
            lastMessage: conv.lastMessage,
            lastTime: conv.lastTime,
            unreadCount: conv.unreadCount,
            color: Color(conv.color),
            isDark: isDark,
            onTap: () {
              controller.openConversation(conv.id);
              Get.toNamed(AppRoutes.CONVERSATION);
            },
          );
        },
      );
    });
  }
}

// ──────────────────────── Tab 2: Visitors ───────────────────────────────────

class _VisitorConversationsTab extends GetView<VisitorMessagesController> {
  final bool isDark;
  const _VisitorConversationsTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.visitorConversations.isEmpty) {
        return const _EmptyState(
          icon: Icons.people_outline_rounded,
          label: 'لا توجد محادثات مع الزوار',
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: controller.visitorConversations.length,
        separatorBuilder: (_, __) => Divider(
          indent: 80,
          endIndent: 16,
          height: 1,
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
        ),
        itemBuilder: (_, i) {
          final conv = controller.visitorConversations[i];
          return _ConversationTile(
            name: conv.visitorName,
            initials: conv.visitorInitials,
            lastMessage: conv.lastMessage,
            lastTime: conv.lastTime,
            unreadCount: conv.unreadCount,
            color: Color(conv.color),
            isDark: isDark,
            onTap: () {
              controller.openConversation(conv.id);
              Get.toNamed(AppRoutes.VISITOR_CONVERSATION);
            },
          );
        },
      );
    });
  }
}

// ──────────────────────── Shared Tile Widget ────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final String name;
  final String initials;
  final String lastMessage;
  final String lastTime;
  final int unreadCount;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.name,
    required this.initials,
    required this.lastMessage,
    required this.lastTime,
    required this.unreadCount,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = unreadCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.65)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
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
                            '$unreadCount',
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
                            name,
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
                          lastTime,
                          style: TextStyle(
                            fontSize: 11,
                            color: hasUnread ? color : AppColors.grey,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessage,
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

// ──────────────────────── Empty State ───────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EmptyState({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(label,
              style: const TextStyle(color: AppColors.grey, fontSize: 15)),
        ],
      ),
    );
  }
}
