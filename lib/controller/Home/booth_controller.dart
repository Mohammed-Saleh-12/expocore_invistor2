import 'package:get/get.dart';
import '../../data/model/booth/booth_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class BoothController extends GetxController {
  final booths       = <BoothModel>[].obs;
  final filtered     = <BoothModel>[].obs;
  final statusFilter = 'الكل'.obs;
  final filters      = ['الكل', 'نشطة', 'قيد المراجعة', 'مرفوضة', 'منتهية'];

  @override
  void onInit() {
    booths.value   = DummyData.myBooths;
    filtered.value = booths;
    super.onInit();
  }

  void applyFilter(String f) {
    statusFilter.value = f;
    if (f == 'الكل') {
      filtered.value = booths;
    } else {
      final map = {'نشطة': 'active', 'قيد المراجعة': 'pending', 'مرفوضة': 'rejected', 'منتهية': 'ended'};
      filtered.value = booths.where((b) => b.status == map[f]).toList();
    }
  }

  void toggleFavorite(BoothModel b) {
    b.isFavorite = !b.isFavorite;
    booths.refresh();
    filtered.refresh();
  }
}
