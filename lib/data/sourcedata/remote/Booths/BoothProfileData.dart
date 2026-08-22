import 'dart:convert';
import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';
import 'package:image_picker/image_picker.dart';

class BoothProfileData {
  Crud crud;

  BoothProfileData(this.crud);

  Future<Map<String, dynamic>> getBoothProfile(int boothId) async {
    return await crud.getData(AppLink.boothProfile(boothId));
  }

  /// تحديث بروفايل الجناح.
  /// يحفظ معلومات الشركة والصور في ملف الجناح المعتمد.
  Future<Map<String, dynamic>> updateBoothProfile({
    required int boothId,
    required String companyNature,
    required String servicesProducts,
    required String headquarters,
    required List<String> socialLinks,
    required List<String> productImages,
    required List<String> boothImages,
    List<XFile> productImageFiles = const [],
    List<XFile> boothImageFiles = const [],
    XFile? coverImage,
  }) async {
    final hasFiles =
        productImageFiles.isNotEmpty ||
        boothImageFiles.isNotEmpty ||
        coverImage != null;

    if (!hasFiles) {
      return await crud.postData(AppLink.boothProfileUpdate(boothId), {
        'company_nature': companyNature,
        'services_products': servicesProducts,
        'headquarters': headquarters,
        'social_links': socialLinks,
        'product_images': productImages,
        'booth_images': boothImages,
      });
    }

    // مع ملفات: multipart مع method spoofing
    final fields = <String, dynamic>{
      'company_nature': companyNature,
      'services_products': servicesProducts,
      'headquarters': headquarters,
      // تشفير القوائم كـ JSON string (multipart لا يدعم arrays مباشرةً)
      'social_links': jsonEncode(socialLinks),
      'product_images': jsonEncode(productImages),
      'booth_images': jsonEncode(boothImages),
    };

    final files = <MapEntry<String, XFile>>[];
    for (final f in productImageFiles)
      files.add(MapEntry('product_images[]', f));
    for (final f in boothImageFiles) files.add(MapEntry('booth_images[]', f));
    if (coverImage != null) files.add(MapEntry('cover_image', coverImage));

    return await crud.uploadData(
      AppLink.boothProfileUpdate(boothId),
      fields,
      files: files,
      method: 'POST',
    );
  }

  /// رفع صورة غلاف الجناح منفردةً
  Future<Map<String, dynamic>> uploadBoothCover(
    int boothId,
    XFile cover,
  ) async {
    return await crud.uploadData(
      AppLink.boothCoverImage(boothId),
      {},
      files: [MapEntry('cover_image', cover)],
      method: 'POST',
    );
  }

  Future<Map<String, dynamic>> getBoothEvents(int boothId) async {
    return await crud.getData(
      AppLink.investorEvents,
      params: {'booth_id': boothId},
    );
  }
}
