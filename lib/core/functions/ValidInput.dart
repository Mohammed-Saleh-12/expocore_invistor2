import 'package:get/get.dart';

class ValidInput {
  static String? email(String? val) {
    if (val == null || val.isEmpty) return 'البريد مطلوب';
    if (!GetUtils.isEmail(val)) return 'بريد إلكتروني غير صحيح';
    return null;
  }

  static String? phone(String? val) {
    if (val == null || val.isEmpty) return 'رقم الهاتف مطلوب';
    if (val.length < 9) return 'رقم هاتف غير صحيح';
    return null;
  }

  static String? password(String? val) {
    if (val == null || val.isEmpty) return 'كلمة السر مطلوبة';
    if (val.length < 6) return 'كلمة السر 6 أحرف على الأقل';
    return null;
  }

  static String? required(String? val, String fieldName) {
    if (val == null || val.isEmpty) return '$fieldName مطلوب';
    return null;
  }
}
