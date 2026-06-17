import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import '../services/services.dart';
import '../utils/safe_snackbar.dart';

class DownloadService {
  DownloadService._();

  static Future<void> downloadUrl(String url) async {
    try {
      final token = _token();
      final headers = <String, String>{
        'Accept': 'application/octet-stream',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.bodyBytes.isEmpty) {
        throw Exception('الملف فارغ');
      }

      final ext = url.contains('format=excel') ? '.xlsx' : '.pdf';
      final tmpPath =
          '${Directory.systemTemp.path}/expocore_report$ext';
      await File(tmpPath).writeAsBytes(response.bodyBytes);

      await Share.shareXFiles(
        [XFile(tmpPath)],
        subject: 'تقرير ExpoCore',
        text: 'تصدير التقرير من منصة ExpoCore',
      );
    } catch (e) {
      safeSnackbar('خطأ', 'تعذّر تنزيل التقرير. تأكد من الاتصال.');
    }
  }

  static String _token() {
    try {
      return Get.find<Services>().token;
    } catch (_) {
      return '';
    }
  }
}
