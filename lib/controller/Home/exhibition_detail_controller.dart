import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../data/model/booth/booth_model.dart';
import '../../data/model/exhibition/exhibition_model.dart';
import '../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../data/model/exhibition/exhibition_sponsorship_request_model.dart';
import '../../data/sourcedata/remote/Exhibitions/ExhibitionsData.dart';
import '../../data/sourcedata/remote/Profile/ProfileData.dart';
import '../../data/sourcedata/remote/Booths/BoothsData.dart';
import '../../data/sourcedata/remote/Favorites/FavoritesData.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';
import 'booth_map_controller.dart';
import 'favorites_controller.dart';

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
  final ProfileData _profileData = ProfileData(Crud());
  final BoothsData _boothsData = BoothsData(Crud());
  final FavoritesData _favoritesData = FavoritesData(Crud());

  late TabController tabCtrl;

  final exhibition = Rxn<ExhibitionModel>();
  final exhibitionBooths = <BoothModel>[].obs;
  final isLoading = true.obs;
  final isFavorite = false.obs;
  final sponsorshipRequest = Rxn<ExhibitionSponsorshipRequestModel>();
  final isSponsorshipRequestLoading = false.obs;
  final isSponsorshipSubmitting = false.obs;

  final companyNameCtrl = TextEditingController();
  final companyTypeCtrl = TextEditingController();
  final websiteCtrl = TextEditingController();
  final contactNameCtrl = TextEditingController();
  final contactPhoneCtrl = TextEditingController();
  final contactEmailCtrl = TextEditingController();
  final proposedAmountCtrl = TextEditingController();
  final offerDetailsCtrl = TextEditingController();
  final conditionsCtrl = TextEditingController();
  final contractTermsCtrl = TextEditingController();
  final startDateCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();
  final proposedTier = ''.obs;

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
    loadSponsorshipRequest(exhibition.value!.id);
  }

  Future<void> loadSponsorshipRequest(int exhibitionId) async {
    isSponsorshipRequestLoading.value = true;
    final result = await _exhibitionsData.getMySponsorshipRequest(exhibitionId);
    if (result['status'] == true) {
      final raw = result['data'];
      final data = raw is Map && raw['data'] is Map ? raw['data'] : raw;
      sponsorshipRequest.value = data is Map
          ? ExhibitionSponsorshipRequestModel.fromJson(
              Map<String, dynamic>.from(data),
            )
          : null;
    }
    await _prefillSponsorshipForm();
    isSponsorshipRequestLoading.value = false;
  }

  Future<void> _prefillSponsorshipForm() async {
    final result = await _profileData.getProfile();
    if (result['status'] != true) return;
    final raw = result['data'];
    final data = raw is Map && raw['data'] is Map ? raw['data'] : raw;
    if (data is! Map) return;
    companyNameCtrl.text = (data['company_name'] ?? data['name'] ?? '')
        .toString();
    companyTypeCtrl.text = (data['activity_type'] ?? '').toString();
    websiteCtrl.text = (data['website'] ?? '').toString();
    contactPhoneCtrl.text = (data['phone'] ?? data['mobile'] ?? '').toString();
    contactEmailCtrl.text = (data['email'] ?? '').toString();
    contactNameCtrl.text = (data['contact_name'] ?? data['name'] ?? '')
        .toString();
  }

  Future<bool> submitSponsorshipRequest() async {
    final current = exhibition.value;
    if (current == null || sponsorshipRequest.value != null) return false;
    if (companyNameCtrl.text.trim().isEmpty ||
        contactPhoneCtrl.text.trim().isEmpty ||
        contactEmailCtrl.text.trim().isEmpty) {
      Get.snackbar('تنبيه', 'يرجى إدخال اسم الشركة والهاتف والبريد الإلكتروني');
      return false;
    }
    isSponsorshipSubmitting.value = true;
    final result = await _exhibitionsData.submitSponsorshipRequest(
      exhibitionId: current.id,
      companyName: companyNameCtrl.text.trim(),
      companyType: companyTypeCtrl.text.trim(),
      website: websiteCtrl.text.trim(),
      contactName: contactNameCtrl.text.trim(),
      contactPhone: contactPhoneCtrl.text.trim(),
      contactEmail: contactEmailCtrl.text.trim(),
      proposedTier: proposedTier.value,
      proposedAmount: double.tryParse(proposedAmountCtrl.text.trim()) ?? 0,
      offerDetails: offerDetailsCtrl.text.trim(),
      conditions: conditionsCtrl.text.trim(),
      contractTerms: contractTermsCtrl.text.trim(),
      startDate: startDateCtrl.text.trim(),
      endDate: endDateCtrl.text.trim(),
    );
    if (result['status'] == true) {
      final raw = result['data'];
      final data = raw is Map && raw['data'] is Map ? raw['data'] : raw;
      if (data is Map) {
        sponsorshipRequest.value = ExhibitionSponsorshipRequestModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }
      Get.snackbar('تم الإرسال', 'تم إرسال طلب الرعاية وهو قيد المراجعة');
    } else {
      Get.snackbar(
        'تعذر الإرسال',
        result['message'] ?? 'حدث خطأ أثناء إرسال الطلب',
      );
    }
    isSponsorshipSubmitting.value = false;
    return result['status'] == true;
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
            : (raw is Map
                  ? Map<String, dynamic>.from(raw)
                  : <String, dynamic>{});
        final updated = ExhibitionModel.fromJson(data);
        exhibition.value = updated;
        isFavorite.value = updated.isFavorite;
      }

      // ── 2. أجنحة المعرض ───────────────────────────────────
      final boothsResult = results[1];
      if (boothsResult['status'] == true) {
        final list = _asList(boothsResult['data']);
        exhibitionBooths.value = list
            .map((e) => BoothModel.fromJson(e as Map<String, dynamic>))
            .toList();
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
    mapCtrl.loadFromDetailData(exhibition.value?.mapJson, exhibitionBooths);
    mapCtrl.exhibitionId = exhibition.value?.id ?? 0;
  }

  // ── Favorite ─────────────────────────────────────────────────
  Future<void> toggleFavorite() async {
    final current = exhibition.value;
    if (current == null) return;

    final wasFavorite = isFavorite.value;
    final nextFavorite = !wasFavorite;
    isFavorite.value = nextFavorite;
    current.isFavorite = nextFavorite;

    final result = nextFavorite
        ? await _favoritesData.addFavorite(current.id, FavoriteType.exhibition)
        : await _favoritesData.removeFavorite(
            current.id,
            FavoriteType.exhibition,
          );

    if (result['status'] != true) {
      isFavorite.value = wasFavorite;
      current.isFavorite = wasFavorite;
      Get.snackbar(
        'تعذر تحديث المفضلة',
        result['message'] ?? 'حدث خطأ أثناء الاتصال',
      );
      return;
    }

    if (Get.isRegistered<FavoritesController>()) {
      final favoritesController = Get.find<FavoritesController>();
      if (nextFavorite) {
        if (!favoritesController.isExhibitionFavorited(current.id)) {
          favoritesController.favoriteExhibitions.add(current);
        }
      } else {
        favoritesController.favoriteExhibitions.removeWhere(
          (item) => item.id == current.id,
        );
      }
    }
  }

  // ── Status helpers ────────────────────────────────────────────
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

  // ── Refresh ───────────────────────────────────────────────────
  Future<void> refresh() => _loadFullDetail(exhibition.value?.id ?? 0);

  List _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['data'] is List) return data['data'];
      if (data['booths'] is List) return data['booths'];
    }
    return [];
  }

  @override
  void onClose() {
    tabCtrl.dispose();
    for (final ctrl in [
      companyNameCtrl,
      companyTypeCtrl,
      websiteCtrl,
      contactNameCtrl,
      contactPhoneCtrl,
      contactEmailCtrl,
      proposedAmountCtrl,
      offerDetailsCtrl,
      conditionsCtrl,
      contractTermsCtrl,
      startDateCtrl,
      endDateCtrl,
    ]) {
      ctrl.dispose();
    }
    super.onClose();
  }
}
