import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';

class RegisterData {
  Crud crud;

  RegisterData(this.crud);

  Future<Map<String, dynamic>> register({
    required String companyName,
    required String tradeName,
    required String email,
    required String location,
    required String phone,
    required String website,
    required String password,
    required String passwordConfirmation,
    required String activityType,
    String? fcmToken,
  }) async {
    final body = <String, dynamic>{
      'company_name': companyName,
      'trade_name': tradeName,
      'email': email,
      'location': location,
      'phone': phone,
      'website': website,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'activity_type': _backendActivityType(activityType),
      if ((fcmToken ?? '').isNotEmpty) 'fcm_token': fcmToken,
    };

    return await crud.postData(AppLink.register, body);
  }

  String _backendActivityType(String value) {
    const activityTypes = {
      'تقنية': 'technology',
      'غذاء وضيافة': 'food&hospitality',
      'موضة': 'fashion',
      'صحة': 'health',
      'تعليم': 'education',
      'أخرى': 'other',
    };

    return activityTypes[value] ?? value;
  }
}
