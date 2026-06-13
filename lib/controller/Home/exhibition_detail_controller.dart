import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/exhibition/exhibition_model.dart';
import '../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';
import 'events_controller.dart';

class ExhibitionDetailController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabCtrl;
  late ExhibitionModel exhibition;
  late EventsController eventsCtrl;
  late RxBool isFavorite;

  @override
  void onInit() {
    super.onInit();
    exhibition = Get.arguments as ExhibitionModel? ?? DummyData.exhibitions.first;
    tabCtrl = TabController(length: 2, vsync: this);
    eventsCtrl = Get.find<EventsController>();
    isFavorite = exhibition.isFavorite.obs;
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
    exhibition.isFavorite = isFavorite.value;
  }

  List<ExhibitionSponsorEvent> get exhibitionEvents => eventsCtrl
      .exhibitionSponsorEvents
      .where((e) => e.exhibitionId == exhibition.id)
      .toList();

  Color statusColor(String s, Color active, Color upcoming, Color ended) {
    if (s == 'active') return active;
    if (s == 'upcoming') return upcoming;
    return ended;
  }

  String statusLabel(String s) {
    if (s == 'active') return 'جارٍ'.tr;
    if (s == 'upcoming') return 'قادم'.tr;
    return 'منته'.tr;
  }

  @override
  void onClose() {
    tabCtrl.dispose();
    super.onClose();
  }
}
