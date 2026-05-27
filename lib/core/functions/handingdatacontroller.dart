import '../class/StatusRequest.dart';

StatusRequest handlingData(dynamic response) {
  if (response == null) return StatusRequest.serverFailure;
  if (response is Map && response['status'] == 'success') return StatusRequest.success;
  return StatusRequest.serverFailure;
}
