import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/messages_controller.dart';
import '../../../controller/Home/visitor_messages_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../controllers/web_nav_controller.dart';

class WebMessagesPage extends StatelessWidget {
  const WebMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = WebNavController.to;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Row(
              children: [
                _seg(nav, 'messages_admin'.tr, 0),
                const SizedBox(width: 10),
                _seg(nav, 'messages_visitors'.tr, 1),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(
              () => nav.messagesTab.value == 0
                  ? const _AdminMessages()
                  : const _VisitorMessages(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seg(WebNavController nav, String label, int index) {
    final active = nav.messagesTab.value == index;
    return GestureDetector(
      onTap: () => nav.messagesTab.value = index,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        decoration: BoxDecoration(
          gradient: active ? AppColors.favoriteGradient : null,
          color: active ? null : WebTheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.grey,
            fontSize: 14,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _AdminMessages extends StatelessWidget {
  const _AdminMessages();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MessagesController>();
    return _TwoPane(
      listBuilder: () => Obx(() {
        final list = c.conversations.toList();
        if (list.isEmpty) return const _EmptyList();
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final conv = list[i];
            return Obx(
              () => _ConvTile(
                initials: conv.exhibitionInitials,
                color: conv.color,
                name: conv.exhibitionName,
                last: conv.lastMessage,
                unread: conv.unreadCount,
                active: c.activeConversationId.value == conv.id,
                onTap: () => c.openConversation(conv.id),
              ),
            );
          },
        );
      }),
      chatBuilder: () => Obx(() {
        final id = c.activeConversationId.value;
        if (id == null) return const _NoChat();
        final conv = c.conversations.firstWhereOrNull((x) => x.id == id);
        if (conv == null) return const SizedBox.shrink();
        return _ChatBody(
          initials: conv.exhibitionInitials,
          color: conv.color,
          name: conv.exhibitionName,
          messages: conv.messages.map((m) => (m.text, m.isMe)).toList(),
          input: c.inputCtrl,
          onSend: c.sendMessage,
        );
      }),
    );
  }
}

class _VisitorMessages extends StatelessWidget {
  const _VisitorMessages();

  @override
  Widget build(BuildContext context) {
    final c = _ctrl();
    return _TwoPane(
      listBuilder: () => Obx(() {
        final list = c.visitorConversations.toList();
        if (list.isEmpty) return const _EmptyList();
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final conv = list[i];
            return Obx(
              () => _ConvTile(
                initials: conv.visitorInitials,
                color: conv.color,
                name: conv.visitorName,
                last: conv.lastMessage,
                unread: conv.unreadCount,
                active: c.activeConversationId.value == conv.id,
                onTap: () => c.openConversation(conv.id),
              ),
            );
          },
        );
      }),
      chatBuilder: () => Obx(() {
        final id = c.activeConversationId.value;
        if (id == null) return const _NoChat();
        final conv = c.visitorConversations.firstWhereOrNull((x) => x.id == id);
        if (conv == null) return const SizedBox.shrink();
        return _ChatBody(
          initials: conv.visitorInitials,
          color: conv.color,
          name: conv.visitorName,
          messages: conv.messages.map((m) => (m.text, m.isMe)).toList(),
          input: c.inputCtrl,
          onSend: c.sendMessage,
        );
      }),
    );
  }

  VisitorMessagesController _ctrl() {
    try {
      return Get.find<VisitorMessagesController>();
    } catch (_) {
      return Get.put(VisitorMessagesController());
    }
  }
}

class _TwoPane extends StatelessWidget {
  final Widget Function() listBuilder;
  final Widget Function() chatBuilder;
  const _TwoPane({required this.listBuilder, required this.chatBuilder});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 320,
          child: Container(
            decoration: BoxDecoration(
              color: WebTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: WebTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'messages_conversations'.tr,
                    style: TextStyle(
                      color: WebTheme.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Divider(color: Color(0x18FFFFFF), height: 1),
                Expanded(child: listBuilder()),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: WebTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: WebTheme.border),
            ),
            child: chatBuilder(),
          ),
        ),
      ],
    );
  }
}

// ── Conversation tile ───────────────────────────────────────
class _ConvTile extends StatelessWidget {
  final String initials, name, last;
  final int color, unread;
  final bool active;
  final VoidCallback onTap;
  const _ConvTile({
    required this.initials,
    required this.color,
    required this.name,
    required this.last,
    required this.unread,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: active ? WebTheme.primary.withOpacity(0.12) : null,
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Color(color),
              child: Text(
                initials,
                style: TextStyle(
                  color: WebTheme.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: WebTheme.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (unread > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: WebTheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$unread',
                  style: TextStyle(
                    color: WebTheme.text,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Chat body ───────────────────────────────────────────────
class _ChatBody extends StatelessWidget {
  final String initials, name;
  final int color;
  final List<(String, bool)> messages;
  final TextEditingController input;
  final VoidCallback onSend;
  const _ChatBody({
    required this.initials,
    required this.color,
    required this.name,
    required this.messages,
    required this.input,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Color(color),
                child: Text(
                  initials,
                  style: TextStyle(
                    color: WebTheme.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: TextStyle(
                  color: WebTheme.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0x18FFFFFF), height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: messages
                .map(
                  (m) => Align(
                    alignment: m.$2
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      constraints: const BoxConstraints(maxWidth: 420),
                      decoration: BoxDecoration(
                        gradient: m.$2 ? AppColors.favoriteGradient : null,
                        color: m.$2 ? null : WebTheme.surfaceAlt,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        m.$1,
                        style: TextStyle(
                          color: m.$2 ? Colors.white : WebTheme.text,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: input,
                  style: TextStyle(color: WebTheme.text),
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: 'messages_type_hint'.tr,
                    hintStyle: TextStyle(
                      color: AppColors.grey.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: WebTheme.surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onSend,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.favoriteGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList();
  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      'messages_no_conversations'.tr,
      style: TextStyle(color: AppColors.grey),
    ),
  );
}

class _NoChat extends StatelessWidget {
  const _NoChat();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.chat_bubble_outline_rounded,
          size: 56,
          color: AppColors.grey.withOpacity(0.5),
        ),
        const SizedBox(height: 12),
        Text(
          'messages_select_chat'.tr,
          style: TextStyle(color: AppColors.grey),
        ),
      ],
    ),
  );
}
