import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/class/crud.dart';
import '../../data/model/campaign/campaign_model.dart';
import '../../data/sourcedata/remote/Campaigns/CampaignsData.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class CampaignsController extends GetxController {
  final CampaignsData _campaignsData = CampaignsData(Crud());
  final campaigns  = <CampaignModel>[].obs;
  final isLoading  = false.obs;
  final isCreating = false.obs;
  final status     = StatusRequest.none.obs;

  final titleCtrl  = TextEditingController();
  final descCtrl   = TextEditingController();
  final budgetCtrl = TextEditingController();
  final formKey    = GlobalKey<FormState>();
  final selectedType   = ''.obs;
  final selectedStart  = ''.obs;
  final selectedEnd    = ''.obs;

  // ── وسائط الحملة (صور/فيديو) ─────────────────────────────
  final mediaFiles = <XFile>[].obs;
  final _picker    = ImagePicker();

  Future<void> pickCampaignMedia() async {
    const maxFiles = 5;
    if (mediaFiles.length >= maxFiles) {
      Get.snackbar('تنبيه', 'الحد الأقصى $maxFiles ملفات',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      final remaining = maxFiles - mediaFiles.length;
      final picked = await _picker.pickMultiImage(imageQuality: 85);
      if (picked.isEmpty) return;
      mediaFiles.addAll(picked.take(remaining));
    } catch (_) {
      Get.snackbar('خطأ', 'تعذّر فتح معرض الصور',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void removeCampaignMedia(int index) {
    if (index < mediaFiles.length) mediaFiles.removeAt(index);
  }
  final campaignTypes  = [
    'إعلانات على شاشات المعرض',
    'إعلانات على الخريطة 3D',
    'عروض خاصة لزوار المعرض',
  ];

  @override
  void onInit() {
    _loadCampaigns();
    super.onInit();
  }

  Future<void> _loadCampaigns() async {
    isLoading.value = true;
    final result = await _campaignsData.getCampaigns();
    if (result['status'] == true) {
      final list = _asList(result['data']);
      campaigns.value = list.map((e) => CampaignModel.fromJson(e)).toList();
    } else {
      campaigns.value = DummyData.campaigns;
    }
    isLoading.value = false;
  }

  Future<void> createCampaign() async {
    if (!formKey.currentState!.validate()) return;
    status.value = StatusRequest.loading;

    final result = await _campaignsData.createCampaign(
      title:       titleCtrl.text.trim(),
      description: descCtrl.text.trim(),
      type:        selectedType.value,
      budget:      double.tryParse(budgetCtrl.text) ?? 0,
      startDate:   selectedStart.value,
      endDate:     selectedEnd.value,
      mediaFiles:  mediaFiles.toList(),   // ← multipart upload
    );

    if (result['status'] == true) {
      status.value = StatusRequest.success;
      mediaFiles.clear();
      await _loadCampaigns();
      Get.back();
      Get.snackbar('success'.tr, 'campaign_created_msg'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      status.value = StatusRequest.failure;
      Get.snackbar('error'.tr, result['message'] ?? 'campaign_create_fail_msg'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteCampaign(int id) async {
    final result = await _campaignsData.deleteCampaign(id);
    if (result['status'] == true) {
      campaigns.removeWhere((c) => c.id == id);
      Get.snackbar('campaign_deleted_title'.tr, 'campaign_deleted_msg'.tr, snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('error'.tr, result['message'] ?? 'campaign_delete_fail_msg'.tr, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> refresh() => _loadCampaigns();

  List _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    budgetCtrl.dispose();
    mediaFiles.clear();
    super.onClose();
  }
}
