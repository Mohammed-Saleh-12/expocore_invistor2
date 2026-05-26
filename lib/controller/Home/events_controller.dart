import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/event/event_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class EventsController extends GetxController {
  final myEvents         = <EventModel>[].obs;
  final exhibitionEvents = <EventModel>[].obs;
  final selectedTab      = 0.obs;
  final isCreating       = false.obs;

  final nameCtrl        = TextEditingController();
  final descCtrl        = TextEditingController();
  final maxCtrl         = TextEditingController();
  final formKey         = GlobalKey<FormState>();
  final selectedType    = ''.obs;
  final eventTypes      = ['سحب', 'عرض مباشر', 'مسابقة', 'ورشة عمل', 'لقاء B2B'];

  @override
  void onInit() {
    myEvents.value         = DummyData.events.where((e) => e.boothNumber.isNotEmpty).toList();
    exhibitionEvents.value = DummyData.events;
    super.onInit();
  }

  void toggleFavorite(EventModel e) {
    e.isFavorite = !e.isFavorite;
    exhibitionEvents.refresh();
  }

  Future<void> createEvent() async {
    if (!formKey.currentState!.validate()) return;
    isCreating.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isCreating.value = false;
    Get.back();
    Get.snackbar('نجاح', 'تم إنشاء الفعالية بنجاح', snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void onClose() {
    nameCtrl.dispose(); descCtrl.dispose(); maxCtrl.dispose();
    super.onClose();
  }
}
