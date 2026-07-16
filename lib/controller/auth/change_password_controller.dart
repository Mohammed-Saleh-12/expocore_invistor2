import 'package:expocore_invistor2/core/class/StatusRequest.dart';
import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../data/sourcedata/remote/Auth/ChangePasswordData.dart';

class ChangePasswordController extends GetxController {
  late final ChangePasswordData _changePasswordData;

  final RxBool isLoading = false.obs;
  final Rx<StatusRequest> status = StatusRequest.none.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _changePasswordData = ChangePasswordData(Get.find<Crud>());
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    isLoading.value = true;
    status.value = StatusRequest.loading;
    errorMessage.value = '';

    final response = await _changePasswordData.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: confirmPassword,
    );

    final sr = StatusRequest.values.byName(
      response['statusRequest'] ?? StatusRequest.failure.name,
    );

    if (sr == StatusRequest.success && response['status'] == true) {
      status.value = StatusRequest.success;
      Get.snackbar(
        'تم بنجاح',
        'تم تغيير كلمة المرور بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      Get.back();
    } else {
      status.value = sr;
      errorMessage.value =
          response['message']?.toString() ?? 'حدث خطأ، يرجى المحاولة مجدداً';
      Get.snackbar(
        'خطأ',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    isLoading.value = false;
  }
}
