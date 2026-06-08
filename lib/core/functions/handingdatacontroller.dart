import '../class/StatusRequest.dart';

// ════════════════════════════════════════════════════════════
//  handlingData  —  maps API result map → StatusRequest
// ════════════════════════════════════════════════════════════
StatusRequest handlingData(dynamic response) {
  if (response == null) return StatusRequest.serverFailure;
  if (response is! Map)  return StatusRequest.serverFailure;

  final status = response['status'];
  final code   = response['code'] as int? ?? 0;

  // network/timeout failures
  if (code == 0 && status != true) return StatusRequest.offlineFailure;

  // server errors
  if (code >= 500) return StatusRequest.serverFailure;

  // unauthorised — handled by _AuthInterceptor but kept as safety
  if (code == 401) return StatusRequest.failure;

  if (status == true) return StatusRequest.success;

  return StatusRequest.failure;
}

// ── Convenience: extract body from nested response ─────────
dynamic extractBody(dynamic response) {
  if (response is! Map) return null;
  final data = response['data'];
  if (data is Map && data.containsKey('data')) return data['data'];
  return data;
}

// ── Convenience: extract list from response ────────────────
List<dynamic> extractList(dynamic response) {
  final body = extractBody(response);
  if (body is List) return body;
  if (body is Map && body['data'] is List) return body['data'] as List;
  return [];
}
