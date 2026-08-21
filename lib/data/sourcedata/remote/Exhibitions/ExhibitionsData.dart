import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class ExhibitionsData {
  final Crud crud;
  ExhibitionsData(this.crud);

  /// جلب قائمة المعارض مع Pagination
  /// [page]    : رقم الصفحة (يبدأ من 1)
  /// [perPage] : عدد العناصر في الصفحة (افتراضي 15)
  /// [status]  : فلتر الحالة اختياري (upcoming | active | ended)
  /// [search]  : بحث نصي اختياري
  Future<Map<String, dynamic>> getExhibitions({
    int page = 1,
    int perPage = 15,
    String? status,
    String? city,
    String? sector,
    String? search,
  }) async {
    final params = <String, dynamic>{'page': page, 'per_page': perPage};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (sector != null && sector.isNotEmpty) params['sector'] = sector;
    if (search != null && search.isNotEmpty) params['search'] = search;
    return await crud.getData(AppLink.exhibitions, params: params);
  }

  /// جلب تفاصيل معرض واحد
  Future<Map<String, dynamic>> getExhibitionDetail(int id) async {
    return await crud.getData(AppLink.exhibitionDetail(id));
  }

  Future<Map<String, dynamic>> getMySponsorshipRequest(int exhibitionId) async {
    return await crud.getData(
      AppLink.exhibitionSponsorshipRequest(exhibitionId),
    );
  }

  Future<Map<String, dynamic>> submitSponsorshipRequest({
    required int exhibitionId,
    required String companyName,
    required String companyType,
    required String website,
    required String contactName,
    required String contactPhone,
    required String contactEmail,
    required String proposedTier,
    required double proposedAmount,
    required String offerDetails,
    required String conditions,
    required String contractTerms,
    required String startDate,
    required String endDate,
  }) async {
    return await crud.postData(AppLink.submitExhibitionSponsorshipRequest, {
      'exhibition_id': exhibitionId,
      'company_name': companyName,
      'company_type': companyType,
      'website': website.isEmpty ? null : website,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'proposed_tier': proposedTier.isEmpty ? null : proposedTier,
      'proposed_amount': proposedAmount,
      'offer_details': offerDetails,
      'conditions': conditions,
      'contract_terms': contractTerms,
      'start_date': startDate.isEmpty ? null : startDate,
      'end_date': endDate.isEmpty ? null : endDate,
    });
  }
}
