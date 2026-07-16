import 'package:expocore_invistor2/core/class/StatusRequest.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../core/constant/app_globals.dart';
import '../../core/constant/routes.dart';
import '../../core/services/services.dart';
import '../../data/sourcedata/remote/Auth/LogoutData.dart';
import '../../data/sourcedata/remote/Auth/ChangePasswordData.dart';
import '../../data/sourcedata/remote/Auth/DeleteAccountData.dart';

class SettingsController extends GetxController {
  final LogoutData _logoutData = LogoutData(Crud());
  final ChangePasswordData _changePasswordData = ChangePasswordData(Crud());
  final DeleteAccountData _deleteAccountData = DeleteAccountData(Crud());
  final RxBool isLoading = false.obs;
  final Rx<StatusRequest> status = StatusRequest.none.obs;
  final RxString errorMessage = ''.obs;
  final isDark = true.obs;
  final notificationsEnabled = true.obs;
  final favoritesNotify = true.obs;
  final reportsNotify = true.obs;
  final currentLang = 'ar'.obs;
  final isLoggingOut = false.obs;
  final isChangingPassword = false.obs;
  final isDeletingAccount = false.obs;

  @override
  void onInit() {
    isDark.value = Get.find<Services>().isDarkMode;
    currentLang.value = Get.find<Services>().lang;
    super.onInit();
  }

  void toggleTheme(bool val) {
    isDark.value = val;
    Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
    Get.find<Services>().saveTheme(val);
  }

  void changeLanguage(String lang) {
    currentLang.value = lang;
    appLang.value = lang;
    Get.updateLocale(Locale(lang, lang == 'ar' ? 'SA' : 'US'));
    Get.find<Services>().saveLang(lang);
  }

  Future<void> logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('settings_logout'.tr),
        content: Text('settings_logout_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('btn_cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'btn_confirm'.tr,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      isLoggingOut.value = true;
      await _logoutData.logout();
      await Get.find<Services>().clearSession();
      isLoggingOut.value = false;
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  /// تغيير كلمة المرور — يُغلق الـ dialog عند النجاح
  Future<void> changePassword({
    required String current,
    required String newPass,
    required String confirm,
  }) async {
    isLoading.value = true;
    status.value = StatusRequest.loading;
    errorMessage.value = '';
    if (newPass != confirm) {
      Get.snackbar(
        'خطأ',
        'كلمة المرور الجديدة وتأكيدها غير متطابقتين',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.85),
        colorText: Colors.white,
      );
      return;
    }

    isChangingPassword.value = true;
    final result = await _changePasswordData.changePassword(
      currentPassword: current,
      newPassword: newPass,
      newPasswordConfirmation: confirm,
    );
    isChangingPassword.value = false;

    if (result['status'] == true) {
      Get.back(); // أغلق الـ dialog
      Get.snackbar(
        'تم',
        'تم تغيير كلمة المرور بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.85),
        colorText: Colors.white,
      );
    } else {
      final msg =
          result['message'] ??
          'فشل تغيير كلمة المرور، تحقق من كلمة المرور الحالية';
      Get.snackbar(
        'خطأ',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.85),
        colorText: Colors.white,
      );
    }
    isLoading.value = false;
  }

  /// حذف الحساب — يُنهي الجلسة ويعود للتسجيل عند النجاح
  Future<void> deleteAccount() async {
    isDeletingAccount.value = true;
    final result = await _deleteAccountData.deleteAccount();
    isDeletingAccount.value = false;

    if (result['status'] == true) {
      await Get.find<Services>().clearSession();
      Get.offAllNamed(AppRoutes.LOGIN);
    } else {
      final msg = result['message'] ?? 'فشل حذف الحساب، حاول مجدداً';
      Get.snackbar(
        'خطأ',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.85),
        colorText: Colors.white,
      );
    }
  }
}
