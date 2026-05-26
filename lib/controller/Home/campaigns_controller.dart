import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/campaign/campaign_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class CampaignsController extends GetxController {
  final campaigns   = <CampaignModel>[].obs;
  final isCreating  = false.obs;

  final titleCtrl  = TextEditingController();
  final descCtrl   = TextEditingController();
  final budgetCtrl = TextEditingController();
  final formKey    = GlobalKey<FormState>();
  final selectedType = ''.obs;
  final campaignTypes = ['إعلانات على شاشات المعرض', 'إعلانات على الخريطة 3D', 'عروض خاصة لزوار المعرض'];

  @override
  void onInit() {
    campaigns.value = DummyData.campaigns;
    super.onInit();
  }

  Future<void> createCampaign() async {
    if (!formKey.currentState!.validate()) return;
    isCreating.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isCreating.value = false;
    Get.back();
    Get.snackbar('نجاح', 'تم إنشاء الحملة بنجاح', snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void onClose() {
    titleCtrl.dispose(); descCtrl.dispose(); budgetCtrl.dispose();
    super.onClose();
  }
}
