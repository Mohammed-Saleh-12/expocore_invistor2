import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/class/crud.dart';
import '../../data/model/campaign/campaign_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';
import '../../linkapi.dart';

class CampaignsController extends GetxController {
  final _crud      = Crud();
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
    final result = await _crud.getData(AppLink.investorCampaigns);
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

    final result = await _crud.postData(AppLink.investorCampaigns, {
      'title':      titleCtrl.text.trim(),
      'description': descCtrl.text.trim(),
      'type':       selectedType.value,
      'budget':     double.tryParse(budgetCtrl.text) ?? 0,
      'start_date': selectedStart.value,
      'end_date':   selectedEnd.value,
    });

    if (result['status'] == true) {
      status.value = StatusRequest.success;
      await _loadCampaigns();
      Get.back();
      Get.snackbar('نجاح', 'تم إنشاء الحملة بنجاح',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      status.value = StatusRequest.failure;
      Get.snackbar('خطأ', result['message'] ?? 'فشل إنشاء الحملة',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteCampaign(int id) async {
    final result = await _crud.deleteData(AppLink.campaignDetail(id));
    if (result['status'] == true) {
      campaigns.removeWhere((c) => c.id == id);
      Get.snackbar('تم الحذف', 'تم حذف الحملة', snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('خطأ', result['message'] ?? 'فشل الحذف', snackPosition: SnackPosition.BOTTOM);
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
    super.onClose();
  }
}
