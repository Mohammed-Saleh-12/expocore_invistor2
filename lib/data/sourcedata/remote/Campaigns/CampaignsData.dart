import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class CampaignsData {
  Crud crud;

  CampaignsData(this.crud);

  Future<Map<String, dynamic>> getCampaigns() async {
    return await crud.getData(AppLink.investorCampaigns);
  }

  Future<Map<String, dynamic>> createCampaign({
    required String title,
    required String description,
    required String type,
    required double budget,
    required String startDate,
    required String endDate,
  }) async {
    return await crud.postData(AppLink.investorCampaigns, {
      'title': title,
      'description': description,
      'type': type,
      'budget': budget,
      'start_date': startDate,
      'end_date': endDate,
    });
  }

  Future<Map<String, dynamic>> deleteCampaign(int campaignId) async {
    return await crud.deleteData(AppLink.campaignDetail(campaignId));
  }
}
