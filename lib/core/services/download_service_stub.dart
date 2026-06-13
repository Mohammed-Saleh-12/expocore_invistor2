import 'dart:io';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../services/services.dart';
import '../utils/safe_snackbar.dart';

// ════════════════════════════════════════════════════════════
//  DownloadService  —  mobile/stub implementation
//  Downloads binary bytes from server with Dio, saves to the
//  system temp directory, then shares via share_plus.
// ════════════════════════════════════════════════════════════
class DownloadService {
  DownloadService._();

  static Future<void> downloadUrl(String url) async {
    try {
      final token = _token();
      final client = dio_pkg.Dio();

      final response = await client.get<List<int>>(
        url,
        options: dio_pkg.Options(
          responseType: dio_pkg.ResponseType.bytes,
          headers: token.isNotEmpty
              ? {'Authorization': 'Bearer $token'}
              : {},
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data == null || response.data!.isEmpty) {
        throw Exception('الملف فارغ');
      }

      final ext = url.contains('format=excel') ? '.xlsx' : '.pdf';
      final tmpPath =
          '${Directory.systemTemp.path}/expocore_report$ext';
      await File(tmpPath).writeAsBytes(response.data!);

      await Share.shareXFiles(
        [XFile(tmpPath)],
        subject: 'تقرير ExpoCore',
        text: 'تصدير التقرير من منصة ExpoCore',
      );
    } on dio_pkg.DioException catch (e) {
      safeSnackbar('خطأ في التنزيل', e.message ?? 'تعذّر الاتصال بالخادم');
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
