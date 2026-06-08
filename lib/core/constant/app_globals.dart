// ignore: depend_on_referenced_packages
import 'package:get/get.dart';

/// Global reactive language string — updated by SettingsController.
/// Used by main.dart to switch RTL ↔ LTR without requiring BuildContext.
final RxString appLang = 'ar'.obs;