import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../data/model/exhibition/exhibition_model.dart';
import '../../data/sourcedata/remote/Dashboard/latest_exhibitions_data.dart';

/// يدير جلب أحدث المعارض لقسم "أحدث المعارض" في الصفحة الرئيسية (ويب)
/// لا يدعم Pagination — يجلب القائمة الكاملة في طلب واحد عند onInit
class LatestExhibitionsController extends GetxController {
  final LatestExhibitionsData _data = LatestExhibitionsData(Crud());

  // ── الحالة ───────────────────────────────────────────────────────────────
  final exhibitions = <ExhibitionModel>[].obs;
  final isLoading   = false.obs;

  @override
  void onInit() {
    fetchLatestExhibitions();
    super.onInit();
  }

  // ════════════════════════════════════════════════════════════════════════
  //  جلب أحدث المعارض
  // ════════════════════════════════════════════════════════════════════════
  Future<void> fetchLatestExhibitions() async {
    isLoading.value = true;

    final result = await _data.getLatestExhibitions();

    if (result['status'] == true) {
      final body = result['data'];
      final list = _asList(body);
      exhibitions.value = list.map((e) => ExhibitionModel.fromJson(e)).toList();
    }

    isLoading.value = false;
  }

  // ── مساعد ────────────────────────────────────────────────────────────────
  List<dynamic> _asList(dynamic d) {
    if (d is List) return d;
    if (d is Map && d['data'] is List) return d['data'] as List;
    return [];
  }
}
