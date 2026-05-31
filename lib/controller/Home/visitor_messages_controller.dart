import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/routes.dart';
import '../../data/model/message/visitor_conversation_model.dart';
import '../../data/model/message/message_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class VisitorMessagesController extends GetxController {
  final visitorConversations    = <VisitorConversationModel>[].obs;
  final activeConversationId    = Rxn<int>();
  final inputCtrl               = TextEditingController();
  int _nextId                   = 800;

  @override
  void onInit() {
    visitorConversations.value = List.from(DummyData.visitorConversations);
    super.onInit();
  }

  // ── Active conversation helpers ─────────────────────────────────────
  VisitorConversationModel? get activeConversation {
    final id = activeConversationId.value;
    if (id == null) return null;
    return visitorConversations.firstWhereOrNull((c) => c.id == id);
  }

  List<MessageModel> get activeMessages =>
      activeConversation?.messages ?? [];

  // ── Open a conversation by id ───────────────────────────────────────
  void openConversation(int id) {
    activeConversationId.value = id;
    final conv = visitorConversations.firstWhereOrNull((c) => c.id == id);
    if (conv != null) {
      conv.unreadCount = 0;
      visitorConversations.refresh();
    }
  }

  // ── Open (or create) a visitor conversation ─────────────────────────
  void openConversationForVisitor(String visitorName) {
    var conv = visitorConversations.firstWhereOrNull(
      (c) => c.visitorName == visitorName,
    );

    if (conv == null) {
      final initials = visitorName.length >= 2
          ? visitorName.substring(0, 2)
          : visitorName;
      conv = VisitorConversationModel(
        id:               visitorConversations.length + 700,
        visitorName:      visitorName,
        visitorInitials:  initials,
        color:            0xFFFF1592,
        messages: [
          MessageModel(
            id: _nextId++,
            text: 'مرحباً، يسعدنا التواصل معك',
            isMe: false,
            time: _now(),
            isRead: true,
          ),
        ],
        unreadCount: 0,
      );
      visitorConversations.add(conv);
    }

    openConversation(conv.id);
    Get.toNamed(AppRoutes.VISITOR_CONVERSATION);
  }

  // ── Send a message ──────────────────────────────────────────────────
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
    visitorConversations.refresh();
    inputCtrl.clear();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (activeConversation?.id == conv.id) {
        conv.messages.add(MessageModel(
          id: _nextId++,
          text: 'شكراً لتواصلك معنا، سنرد عليك في أقرب وقت.',
          isMe: false,
          time: _now(),
          isRead: true,
        ));
        visitorConversations.refresh();
      }
    });
  }

  int get totalUnread =>
      visitorConversations.fold(0, (sum, c) => sum + c.unreadCount);

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
