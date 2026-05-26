import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/routes.dart';

class ProfileCompanyController extends GetxController {
  final nameCtrl    = TextEditingController(text: 'شركة المستقبل التقنية');
  final emailCtrl   = TextEditingController(text: 'info@futuretech.sa');
  final phoneCtrl   = TextEditingController(text: '+966 50 123 4567');
  final websiteCtrl = TextEditingController(text: 'www.futuretech.sa');
  final bioCtrl     = TextEditingController(text: 'شركة رائدة في مجال التقنية والذكاء الاصطناعي، تأسست عام 2018.');
  final isEditing   = false.obs;
  final isSaving    = false.obs;

  void toggleEdit() => isEditing.value = !isEditing.value;

  Future<void> saveChanges() async {
    isSaving.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isSaving.value   = false;
    isEditing.value  = false;
    Get.snackbar('نجاح', 'تم حفظ التغييرات بنجاح', snackPosition: SnackPosition.BOTTOM);
  }

  void viewReport() => Get.toNamed(AppRoutes.REPORTS);

  @override
  void onClose() {
    nameCtrl.dispose(); emailCtrl.dispose(); phoneCtrl.dispose();
    websiteCtrl.dispose(); bioCtrl.dispose();
    super.onClose();
  }
}
