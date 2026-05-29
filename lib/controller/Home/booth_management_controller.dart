import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/booth/booth_model.dart';
import '../../data/model/event/event_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class BoothManagementController extends GetxController {
  late BoothModel booth;

  final companyNatureCtrl    = TextEditingController();
  final servicesProductsCtrl = TextEditingController();
  final headquartersCtrl     = TextEditingController();
  final newLinkCtrl          = TextEditingController();

  final socialLinks   = <String>[].obs;
  final productImages = <String>[].obs;
  final boothImages   = <String>[].obs;
  final boothEvents   = <EventModel>[].obs;
  final isSaving      = false.obs;

  final profileLinks = [
    'https://linkedin.com/company/myco',
    'https://twitter.com/myco',
    'https://instagram.com/myco',
  ];

  @override
  void onInit() {
    super.onInit();
    booth = Get.arguments as BoothModel? ?? DummyData.myBooths.first;
    _loadEvents();
    _loadDummyProfileData();
  }

  void _loadEvents() {
    boothEvents.value = DummyData.events
        .where((e) => e.exhibitionName == booth.exhibitionName)
        .toList();
  }

  void _loadDummyProfileData() {
    socialLinks.value = ['https://linkedin.com/company/myco'];
    productImages.value = [
      'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=400',
      'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=400',
    ];
    boothImages.value = [
      'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400',
    ];
  }

  void addSocialLink() {
    final link = newLinkCtrl.text.trim();
    if (link.isNotEmpty && !socialLinks.contains(link)) {
      socialLinks.add(link);
      newLinkCtrl.clear();
    }
  }

  void removeSocialLink(String link) => socialLinks.remove(link);

  void addProfileLink(String link) {
    if (!socialLinks.contains(link)) socialLinks.add(link);
  }

  void addProductImage() {
    productImages.add(
      'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=400',
    );
  }

  void addBoothImage() {
    boothImages.add(
      'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=400',
    );
  }

  Future<void> saveProfile() async {
    isSaving.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isSaving.value = false;
    Get.snackbar(
      'تم الحفظ',
      'تم حفظ معلومات الشركة بنجاح',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50).withOpacity(0.9),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  void onClose() {
    companyNatureCtrl.dispose();
    servicesProductsCtrl.dispose();
    headquartersCtrl.dispose();
    newLinkCtrl.dispose();
    super.onClose();
  }
}
