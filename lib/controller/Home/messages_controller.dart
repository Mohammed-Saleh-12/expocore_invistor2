import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';
import '../../core/constant/routes.dart';
import '../../data/model/message/conversation_model.dart';
import '../../data/model/message/message_model.dart';
class MessagesController extends GetxController {
 final conversations        = <ConversationModel>[].obs;
  final activeConversationId = Rxn<int>();
  final inputCtrl            = TextEditingController();
  final isTyping             = false.obs;
  int _nextId                = 500;

  @override
  void onInit() {
    conversations.value = List.from(DummyData.conversations);
    super.onInit();
  }

  // ── Active conversation helpers ─────────────────────────────────────
  ConversationModel? get activeConversation {
    final id = activeConversationId.value;
    if (id == null) return null;
    return conversations.firstWhereOrNull((c) => c.id == id);
  }

  List<MessageModel> get activeMessages =>
      activeConversation?.messages ?? [];

  // ── Open a conversation by id ───────────────────────────────────────
  void openConversation(int id) {
    activeConversationId.value = id;
    final conv = conversations.firstWhereOrNull((c) => c.id == id);
    if (conv != null) {
      conv.unreadCount = 0;
      conversations.refresh();
    }
  }

  // ── Open (or create) a conversation for an exhibition by name ───────
  void openConversationForExhibitionName(String exhibitionName) {
    var conv = conversations.firstWhereOrNull(
      (c) => c.exhibitionName == exhibitionName,
    );

    if (conv == null) {
      final ex = DummyData.exhibitions.firstWhereOrNull(
        (e) => e.name == exhibitionName,
      );
      final initials = exhibitionName.length >= 2
          ? exhibitionName.substring(0, 2)
          : exhibitionName;
      conv = ConversationModel(
        id:                  conversations.length + 200,
        exhibitionId:        ex?.id ?? 0,
        exhibitionName:      exhibitionName,
        exhibitionInitials:  initials,
        color:               0xFF7A1FFF,
        messages: [
          MessageModel(
            id: _nextId++,
            text: 'مرحباً، كيف يمكننا مساعدتك؟',
            isMe: false,
            time: _now(),
            isRead: true,
          ),
        ],
        unreadCount: 0,
      );
      conversations.add(conv);
    }

    openConversation(conv.id);
    Get.toNamed(AppRoutes.CONVERSATION);
  }

  // ── Send a message to the active conversation ───────────────────────
  void sendMessage() {
    final text = inputCtrl.text.trim();
    if (text.isEmpty) return;

    final conv = activeConversation;
    if (conv == null) return;

    conv.messages.add(MessageModel(
      id: _nextId++,
      text: text,
      isMe: true,
      time: _now(),
      isRead: false,
    ));
    conversations.refresh();
    inputCtrl.clear();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (activeConversation?.id == conv.id) {
        conv.messages.add(MessageModel(
          id: _nextId++,
          text: 'شكراً لتواصلك معنا. سيرد عليك فريق الدعم قريباً.',
          isMe: false,
          time: _now(),
          isRead: true,
        ));
        conversations.refresh();
      }
    });
  }
    int get totalUnread =>
      conversations.fold(0, (sum, c) => sum + c.unreadCount);

  String _now() {
    final t = DateTime.now();
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    inputCtrl.dispose();
    super.onClose();
  }
}
