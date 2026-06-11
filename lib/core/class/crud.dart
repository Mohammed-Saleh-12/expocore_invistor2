import 'dart:developer' as dev;
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart' hide Response;
import '../constant/app_env.dart';
import '../services/services.dart';

// ════════════════════════════════════════════════════════════
//  Crud  —  central HTTP client
//  • Dio with interceptors (auth, logging, error, 401 logout)
//  • All methods return Map<String, dynamic> for compatibility
// ════════════════════════════════════════════════════════════
class Crud {
  late final dio.Dio _dio;

  Crud() {
    _dio = dio.Dio(
      dio.BaseOptions(
        baseUrl:        AppEnv.baseUrl,
        connectTimeout: AppEnv.connectTimeout,
        receiveTimeout: AppEnv.receiveTimeout,
        sendTimeout:    AppEnv.sendTimeout,
        headers: {
          'Accept':       'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    _dio.interceptors.addAll([
      _AuthInterceptor(),
      if (AppEnv.logEnabled) _LogInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  // ── GET ───────────────────────────────────────────────────
  Future<Map<String, dynamic>> getData(
    String url, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final res = await _dio.get(url, queryParameters: params);
      return _ok(res.data);
    } on dio.DioException catch (e) {
      return _err(e);
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
      final res = await _dio.post(url, data: data);
      return _ok(res.data);
    } on dio.DioException catch (e) {
      return _err(e);
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
      final res = await _dio.put(url, data: data);
      return _ok(res.data);
    } on dio.DioException catch (e) {
      return _err(e);
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
      final res = await _dio.patch(url, data: data);
      return _ok(res.data);
    } on dio.DioException catch (e) {
      return _err(e);
    } catch (e) {
      return _unexpected(e);
    }
  }

  // ── DELETE ────────────────────────────────────────────────
  Future<Map<String, dynamic>> deleteData(String url) async {
    try {
      final res = await _dio.delete(url);
      return _ok(res.data);
    } on dio.DioException catch (e) {
      return _err(e);
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
      final form = dio.FormData.fromMap(fields);
      for (final entry in filePaths) {
        form.files.add(MapEntry(
          entry.key,
          await dio.MultipartFile.fromFile(entry.value),
        ));
      }
      final res = await _dio.post(
        url,
        data: form,
        options: dio.Options(contentType: 'multipart/form-data'),
      );
      return _ok(res.data);
    } on dio.DioException catch (e) {
      return _err(e);
    } catch (e) {
      return _unexpected(e);
    }
  }

  // ── Response helpers ──────────────────────────────────────
  Map<String, dynamic> _ok(dynamic data) =>
      {'status': true, 'data': data, 'code': 200};

  Map<String, dynamic> _err(dio.DioException e) {
    final code = e.response?.statusCode ?? 0;
    String msg  = 'حدث خطأ في الاتصال';
    try {
      final d = e.response?.data;
      if (d is Map) msg = d['message']?.toString() ?? msg;
    } catch (_) {}
    return {'status': false, 'code': code, 'message': msg};
  }

  Map<String, dynamic> _unexpected(Object e) =>
      {'status': false, 'code': 0, 'message': e.toString()};
}

// ════════════════════════════════════════════════════════════
//  _AuthInterceptor  —  injects Bearer token on every request
//                       auto-logout on 401
// ════════════════════════════════════════════════════════════
class _AuthInterceptor extends dio.Interceptor {
  @override
  void onRequest(
      dio.RequestOptions options, dio.RequestInterceptorHandler handler) {
    try {
      final token = Get.find<Services>().token;
      if (token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}
    handler.next(options);
  }

  @override
  void onError(dio.DioException err, dio.ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _handleUnauthorized();
    }
    handler.next(err);
  }

  void _handleUnauthorized() {
    try {
      Get.find<Services>().clearSession();
    } catch (_) {}
    // على الويب تتولى WebAuthController إدارة حالة الجلسة — لا نستخدم مسارات GetX
    if (GetPlatform.isWeb) return;
    // إعادة توجيه للوجين — يُنفَّذ مرة واحدة فقط
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

// ════════════════════════════════════════════════════════════
//  _LogInterceptor  —  dev-only request/response logger
// ════════════════════════════════════════════════════════════
class _LogInterceptor extends dio.Interceptor {
  @override
  void onRequest(
      dio.RequestOptions options, dio.RequestInterceptorHandler handler) {
    dev.log(
      '→ ${options.method} ${options.path}',
      name: 'API',
    );
    if (options.data != null) {
      dev.log('  body: ${options.data}', name: 'API');
    }
    handler.next(options);
  }

  @override
  void onResponse(
      dio.Response response, dio.ResponseInterceptorHandler handler) {
    dev.log(
      '← ${response.statusCode} ${response.requestOptions.path}',
      name: 'API',
    );
    handler.next(response);
  }

  @override
  void onError(dio.DioException err, dio.ErrorInterceptorHandler handler) {
    dev.log(
      '✗ ${err.response?.statusCode ?? "?"} ${err.requestOptions.path} — ${err.message}',
      name: 'API',
      error: err,
    );
    handler.next(err);
  }
}

// ════════════════════════════════════════════════════════════
//  _ErrorInterceptor  —  maps DioException types to readable msgs
// ════════════════════════════════════════════════════════════
class _ErrorInterceptor extends dio.Interceptor {
  static const _msgs = {
    dio.DioExceptionType.connectionTimeout: 'انتهت مهلة الاتصال بالخادم',
    dio.DioExceptionType.receiveTimeout:    'استغرق الخادم وقتاً طويلاً للرد',
    dio.DioExceptionType.sendTimeout:       'فشل إرسال البيانات',
    dio.DioExceptionType.connectionError:   'تعذّر الاتصال — تحقق من الإنترنت',
    dio.DioExceptionType.cancel:            'تم إلغاء الطلب',
  };

  @override
  void onError(dio.DioException err, dio.ErrorInterceptorHandler handler) {
    final mapped = _msgs[err.type];
    if (mapped != null && err.response == null) {
      handler.reject(
        dio.DioException(
          requestOptions: err.requestOptions,
          type:           err.type,
          error:          mapped,
          response:       err.response,
        ),
      );
      return;
    }
    handler.next(err);
  }
}
