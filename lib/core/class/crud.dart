import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart' hide Response;
import '../../core/services/services.dart';

class Crud {
  final _dio = dio.Dio();

  Map<String, String> get _authHeader {
    try {
      final token = Get.find<Services>().token;
      if (token.isNotEmpty) return {'Authorization': 'Bearer $token'};
    } catch (_) {}
    return {};
  }

  dio.Options get _opts => dio.Options(headers: {
    ..._authHeader,
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  });

  dio.Options get _uploadOpts => dio.Options(headers: _authHeader);

  // ── GET ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getData(
    String url, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final res = await _dio.get(url, queryParameters: params, options: _opts);
      return {'status': true, 'data': res.data};
    } on dio.DioException catch (e) {
      return _err(e);
    } catch (e) {
      return {'status': false, 'code': 0, 'message': e.toString()};
    }
  }

  // ── POST ───────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> postData(
    String url,
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await _dio.post(url, data: data, options: _opts);
      return {'status': true, 'data': res.data};
    } on dio.DioException catch (e) {
      return _err(e);
    } catch (e) {
      return {'status': false, 'code': 0, 'message': e.toString()};
    }
  }

  // ── PUT ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> putData(
    String url,
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await _dio.put(url, data: data, options: _opts);
      return {'status': true, 'data': res.data};
    } on dio.DioException catch (e) {
      return _err(e);
    } catch (e) {
      return {'status': false, 'code': 0, 'message': e.toString()};
    }
  }

  // ── PATCH ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> patchData(
    String url,
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await _dio.patch(url, data: data, options: _opts);
      return {'status': true, 'data': res.data};
    } on dio.DioException catch (e) {
      return _err(e);
    } catch (e) {
      return {'status': false, 'code': 0, 'message': e.toString()};
    }
  }

  // ── DELETE ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> deleteData(String url) async {
    try {
      final res = await _dio.delete(url, options: _opts);
      return {'status': true, 'data': res.data};
    } on dio.DioException catch (e) {
      return _err(e);
    } catch (e) {
      return {'status': false, 'code': 0, 'message': e.toString()};
    }
  }

  // ── MULTIPART UPLOAD ───────────────────────────────────────────────
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
      final res = await _dio.post(url, data: form, options: _uploadOpts);
      return {'status': true, 'data': res.data};
    } on dio.DioException catch (e) {
      return _err(e);
    } catch (e) {
      return {'status': false, 'code': 0, 'message': e.toString()};
    }
  }

  // ── Error helper ───────────────────────────────────────────────────
  Map<String, dynamic> _err(dio.DioException e) {
    String msg = 'حدث خطأ في الاتصال';
    try {
      final d = e.response?.data;
      if (d is Map) msg = d['message']?.toString() ?? msg;
    } catch (_) {}
    return {
      'status': false,
      'code': e.response?.statusCode ?? 0,
      'message': msg,
    };
  }
}
