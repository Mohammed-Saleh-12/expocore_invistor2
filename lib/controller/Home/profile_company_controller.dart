import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/class/crud.dart';
import '../../core/constant/routes.dart';
import '../../core/services/services.dart';
import '../../linkapi.dart';

class ProfileCompanyController extends GetxController {
  final _crud       = Crud();
  final nameCtrl    = TextEditingController();
  final emailCtrl   = TextEditingController();
  final locationCtrl   = TextEditingController();
  final phoneCtrl   = TextEditingController();
  final websiteCtrl = TextEditingController();
  final bioCtrl     = TextEditingController();
  final isEditing   = false.obs;
  final isLoading   = false.obs;
  final isSaving    = false.obs;
  final status      = StatusRequest.none.obs;

  @override
  void onInit() {
    _loadProfile();
    super.onInit();
  }

  Future<void> _loadProfile() async {
    isLoading.value = true;
    final result = await _crud.getData(AppLink.investorProfile);
    if (result['status'] == true) {
      final d = _body(result['data']);
      nameCtrl.text    = d['company_name'] ?? d['name'] ?? '';
      emailCtrl.text   = d['email'] ?? '';
      locationCtrl.text   = d['location'] ?? '';
      phoneCtrl.text   = d['phone'] ?? '';
      websiteCtrl.text = d['website'] ?? '';
      bioCtrl.text     = d['bio'] ?? '';
      final svc = Get.find<Services>();
      if (nameCtrl.text.isNotEmpty) await svc.saveCompany(nameCtrl.text);
    } else {
      nameCtrl.text    = Get.find<Services>().companyName;
      emailCtrl.text   = 'info@company.sa';
      locationCtrl.text   = 'syria/Damascus';
      phoneCtrl.text   = '+966 50 123 4567';
      websiteCtrl.text = 'www.company.sa';
      bioCtrl.text     = 'شركة رائدة في مجال التقنية والذكاء الاصطناعي، تأسست عام 2018.';
    }
    isLoading.value = false;
  }

  void toggleEdit() => isEditing.value = !isEditing.value;

  Future<void> saveChanges() async {
    isSaving.value = true;
    status.value   = StatusRequest.loading;

    final result = await _crud.putData(AppLink.investorProfile, {
      'company_name': nameCtrl.text.trim(),
      'email':        emailCtrl.text.trim(),
      'location':        locationCtrl.text.trim(),
      'phone':        phoneCtrl.text.trim(),
      'website':      websiteCtrl.text.trim(),
      'bio':          bioCtrl.text.trim(),
    });

    if (result['status'] == true) {
      await Get.find<Services>().saveCompany(nameCtrl.text.trim());
      status.value   = StatusRequest.success;
      isEditing.value = false;
      Get.snackbar('نجاح', 'تم حفظ التغييرات بنجاح',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      status.value = StatusRequest.failure;
      Get.snackbar('خطأ', result['message'] ?? 'فشل الحفظ',
          snackPosition: SnackPosition.BOTTOM);
    }
    isSaving.value = false;
  }

  void viewReport() => Get.toNamed(AppRoutes.REPORTS);

  dynamic _body(dynamic data) =>
      (data is Map && data['data'] is Map) ? data['data'] : (data ?? {});

  @override
  void onClose() {
    nameCtrl.dispose(); emailCtrl.dispose(); phoneCtrl.dispose();
    websiteCtrl.dispose(); bioCtrl.dispose();
    super.onClose();
  }
}
