import 'package:get/get.dart';

import '../../core/class/crud.dart';
import '../../core/services/services.dart';
import '../../linkapi.dart';

class UserRepository extends GetxService {
  final Crud _crud = Crud();

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final result = await _crud.getData(AppLink.investorProfile);
      if (result['status'] == true) {
        final data = result['data'];
        if (data is Map && data['data'] != null) {
          return Map<String, dynamic>.from(data['data']);
        }
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
      }
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<void> syncFirebaseProfile({
    required String firebaseUid,
    required String userId,
  }) async {
    final result = await _crud.postData(AppLink.firebaseSync, {
      'user_id': userId,
      'firebase_uid': firebaseUid,
    });
    if (result['status'] != true) {
      throw Exception(result['message'] ?? 'Firebase sync failed');
    }
  }

  Future<String> getCurrentUserId() async {
    return Get.find<Services>().userId.toString();
  }
}
