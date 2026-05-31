import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../core/constant/routes.dart';
import '../../data/model/message/conversation_model.dart';
import '../../data/model/message/message_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';
import '../../linkapi.dart';

class MessagesController extends GetxController {
  final _crud                = Crud();
  final conversations        = <ConversationModel>[].obs;
  final activeConversationId = Rxn<int>();
  final inputCtrl            = TextEditingController();
  final isLoading            = false.obs;
  final isSending            = false.obs;
  int _nextId                = 500;

  @override
  void onInit() {
    _loadConversations();
    super.onInit();
  }

  Future<void> _loadConversations() async {
    isLoading.value = true;
    final result = await _crud.getData(AppLink.investorMessages);
    if (result['status'] == true) {
      final list = _asList(result['data']);
      conversations.value =
          list.map((e) => ConversationModel.fromJson(e)).toList();
    } else {
      conversations.value = List.from(DummyData.conversations);
    }
    isLoading.value = false;
  }

  Future<void> _loadConversationMessages(int convId) async {
    final result = await _crud.getData(AppLink.conversationDetail(convId));
    if (result['status'] == true) {
      final d    = _body(result['data']);
      final msgs = _asList(d['messages'])
          .map((m) => MessageModel.fromJson(m))
          .toList();
      final idx = conversations.indexWhere((c) => c.id == convId);
      if (idx != -1) {
        final c = conversations[idx];
        conversations[idx] = ConversationModel(
          id:                 c.id,
          exhibitionId:       c.exhibitionId,
          exhibitionName:     c.exhibitionName,
          exhibitionInitials: c.exhibitionInitials,
          color:              c.color,
          messages:           msgs,
          unreadCount:        0,
        );
        conversations.refresh();
      }
    }
  }

  // ── Active conversation helpers ─────────────────────────────────────
  ConversationModel? get activeConversation {
    final id = activeConversationId.value;
    if (id == null) return null;
    return conversations.firstWhereOrNull((c) => c.id == id);
  }

  List<MessageModel> get activeMessages => activeConversation?.messages ?? [];

  // ── Open a conversation ─────────────────────────────────────────────
  void openConversation(int id) {
    activeConversationId.value = id;
    final conv = conversations.firstWhereOrNull((c) => c.id == id);
    if (conv != null) {
      conv.unreadCount = 0;
      conversations.refresh();
    }
    _loadConversationMessages(id);
  }

  // ── Open (or create) conversation by exhibition name ────────────────
  void openConversationForExhibitionName(String exhibitionName) {
    var conv = conversations.firstWhereOrNull(
      (c) => c.exhibitionName == exhibitionName,
    );

    if (conv == null) {
      final ex = DummyData.exhibitions
          .firstWhereOrNull((e) => e.name == exhibitionName);
      final initials = exhibitionName.length >= 2
          ? exhibitionName.substring(0, 2)
          : exhibitionName;
      conv = ConversationModel(
        id:                 conversations.length + 200,
        exhibitionId:       ex?.id ?? 0,
        exhibitionName:     exhibitionName,
        exhibitionInitials: initials,
        color:              0xFF7A1FFF,
        messages: [
          MessageModel(
            id: _nextId++, text: 'مرحباً، كيف يمكننا مساعدتك؟',
            isMe: false, time: _now(), isRead: true,
          ),
        ],
        unreadCount: 0,
      );
      conversations.add(conv);
      _crud.postData(AppLink.investorMessages, {
        'exhibition_id':   ex?.id ?? 0,
        'exhibition_name': exhibitionName,
      });
    }

    openConversation(conv.id);
    Get.toNamed(AppRoutes.CONVERSATION);
  }

  // ── Send a message ──────────────────────────────────────────────────
  Future<void> sendMessage() async {
    final text = inputCtrl.text.trim();
    if (text.isEmpty) return;
    final conv = activeConversation;
    if (conv == null) return;

    final optimisticMsg = MessageModel(
      id: _nextId++, text: text, isMe: true, time: _now(), isRead: false,
    );
    conv.messages.add(optimisticMsg);
    conversations.refresh();
    inputCtrl.clear();

    isSending.value = true;
    final result = await _crud.postData(AppLink.sendMessage(conv.id), {
      'text': text,
    });
    isSending.value = false;

    if (result['status'] != true) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (activeConversation?.id == conv.id) {
          conv.messages.add(MessageModel(
            id: _nextId++,
            text: 'شكراً لتواصلك معنا. سيرد عليك فريق الدعم قريباً.',
            isMe: false, time: _now(), isRead: true,
          ));
          conversations.refresh();
        }
      });
    }
  }

  int get totalUnread =>
      conversations.fold(0, (sum, c) => sum + c.unreadCount);

  Future<void> refresh() => _loadConversations();

  String _now() {
    final t = DateTime.now();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  List _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  dynamic _body(dynamic data) =>
      (data is Map && data['data'] is Map) ? data['data'] : (data ?? {});

  @override
  void onClose() {
    inputCtrl.dispose();
    super.onClose();
  }
}
