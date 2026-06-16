// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:get/get.dart';
import '../services/services.dart';

class DownloadService {
  DownloadService._();

  static Future<void> downloadUrl(String url) async {
    try {
      final token = _token();
      final fullUrl = token.isNotEmpty
          ? (url.contains('?') ? '$url&token=$token' : '$url?token=$token')
          : url;

      final anchor = html.AnchorElement(href: fullUrl)
        ..setAttribute('download', '')
        ..style.display = 'none';
      html.document.body?.append(anchor);
      anchor.click();
      Future.delayed(
        const Duration(seconds: 5),
        () => anchor.remove(),
      );
    } catch (_) {
      try {
        html.window.open(url, '_blank');
      } catch (_) {}
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
