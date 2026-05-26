import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/message/message_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class MessagesController extends GetxController {
  final messages   = <MessageModel>[].obs;
  final inputCtrl  = TextEditingController();
  final isTyping   = false.obs;
  int _nextId      = 100;

  @override
  void onInit() {
    messages.value = DummyData.messages;
    super.onInit();
  }

  void sendMessage() {
    final text = inputCtrl.text.trim();
    if (text.isEmpty) return;
    messages.add(MessageModel(
      id: _nextId++, text: text, isMe: true,
      time: _now(), isRead: false,
    ));
    inputCtrl.clear();
    Future.delayed(const Duration(seconds: 1), () {
      messages.add(MessageModel(
        id: _nextId++,
        text: 'شكراً لتواصلك معنا. سيرد عليك فريق الدعم قريباً.',
        isMe: false, time: _now(), isRead: true,
      ));
    });
  }

  String _now() {
    final t = DateTime.now();
    return '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
  }

  @override
  void onClose() {
    inputCtrl.dispose();
    super.onClose();
  }
}
