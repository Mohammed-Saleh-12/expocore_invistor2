import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../data/model/booth/booth_model.dart';
import '../../data/model/exhibition/exhibition_model.dart';
import '../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../data/sourcedata/remote/Exhibitions/ExhibitionsData.dart';
import '../../data/sourcedata/remote/Booths/BoothsData.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';
import 'booth_map_controller.dart';

// ════════════════════════════════════════════════════════════
//  ExhibitionDetailController
//  عند onInit:
//   1. يعرض بيانات المعرض الأساسية من Get.arguments فوراً
//   2. يجلب التفاصيل الكاملة (خريطة + فعاليات + خدمات + صور)
//   3. يجلب أجنحة المعرض كاملة
//   4. يمرر الخريطة + الأجنحة إلى BoothMapController
// ════════════════════════════════════════════════════════════
class ExhibitionDetailController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ExhibitionsData _exhibitionsData = ExhibitionsData(Crud());
  final BoothsData      _boothsData      = BoothsData(Crud());

  late TabController tabCtrl;

  final exhibition     = Rxn<ExhibitionModel>();
  final exhibitionBooths = <BoothModel>[].obs;
  final isLoading      = true.obs;
  final isFavorite     = false.obs;

  // ── Convenience getters ──────────────────────────────────────
  List<ExhibitionSponsorEvent> get sponsorEvents =>
      exhibition.value?.sponsorEvents ?? [];

  List<String> get services => exhibition.value?.services ?? [];

  int get unreadCount => 0; // placeholder

  @override
  void onInit() {
    super.onInit();
    tabCtrl = TabController(length: 2, vsync: this);

    // عرض البيانات الأساسية فوراً من الـ arguments
    final arg = Get.arguments;
    ExhibitionModel? initial;
    if (arg is ExhibitionModel) {
      initial = arg;
    } else if (arg is Map && arg['exhibition'] is ExhibitionModel) {
      initial = arg['exhibition'] as ExhibitionModel;
    }

    if (initial != null) {
      exhibition.value = initial;
      isFavorite.value = initial.isFavorite;
    } else {
      exhibition.value = DummyData.exhibitions.first;
      isFavorite.value = exhibition.value!.isFavorite;
    }

    _loadFullDetail(exhibition.value!.id);
  }

  Future<void> _loadFullDetail(int id) async {
    isLoading.value = true;
    try {
      // ── طلبان متوازيان ────────────────────────────────────
      final results = await Future.wait([
        _exhibitionsData.getExhibitionDetail(id),
        _boothsData.getExhibitionBooths(id),
      ]);

      // ── 1. تفاصيل المعرض (صور + خدمات + خريطة + فعاليات) ─
      final detailResult = results[0];
      if (detailResult['status'] == true) {
        final raw = detailResult['data'];
        final data = raw is Map<String, dynamic>
            ? raw
            : (raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{});
        final updated = ExhibitionModel.fromJson(data);
        exhibition.value = updated;
        isFavorite.value = updated.isFavorite;
      }

      // ── 2. أجنحة المعرض ───────────────────────────────────
      final boothsResult = results[1];
      if (boothsResult['status'] == true) {
        final list = _asList(boothsResult['data']);
        exhibitionBooths.value =
            list.map((e) => BoothModel.fromJson(e as Map<String, dynamic>)).toList();
      }

      // ── 3. تمرير البيانات إلى BoothMapController ──────────
      _syncMapController();
    } catch (e) {
      debugPrint('[ExhibitionDetail] Error loading detail: $e');
    }
    isLoading.value = false;
  }

  void _syncMapController() {
    if (!Get.isRegistered<BoothMapController>()) return;
    final mapCtrl = Get.find<BoothMapController>();
    mapCtrl.loadFromDetailData(
      exhibition.value?.mapJson,
      exhibitionBooths,
    );
    mapCtrl.exhibitionId = exhibition.value?.id ?? 0;
  }

  // ── Favorite ─────────────────────────────────────────────────
  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
    exhibition.value?.isFavorite = isFavorite.value;
  }

  // ── Status helpers ────────────────────────────────────────────
  Color statusColor(String s, Color active, Color upcoming, Color ended) {
    if (s == 'active')   return active;
    if (s == 'upcoming') return upcoming;
    return ended;
  }

  String statusLabel(String s) {
    if (s == 'active')   return 'جارٍ'.tr;
    if (s == 'upcoming') return 'قادم'.tr;
    return 'منته'.tr;
  }

  // ── Refresh ───────────────────────────────────────────────────
  Future<void> refresh() => _loadFullDetail(exhibition.value?.id ?? 0);

  List _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['data']   is List) return data['data'];
      if (data['booths'] is List) return data['booths'];
    }
    return [];
  }

  @override
  void onClose() {
    tabCtrl.dispose();
    super.onClose();
  }
}
