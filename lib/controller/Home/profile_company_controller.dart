import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/class/crud.dart';
import '../../core/constant/routes.dart';
import '../../core/services/services.dart';
import '../../data/sourcedata/remote/Profile/ProfileData.dart';

class ProfileCompanyController extends GetxController {
  final ProfileData _profileData = ProfileData(Crud());
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

  // ── الصورة الشخصية ───────────────────────────────────────
  final profileImage = Rxn<XFile>();
  final _picker      = ImagePicker();

  Future<void> pickProfileImage() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (x != null) profileImage.value = x;
    } catch (e) {
      Get.snackbar('pick_image_error'.tr, 'pick_image_error_msg'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── روابط التواصل الاجتماعي ──────────────────────────────
  final linkedinCtrl  = TextEditingController();
  final twitterCtrl   = TextEditingController();
  final instagramCtrl = TextEditingController();
  final facebookCtrl  = TextEditingController();

  @override
  void onInit() {
    _loadProfile();
    super.onInit();
  }

  Future<void> _loadProfile() async {
    isLoading.value = true;
    final result = await _profileData.getProfile();
    if (result['status'] == true) {
      final d = _body(result['data']);
      nameCtrl.text    = d['company_name'] ?? d['name'] ?? '';
      emailCtrl.text   = d['email'] ?? '';
      locationCtrl.text   = d['location'] ?? '';
      phoneCtrl.text   = d['phone'] ?? '';
      websiteCtrl.text = d['website'] ?? '';
      bioCtrl.text     = d['bio'] ?? '';
      final social     = d['social'] is Map ? d['social'] : {};
      linkedinCtrl.text  = social['linkedin']  ?? '';
      twitterCtrl.text   = social['twitter']   ?? social['x'] ?? '';
      instagramCtrl.text = social['instagram'] ?? '';
      facebookCtrl.text  = social['facebook']  ?? '';
      final svc = Get.find<Services>();
      if (nameCtrl.text.isNotEmpty) await svc.saveCompany(nameCtrl.text);
    } else {
      nameCtrl.text    = Get.find<Services>().companyName;
      emailCtrl.text   = 'info@company.sa';
      locationCtrl.text   = 'syria/Damascus';
      phoneCtrl.text   = '+966 50 123 4567';
      websiteCtrl.text = 'www.company.sa';
      bioCtrl.text     = 'شركة رائدة في مجال التقنية والذكاء الاصطناعي، تأسست عام 2018.';
      linkedinCtrl.text  = 'linkedin.com/company/expocore';
      twitterCtrl.text   = '@expocore';
      instagramCtrl.text = '@expocore';
      facebookCtrl.text  = 'facebook.com/expocore';
    }
    isLoading.value = false;
  }

  void toggleEdit() => isEditing.value = !isEditing.value;

  Future<void> saveChanges() async {
    isSaving.value = true;
    status.value   = StatusRequest.loading;

    final result = await _profileData.updateProfile({
      'company_name': nameCtrl.text.trim(),
      'email':        emailCtrl.text.trim(),
      'location':        locationCtrl.text.trim(),
      'phone':        phoneCtrl.text.trim(),
      'website':      websiteCtrl.text.trim(),
      'bio':          bioCtrl.text.trim(),
      'social': {
        'linkedin':  linkedinCtrl.text.trim(),
        'twitter':   twitterCtrl.text.trim(),
        'instagram': instagramCtrl.text.trim(),
        'facebook':  facebookCtrl.text.trim(),
      },
    });

    if (result['status'] == true) {
      await Get.find<Services>().saveCompany(nameCtrl.text.trim());
      status.value   = StatusRequest.success;
      isEditing.value = false;
      Get.snackbar('success'.tr, 'profile_saved_msg'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      status.value = StatusRequest.failure;
      Get.snackbar('error'.tr, result['message'] ?? 'profile_save_fail_msg'.tr,
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
    websiteCtrl.dispose(); bioCtrl.dispose(); locationCtrl.dispose();
    linkedinCtrl.dispose(); twitterCtrl.dispose();
    instagramCtrl.dispose(); facebookCtrl.dispose();
    super.onClose();
  }
}
