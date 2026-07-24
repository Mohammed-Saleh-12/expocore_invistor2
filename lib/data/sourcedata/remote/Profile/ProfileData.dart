import 'package:expocore_invistor2/core/class/crud.dart';
import 'package:expocore_invistor2/linkapi.dart';
import 'package:image_picker/image_picker.dart';

class ProfileData {
  Crud crud;

  ProfileData(this.crud);

  Future<Map<String, dynamic>> getProfile() async {
    return await crud.getData(AppLink.investorProfile);
  }

  Future<Map<String, dynamic>> updateProfile({
    required String companyName,
    required String email,
    required String location,
    required String phone,
    required String website,
    required String bio,
    required String linkedin,
    required String twitter,
    required String instagram,
    required String facebook,
  }) async {
    return await crud.putData(AppLink.investorProfile, {
      'company_name': companyName,
      'email': email,
      'location': location,
      'phone': phone,
      'website': website,
      'bio': bio,
      'social': {
        'linkedin': linkedin,
        'twitter': twitter,
        'instagram': instagram,
        'facebook': facebook,
      },
    });
  }

  Future<Map<String, dynamic>> uploadAvatar(XFile image) async {
    return await crud.uploadData(
      AppLink.investorProfileAvatar,
      {},
      files: [MapEntry('avatar', image)],
      method: 'POST',
    );
  }
}
