import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class CampaignsData {
  Crud crud;

  CampaignsData(this.crud);

  Future<Map<String, dynamic>> getCampaigns() async {
    return await crud.getData(AppLink.investorCampaigns);
  }

  Future<Map<String, dynamic>> createCampaign(Map<String, dynamic> body) async {
    return await crud.postData(AppLink.investorCampaigns, body);
  }

  Future<Map<String, dynamic>> deleteCampaign(int campaignId) async {
    return await crud.deleteData(AppLink.campaignDetail(campaignId));
  }
}
