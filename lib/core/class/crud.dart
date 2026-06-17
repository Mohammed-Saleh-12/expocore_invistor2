import 'dart:convert';
import 'dart:developer' as dev;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../constant/app_env.dart';
import '../services/services.dart';

class Crud {
  // ── Build headers with token ───────────────────────────────
  Map<String, String> _headers({bool multipart = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      if (!multipart) 'Content-Type': 'application/json',
    };
    try {
      final token = Get.find<Services>().token;
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}
    return headers;
  }

  Uri _uri(String url, [Map<String, dynamic>? params]) {
    final uri = Uri.parse(url);
    if (params == null || params.isEmpty) return uri;
    return uri.replace(
      queryParameters: params.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  // ── GET ───────────────────────────────────────────────────
  Future<Map<String, dynamic>> getData(
    String url, {
    Map<String, dynamic>? params,
  }) async {
    try {
      if (AppEnv.logEnabled) dev.log('→ GET $url', name: 'API');
      final res = await http
          .get(_uri(url, params), headers: _headers())
          .timeout(AppEnv.receiveTimeout);
      return _handle(res);
    } catch (e) {
      return _unexpected(e);
    }
  }

  // ── POST ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> postData(
    String url,
    Map<String, dynamic> data,
  ) async {
    try {
      if (AppEnv.logEnabled) dev.log('→ POST $url', name: 'API');
      final res = await http
          .post(_uri(url), headers: _headers(), body: jsonEncode(data))
          .timeout(AppEnv.sendTimeout);
      return _handle(res);
    } catch (e) {
      return _unexpected(e);
    }
  }

  // ── PUT ───────────────────────────────────────────────────
  Future<Map<String, dynamic>> putData(
    String url,
    Map<String, dynamic> data,
  ) async {
    try {
      if (AppEnv.logEnabled) dev.log('→ PUT $url', name: 'API');
      final res = await http
          .put(_uri(url), headers: _headers(), body: jsonEncode(data))
          .timeout(AppEnv.sendTimeout);
      return _handle(res);
    } catch (e) {
      return _unexpected(e);
    }
  }

  // ── PATCH ─────────────────────────────────────────────────
  Future<Map<String, dynamic>> patchData(
    String url,
    Map<String, dynamic> data,
  ) async {
    try {
      if (AppEnv.logEnabled) dev.log('→ PATCH $url', name: 'API');
      final res = await http
          .patch(_uri(url), headers: _headers(), body: jsonEncode(data))
          .timeout(AppEnv.sendTimeout);
      return _handle(res);
    } catch (e) {
      return _unexpected(e);
    }
  }

  // ── DELETE ────────────────────────────────────────────────
  Future<Map<String, dynamic>> deleteData(String url) async {
    try {
      if (AppEnv.logEnabled) dev.log('→ DELETE $url', name: 'API');
      final res = await http
          .delete(_uri(url), headers: _headers())
          .timeout(AppEnv.receiveTimeout);
      return _handle(res);
    } catch (e) {
      return _unexpected(e);
    }
  }

  // ── MULTIPART UPLOAD ──────────────────────────────────────
  Future<Map<String, dynamic>> uploadData(
    String url,
    Map<String, dynamic> fields, {
    List<MapEntry<String, String>> filePaths = const [],
  }) async {
    try {
      if (AppEnv.logEnabled) dev.log('→ UPLOAD $url', name: 'API');
      final req = http.MultipartRequest('POST', _uri(url))
        ..headers.addAll(_headers(multipart: true));
      fields.forEach((k, v) => req.fields[k] = v.toString());
      for (final entry in filePaths) {
        req.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value),
        );
      }
      final streamed = await req.send().timeout(AppEnv.sendTimeout);
      final res = await http.Response.fromStream(streamed);
      return _handle(res);
    } catch (e) {
      return _unexpected(e);
    }
  }

  // ── Response handler ──────────────────────────────────────
  Map<String, dynamic> _handle(http.Response res) {
    if (AppEnv.logEnabled) {
      dev.log('← ${res.statusCode} ${res.request?.url}', name: 'API');
    }
    if (res.statusCode == 401) {
      _handleUnauthorized();
    }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      dynamic body;
      try {
        body = jsonDecode(res.body);
      } catch (_) {
        body = res.body;
      }
      return {'status': true, 'data': body, 'code': res.statusCode};
    }
    String msg = 'حدث خطأ في الاتصال';
    try {
      final d = jsonDecode(res.body);
      if (d is Map) msg = d['message']?.toString() ?? msg;
    } catch (_) {}
    return {'status': false, 'code': res.statusCode, 'message': msg};
  }

  Map<String, dynamic> _unexpected(Object e) {
    String msg = e.toString();
    if (msg.contains('TimeoutException') || msg.contains('timeout')) {
      msg = 'انتهت مهلة الاتصال بالخادم';
    } else if (msg.contains('SocketException') ||
        msg.contains('Connection refused') ||
        msg.contains('Failed host lookup')) {
      msg = 'تعذّر الاتصال — تحقق من الإنترنت';
    }
    return {'status': false, 'code': 0, 'message': msg};
  }

  void _handleUnauthorized() {
    try {
      Get.find<Services>().clearSession();
    } catch (_) {}
    if (GetPlatform.isWeb) return;
    if (Get.currentRoute != '/login') {
      Get.offAllNamed('/login');
      Get.snackbar(
        'انتهت الجلسة',
        'يرجى تسجيل الدخول مجدداً',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
