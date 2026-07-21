import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

Future<bool> alertExitApp() async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('تأكيد الخروج', style: TextStyle(fontFamily: 'Cairo')),
      content: const Text('هل تريد الخروج من التطبيق؟', style: TextStyle(fontFamily: 'Cairo')),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
        ),
        TextButton(
          onPressed: () => SystemNavigator.pop(),
          child: const Text('خروج', style: TextStyle(fontFamily: 'Cairo', color: Colors.red)),
        ),
      ],
    ),
  );
  return result ?? false;
}
