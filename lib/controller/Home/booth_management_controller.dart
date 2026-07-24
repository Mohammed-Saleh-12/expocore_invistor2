import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/class/StatusRequest.dart';
import '../../core/class/crud.dart';
import '../../data/model/booth/booth_model.dart';
import '../../data/model/event/event_model.dart';
import '../../data/sourcedata/remote/Booths/BoothProfileData.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class BoothManagementController extends GetxController {
  final BoothProfileData _boothProfileData = BoothProfileData(Crud());
  late BoothModel booth;

  final companyNatureCtrl    = TextEditingController();
  final servicesProductsCtrl = TextEditingController();
  final headquartersCtrl     = TextEditingController();
  final newLinkCtrl          = TextEditingController();

  final socialLinks        = <String>[].obs;
  final productImages      = <String>[].obs;   // URLs from server
  final boothImages        = <String>[].obs;   // URLs from server
  final productImageFiles  = <XFile>[].obs;    // locally picked
  final boothImageFiles    = <XFile>[].obs;    // locally picked
  final boothEvents        = <EventModel>[].obs;
  final isLoading          = false.obs;
  final isSaving           = false.obs;
  final status             = StatusRequest.none.obs;

  final _picker = ImagePicker();

  // ── صورة غلاف الجناح (قابلة للتعديل) ────────────────────
  final boothCoverFile = Rxn<XFile>();

  Future<void> pickBoothCoverImage() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (x != null) boothCoverFile.value = x;
    } catch (_) {
      Get.snackbar('خطأ', 'تعذّر فتح معرض الصور',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  final profileLinks = [
    'https://linkedin.com/company/myco',
    'https://twitter.com/myco',
    'https://instagram.com/myco',
  ];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is BoothModel) {
      booth = Get.arguments as BoothModel;
      _loadBoothProfile();
      _loadBoothEvents();
    } else {
      booth = DummyData.myBooths.first;
    }
  }

  void webInit(BoothModel b) {
    booth = b;
    _loadBoothProfile();
    _loadBoothEvents();
  }

  Future<void> _loadBoothProfile() async {
    isLoading.value = true;
    final result = await _boothProfileData.getBoothProfile(booth.id);
    if (result['status'] == true) {
      final d = _body(result['data']);
      companyNatureCtrl.text    = d['company_nature'] ?? '';
      servicesProductsCtrl.text = d['services_products'] ?? '';
      headquartersCtrl.text     = d['headquarters'] ?? '';
      socialLinks.value         = List<String>.from(d['social_links'] ?? []);
      productImages.value       = List<String>.from(d['product_images'] ?? []);
      boothImages.value         = List<String>.from(d['booth_images'] ?? []);
    } else {
      _loadFallbackProfile();
    }
    isLoading.value = false;
  }

  void _loadFallbackProfile() {
    socialLinks.value   = ['https://linkedin.com/company/myco'];
    productImages.value = [
      'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=400',
      'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=400',
    ];
    boothImages.value = [
      'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400',
    ];
  }

  Future<void> _loadBoothEvents() async {
    final result = await _boothProfileData.getBoothEvents(booth.id);
    if (result['status'] == true) {
      boothEvents.value = _asList(result['data'])
          .map((e) => EventModel.fromJson(e))
          .toList();
    } else {
      boothEvents.value = DummyData.events
          .where((e) => e.exhibitionName == booth.exhibitionName)
          .toList();
    }
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

  Future<void> addProductImage() async {
    try {
      final picked = await _picker.pickMultiImage(
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (picked.isNotEmpty) productImageFiles.addAll(picked);
    } catch (_) {
      Get.snackbar('خطأ', 'تعذّر فتح معرض الصور',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> addBoothImage() async {
    try {
      final picked = await _picker.pickMultiImage(
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (picked.isNotEmpty) boothImageFiles.addAll(picked);
    } catch (_) {
      Get.snackbar('خطأ', 'تعذّر فتح معرض الصور',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void removeProductImage(int index) {
    if (index < productImages.length) {
      productImages.removeAt(index);
    }
  }

  void removeBoothImage(int index) {
    if (index < boothImages.length) {
      boothImages.removeAt(index);
    }
  }

  void removeProductImageFile(int index) {
    if (index < productImageFiles.length) {
      productImageFiles.removeAt(index);
    }
  }

  void removeBoothImageFile(int index) {
    if (index < boothImageFiles.length) {
      boothImageFiles.removeAt(index);
    }
  }

  Future<void> saveProfile() async {
    isSaving.value = true;
    status.value   = StatusRequest.loading;

    final result = await _boothProfileData.updateBoothProfile(
      boothId:          booth.id,
      companyNature:    companyNatureCtrl.text.trim(),
      servicesProducts: servicesProductsCtrl.text.trim(),
      headquarters:     headquartersCtrl.text.trim(),
      socialLinks:      socialLinks.toList(),
      productImages:    productImages.toList(),
      boothImages:      boothImages.toList(),
      productImageFiles: productImageFiles.toList(),
      boothImageFiles:   boothImageFiles.toList(),
      coverImage:        boothCoverFile.value,
    );

    if (result['status'] == true) {
      status.value = StatusRequest.success;
      Get.snackbar(
        'booth_saved_title'.tr, 'booth_saved_msg'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50).withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    } else {
      status.value = StatusRequest.failure;
      Get.snackbar('error'.tr, result['message'] ?? 'booth_save_fail_msg'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
    isSaving.value = false;
  }

  Future<void> refresh() => _loadBoothProfile();

  List _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  dynamic _body(dynamic data) =>
      (data is Map && data['data'] is Map) ? data['data'] : (data ?? {});

  @override
  void onClose() {
    companyNatureCtrl.dispose();
    servicesProductsCtrl.dispose();
    headquartersCtrl.dispose();
    newLinkCtrl.dispose();
    super.onClose();
  }
}
