import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class BoothProfileData {
  Crud crud;

  BoothProfileData(this.crud);

  Future<Map<String, dynamic>> getBoothProfile(int boothId) async {
    return await crud.getData(AppLink.boothProfile(boothId));
  }

  Future<Map<String, dynamic>> updateBoothProfile({
    required int boothId,
    required String companyNature,
    required String servicesProducts,
    required String headquarters,
    required List<String> socialLinks,
    required List<String> productImages,
    required List<String> boothImages,
  }) async {
    return await crud.putData(AppLink.boothProfile(boothId), {
      'company_nature': companyNature,
      'services_products': servicesProducts,
      'headquarters': headquarters,
      'social_links': socialLinks,
      'product_images': productImages,
      'booth_images': boothImages,
    });
  }

  Future<Map<String, dynamic>> getBoothEvents(int boothId) async {
    return await crud.getData(
      AppLink.investorEvents,
      params: {'booth_id': boothId},
    );
  }
}
