import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../../core/services/services.dart';
import '../../linkapi.dart';

class Crud {
  final Dio dio = Dio();

  Map<String, String> get _headers {
    try {
      final token = Get.find<Services>().token;
      if (token.isNotEmpty) {
        return {'Authorization': 'Bearer $token'};
      }
    } catch (_) {}
    return {};
  }

  Future<Map> getData(String url, {Map<String, dynamic>? params}) async {
    try {
      final response = await dio.get(
        url,
        queryParameters: params,
        options: Options(headers: _headers),
      );
      return {'status': true, 'data': response.data};
    } on DioException catch (e) {
      return {'status': false, 'code': e.response?.statusCode ?? 0};
    }
  }

  Future<Map> postData(String url, Map data) async {
    try {
      final response = await dio.post(
        url,
        data: data,
        options: Options(headers: _headers),
      );
      return {'status': true, 'data': response.data};
    } on DioException catch (e) {
      return {'status': false, 'code': e.response?.statusCode ?? 0};
    }
  }

  Future<Map> putData(String url, Map data) async {
    try {
      final response = await dio.put(
        url,
        data: data,
        options: Options(headers: _headers),
      );
      return {'status': true, 'data': response.data};
    } on DioException catch (e) {
      return {'status': false, 'code': e.response?.statusCode ?? 0};
    }
  }

  Future<Map> deleteData(String url) async {
    try {
      final response = await dio.delete(
        url,
        options: Options(headers: _headers),
      );
      return {'status': true, 'data': response.data};
    } on DioException catch (e) {
      return {'status': false, 'code': e.response?.statusCode ?? 0};
    }
  }
}
