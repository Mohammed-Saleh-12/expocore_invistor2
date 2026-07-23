import 'dart:async';
import 'package:expocore_invistor2/data/sourcedata/remote/Firebace/MessagesFirebaseData.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/routes.dart';
import '../../core/services/services.dart';
import '../../data/model/message/conversation_model.dart';
import '../../data/model/message/message_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

// ════════════════════════════════════════════════════════════
//  MessagesController
//  محادثات المستثمر مع المعارض — Firebase Firestore
//  ─────────────────────────────────────────────────────────
//  الواجهات تستخدم conv.id (int) لتحديد المحادثة النشطة.
//  نحن نتتبع Firestore doc id (String) داخلياً عبر خريطة.
// ════════════════════════════════════════════════════════════
class MessagesController extends GetxController {
  final MessagesFirebaseData _firebaseData = MessagesFirebaseData();

  final conversations        = <ConversationModel>[].obs;
  /// id المحادثة النشطة — نفس النوع الذي تستخدمه الواجهة (int)
  final activeConversationId = Rxn<int>();
  final inputCtrl            = TextEditingController();
  final isLoading            = false.obs;
  final isSending            = false.obs;

  /// رسائل المحادثة المفتوحة (مُحدَّثة عبر Stream)
  final activeMessages = <MessageModel>[].obs;

  StreamSubscription<List<ConversationModel>>? _convSub;
  StreamSubscription<List<MessageModel>>?      _msgSub;

  /// خريطة int-id → Firestore doc-id
  final _firestoreIds = <int, String>{};

  int _investorId = 0;

  int get totalUnread =>
      conversations.fold(0, (sum, c) => sum + c.unreadCount);

  /// المحادثة النشطة كنموذج كامل (تستخدمها الواجهة المحمولة)
  ConversationModel? get activeConversation {
    final id = activeConversationId.value;
    if (id == null) return null;
    return conversations.firstWhereOrNull((c) => c.id == id);
  }

  @override
  void onInit() {
    _investorId = Get.find<Services>().userId;
    _subscribeToConversations();
    super.onInit();
  }

  void _subscribeToConversations() {
    if (_investorId == 0) {
      conversations.value = List.from(DummyData.conversations);
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    _convSub = _firebaseData.conversationsStream(_investorId).listen(
      (list) {
        conversations.value = list;
        isLoading.value = false;
      },
      onError: (e) {
        debugPrint('[Messages] Firestore error: $e');
        if (conversations.isEmpty) {
          conversations.value = List.from(DummyData.conversations);
        }
        isLoading.value = false;
      },
    );
  }

  // ── فتح محادثة (mobile: تمرَّر conv.id من النوع int) ───────
  void openConversation(int convId) {
    activeConversationId.value = convId;
    activeMessages.clear();
    _msgSub?.cancel();

    final firestoreId = _firestoreIds[convId];
    if (firestoreId == null) {
      // بيانات ثابتة أو مباشرة من الكاش
      final conv = conversations.firstWhereOrNull((c) => c.id == convId);
      if (conv != null) {
        activeMessages.value = List.from(conv.messages);
      }
      return;
    }
    _msgSub = _firebaseData.messagesStream(firestoreId).listen(
      (msgs) => activeMessages.value = msgs,
      onError: (e) => debugPrint('[Messages] msg stream: $e'),
    );
    _firebaseData.markConversationRead(firestoreId).ignore();
  }

  void closeConversation() {
    activeConversationId.value = null;
    activeMessages.clear();
    _msgSub?.cancel();
    _msgSub = null;
  }

  // ── إرسال رسالة — لا مُعامَل، يقرأ من inputCtrl (VoidCallback ✓) ─
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
        senderId:       _investorId,
        text:           text,
        isMe:           true,
      );
      isSending.value = false;
    } else {
      // fallback optimistic (بيانات ثابتة)
      final idx = conversations.indexWhere((c) => c.id == convId);
      if (idx != -1) {
        conversations[idx].messages.add(MessageModel(
          id: DateTime.now().millisecondsSinceEpoch,
          text: text,
          isMe: true,
          time: _now(),
          isRead: false,
        ));
        conversations.refresh();
        if (activeConversationId.value == convId) {
          activeMessages.add(conversations[idx].messages.last);
        }
      }
    }
  }

  // ── البحث عن محادثة باسم المعرض أو إنشائها ثم الانتقال للرسائل
  void prepareConversationForExhibition(String exhibitionName) {
    final existing = conversations.firstWhereOrNull(
      (c) => c.exhibitionName.contains(exhibitionName),
    );
    if (existing != null) {
      openConversation(existing.id);
    } else {
      _createAndOpen(exhibitionName: exhibitionName);
    }
  }

  /// يُستدعى من شاشة تفاصيل المعرض والجناح ثم ينتقل لصفحة الرسائل
  void openConversationForExhibitionName(String exhibitionName) {
    prepareConversationForExhibition(exhibitionName);
    Get.toNamed(AppRoutes.MESSAGES);
  }

  Future<void> _createAndOpen({required String exhibitionName}) async {
    if (_investorId == 0) return;
    final firestoreId = await _firebaseData.createConversation(
      investorId:         _investorId,
      exhibitionId:       0,
      exhibitionName:     exhibitionName,
      exhibitionInitials: _initials(exhibitionName),
      color:              0xFF7A1FFF,
    );
    final intId = firestoreId.hashCode.abs();
    _firestoreIds[intId] = firestoreId;
    openConversation(intId);
  }

  Future<void> refresh() async {
    _convSub?.cancel();
    _subscribeToConversations();
  }

  String _now() {
    final t = DateTime.now();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return name.isNotEmpty ? name[0] : '؟';
  }

  @override
  void onClose() {
    inputCtrl.dispose();
    _convSub?.cancel();
    _msgSub?.cancel();
    super.onClose();
  }
}
