import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/messages_controller.dart';
import '../../../../core/constant/appcolors.dart';

class MessagesView extends GetView<MessagesController> {
  const MessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final conv = controller.activeConversation;
      if (conv == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final accentColor = Color(conv.color);
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        appBar: _buildAppBar(conv, accentColor),
        body: Column(
          children: [
            Expanded(
              child: Obx(
                () => ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: controller.activeMessages.length,
                  itemBuilder: (_, i) {
                    final m = controller.activeMessages[i];
                    return _Bubble(
                      isMe: m.isMe,
                      text: m.text,
                      time: m.time,
                      isRead: m.isRead,
                      accentColor: accentColor,
                    );
                  },
                ),
              ),
            ),
            _InputBar(isDark: isDark),
          ],
        ),
      );
    });
  }

  AppBar _buildAppBar(dynamic conv, Color accentColor) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withOpacity(0.65)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                conv.exhibitionInitials as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conv.exhibitionName as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'messages_online'.tr,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (val) {
            final exhibitionName = conv.exhibitionName as String;
            final Map<String, String> quickMessages = {
              'booking': 'استفسار عن حجز الجناح في $exhibitionName',
              'services': 'ما هي الخدمات المتاحة في المعرض؟',
              'events': 'هل هناك فعاليات قادمة في $exhibitionName؟',
              'reports': 'أحتاج تقريراً عن أداء جناحي',
            };
            controller.inputCtrl.text = quickMessages[val] ?? '';
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'booking',
              child: Text('messages_quick_booking'.tr),
            ),
            PopupMenuItem(
              value: 'services',
              child: Text('messages_quick_services'.tr),
            ),
            PopupMenuItem(
              value: 'events',
              child: Text('messages_quick_events'.tr),
            ),
            PopupMenuItem(
              value: 'reports',
              child: Text('messages_quick_reports'.tr),
            ),
          ],
        ),
      ],
    );
  }
}

// ──────────────────────── Input Bar ────────────────────────────

class _InputBar extends GetView<MessagesController> {
  final bool isDark;
  const _InputBar({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.only(
      left: 12,
      right: 12,
      top: 8,
      bottom: MediaQuery.of(context).viewInsets.bottom + 12,
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.inputCtrl,
            decoration: InputDecoration(
              hintText: 'messages_type_hint'.tr,
              hintStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
              filled: true,
              fillColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: controller.sendMessage,
          child: Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF1592), Color(0xFF7A1FFF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    ),
  );
}

// ──────────────────────── Message Bubble ───────────────────────

class _Bubble extends StatelessWidget {
  final bool isMe;
  final String text;
  final String time;
  final bool isRead;
  final Color accentColor;

  const _Bubble({
    required this.isMe,
    required this.text,
    required this.time,
    required this.isRead,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(
                  colors: [Color(0xFFFF1592), Color(0xFF7A1FFF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isMe
              ? null
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.only(
            topRight: const Radius.circular(16),
            topLeft: const Radius.circular(16),
            bottomRight: Radius.circular(isMe ? 4 : 16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isMe ? Colors.white : null,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : AppColors.grey,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 12,
                    color: Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
