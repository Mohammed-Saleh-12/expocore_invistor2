import 'dart:async';
import 'package:expocore_invistor2/data/sourcedata/remote/Firebace/VisitorMessagesFirebaseData.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/services.dart';
import '../../data/model/message/visitor_conversation_model.dart';
import '../../data/model/message/message_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

// ════════════════════════════════════════════════════════════
//  VisitorMessagesController
//  محادثات المستثمر مع الزوار — Firebase Firestore
//  ─────────────────────────────────────────────────────────
//  يستخدم نفس نمط MessagesController للتوافق مع الواجهات.
// ════════════════════════════════════════════════════════════
class VisitorMessagesController extends GetxController {
  final VisitorMessagesFirebaseData _firebaseData = VisitorMessagesFirebaseData();

  final visitorConversations = <VisitorConversationModel>[].obs;
  final activeConversationId = Rxn<int>();
  final inputCtrl            = TextEditingController();
  final isLoading            = false.obs;
  final isSending            = false.obs;

  final activeMessages = <MessageModel>[].obs;

  StreamSubscription<List<VisitorConversationModel>>? _convSub;
  StreamSubscription<List<MessageModel>>?             _msgSub;

  final _firestoreIds = <int, String>{};

  int _investorId = 0;

  int get totalUnread =>
      visitorConversations.fold(0, (sum, c) => sum + c.unreadCount);

  /// المحادثة النشطة (للتوافق مع messages_view.dart و visitor_messages_view.dart)
  VisitorConversationModel? get activeConversation {
    final id = activeConversationId.value;
    if (id == null) return null;
    return visitorConversations.firstWhereOrNull((c) => c.id == id);
  }

  @override
  void onInit() {
    _investorId = Get.find<Services>().userId;
    _subscribeToConversations();
    super.onInit();
  }

  void _subscribeToConversations() {
    if (_investorId == 0) {
      visitorConversations.value = List.from(DummyData.visitorConversations);
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    _convSub = _firebaseData.conversationsStream(_investorId).listen(
      (list) {
        visitorConversations.value = list;
        isLoading.value = false;
      },
      onError: (e) {
        debugPrint('[VisitorMessages] Firestore error: $e');
        if (visitorConversations.isEmpty) {
          visitorConversations.value = List.from(DummyData.visitorConversations);
        }
        isLoading.value = false;
      },
    );
  }

  void openConversation(int convId) {
    activeConversationId.value = convId;
    activeMessages.clear();
    _msgSub?.cancel();

    final firestoreId = _firestoreIds[convId];
    if (firestoreId == null) {
      final conv = visitorConversations.firstWhereOrNull((c) => c.id == convId);
      if (conv != null) {
        activeMessages.value = List.from(conv.messages);
      }
      return;
    }
    _msgSub = _firebaseData.messagesStream(firestoreId).listen(
      (msgs) => activeMessages.value = msgs,
      onError: (e) => debugPrint('[VisitorMessages] msg stream: $e'),
    );
    _firebaseData.markConversationRead(firestoreId).ignore();
  }

  void closeConversation() {
    activeConversationId.value = null;
    activeMessages.clear();
    _msgSub?.cancel();
    _msgSub = null;
  }

  // ── إرسال رسالة — بدون مُعامَل لدعم VoidCallback ────────
  Future<void> sendMessage() async {
    final text = inputCtrl.text.trim();
    if (text.isEmpty) return;
    final convId      = activeConversationId.value;
    final firestoreId = convId != null ? _firestoreIds[convId] : null;
    inputCtrl.clear();

    if (firestoreId != null) {
      isSending.value = true;
      await _firebaseData.sendMessage(
        conversationId: firestoreId,
        text:           text,
        isMe:           true,
      );
      isSending.value = false;
    } else {
      // fallback optimistic
      final idx = visitorConversations.indexWhere((c) => c.id == convId);
      if (idx != -1) {
        visitorConversations[idx].messages.add(MessageModel(
          id:     DateTime.now().millisecondsSinceEpoch,
          text:   text,
          isMe:   true,
          time:   _now(),
          isRead: false,
        ));
        visitorConversations.refresh();
        if (activeConversationId.value == convId) {
          activeMessages.add(visitorConversations[idx].messages.last);
        }
      }
    }
  }

  Future<void> refresh() async {
    _convSub?.cancel();
    _subscribeToConversations();
  }

  String _now() {
    final t = DateTime.now();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    inputCtrl.dispose();
    _convSub?.cancel();
    _msgSub?.cancel();
    super.onClose();
  }
}
