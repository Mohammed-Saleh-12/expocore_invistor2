import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../core/constant/routes.dart';
import '../../data/model/message/visitor_conversation_model.dart';
import '../../data/model/message/message_model.dart';
import '../../data/sourcedata/remote/VisitorMessages/VisitorMessagesData.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class VisitorMessagesController extends GetxController {
  final VisitorMessagesData _visitorMessagesData = VisitorMessagesData(Crud());
  final visitorConversations = <VisitorConversationModel>[].obs;
  final activeConversationId = Rxn<int>();
  final inputCtrl            = TextEditingController();
  final isLoading            = false.obs;
  final isSending            = false.obs;
  int _nextId                = 800;

  @override
  void onInit() {
    _loadConversations();
    super.onInit();
  }

  Future<void> _loadConversations() async {
    isLoading.value = true;
    final result = await _visitorMessagesData.getConversations();
    if (result['status'] == true) {
      final list = _asList(result['data']);
      visitorConversations.value =
          list.map((e) => VisitorConversationModel.fromJson(e)).toList();
    } else {
      visitorConversations.value = List.from(DummyData.visitorConversations);
    }
    isLoading.value = false;
  }

  Future<void> _loadConversationMessages(int convId) async {
    final result = await _visitorMessagesData.getConversationDetail(convId);
    if (result['status'] == true) {
      final d    = _body(result['data']);
      final msgs = _asList(d['messages'])
          .map((m) => MessageModel.fromJson(m))
          .toList();
      final idx = visitorConversations.indexWhere((c) => c.id == convId);
      if (idx != -1) {
        final c = visitorConversations[idx];
        visitorConversations[idx] = VisitorConversationModel(
          id:              c.id,
          visitorName:     c.visitorName,
          visitorInitials: c.visitorInitials,
          color:           c.color,
          messages:        msgs,
          unreadCount:     0,
        );
        visitorConversations.refresh();
      }
    }
  }

  // ── Active conversation helpers ─────────────────────────────────────
  VisitorConversationModel? get activeConversation {
    final id = activeConversationId.value;
    if (id == null) return null;
    return visitorConversations.firstWhereOrNull((c) => c.id == id);
  }

  List<MessageModel> get activeMessages => activeConversation?.messages ?? [];

  // ── Open a conversation ─────────────────────────────────────────────
  void openConversation(int id) {
    activeConversationId.value = id;
    final conv = visitorConversations.firstWhereOrNull((c) => c.id == id);
    if (conv != null) {
      conv.unreadCount = 0;
      visitorConversations.refresh();
    }
    _loadConversationMessages(id);
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
        id:              visitorConversations.length + 700,
        visitorName:     visitorName,
        visitorInitials: initials,
        color:           0xFFFF1592,
        messages: [
          MessageModel(
            id: _nextId++, text: 'مرحباً، يسعدنا التواصل معك',
            isMe: false, time: _now(), isRead: true,
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
  Future<void> sendMessage() async {
    final text = inputCtrl.text.trim();
    if (text.isEmpty) return;
    final conv = activeConversation;
    if (conv == null) return;

    final optimisticMsg = MessageModel(
      id: _nextId++, text: text, isMe: true, time: _now(), isRead: false,
    );
    conv.messages.add(optimisticMsg);
    visitorConversations.refresh();
    inputCtrl.clear();

    isSending.value = true;
    final result = await _visitorMessagesData.sendMessage(conv.id, text);
    isSending.value = false;

    if (result['status'] != true) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (activeConversation?.id == conv.id) {
          conv.messages.add(MessageModel(
            id: _nextId++,
            text: 'شكراً لتواصلك معنا، سنرد عليك في أقرب وقت.',
            isMe: false, time: _now(), isRead: true,
          ));
          visitorConversations.refresh();
        }
      });
    }
  }

  int get totalUnread =>
      visitorConversations.fold(0, (sum, c) => sum + c.unreadCount);

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
