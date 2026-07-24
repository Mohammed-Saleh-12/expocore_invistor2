import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';
import 'package:image_picker/image_picker.dart';

class CampaignsData {
  Crud crud;

  CampaignsData(this.crud);

  Future<Map<String, dynamic>> getCampaigns() async {
    return await crud.getData(AppLink.investorCampaigns);
  }

  /// إنشاء حملة — مع وسائط اختيارية (multipart) أو بدونها (JSON).
  Future<Map<String, dynamic>> createCampaign({
    required String title,
    required String description,
    required String type,
    required double budget,
    required String startDate,
    required String endDate,
    List<XFile>     mediaFiles = const [],
  }) async {
    final fields = <String, dynamic>{
      'title':       title,
      'description': description,
      'type':        type,
      'budget':      budget,
      'start_date':  startDate,
      'end_date':    endDate,
    };

    if (mediaFiles.isEmpty) {
      return await crud.postData(AppLink.investorCampaigns, fields);
    }

    return await crud.uploadData(
      AppLink.investorCampaigns,
      fields,
      files: mediaFiles.map((f) => MapEntry('media[]', f)).toList(),
    );
  }

  Future<Map<String, dynamic>> deleteCampaign(int campaignId) async {
    return await crud.deleteData(AppLink.campaignDetail(campaignId));
  }
}
