import 'package:get/get.dart';
import '../../data/model/exhibition/exhibition_model.dart';
import '../../data/model/event/event_model.dart';
import '../../data/model/booth/booth_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class FavoritesController extends GetxController {
  final favoriteExhibitions = <ExhibitionModel>[].obs;
  final favoriteEvents      = <EventModel>[].obs;
  final favoriteBooths      = <BoothModel>[].obs;
  final selectedTab         = 0.obs;
  final sortBy              = 'تاريخ الإضافة'.obs;
  final sortOptions         = ['تاريخ الإضافة', 'الاسم', 'الحالة'];

  @override
  void onInit() {
    favoriteExhibitions.value = DummyData.exhibitions.where((e) => e.isFavorite).toList();
    favoriteEvents.value      = DummyData.events.where((e) => e.isFavorite).toList();
    favoriteBooths.value      = DummyData.myBooths.where((b) => b.isFavorite).toList();
    super.onInit();
  }

  bool isExhibitionFavorited(int id) => favoriteExhibitions.any((e) => e.id == id);
  bool isEventFavorited(int id)      => favoriteEvents.any((e) => e.id == id);
  bool isBoothFavorited(int id)      => favoriteBooths.any((b) => b.id == id);

  void toggleFavoriteExhibition(ExhibitionModel exhibition) {
    if (isExhibitionFavorited(exhibition.id)) {
      favoriteExhibitions.removeWhere((e) => e.id == exhibition.id);
      exhibition.isFavorite = false;
    } else {
      favoriteExhibitions.add(exhibition);
      exhibition.isFavorite = true;
    }
  }

  void toggleFavoriteEvent(EventModel event) {
    if (isEventFavorited(event.id)) {
      favoriteEvents.removeWhere((e) => e.id == event.id);
      event.isFavorite = false;
    } else {
      favoriteEvents.add(event);
      event.isFavorite = true;
    }
  }

  void toggleFavoriteBooth(BoothModel booth) {
    if (isBoothFavorited(booth.id)) {
      favoriteBooths.removeWhere((b) => b.id == booth.id);
      booth.isFavorite = false;
    } else {
      favoriteBooths.add(booth);
      booth.isFavorite = true;
    }
  }

  void removeExhibition(ExhibitionModel e) {
    favoriteExhibitions.remove(e);
    e.isFavorite = false;
    Get.snackbar('تمت الإزالة', 'تمت إزالة "${e.name}" من المفضلة', snackPosition: SnackPosition.BOTTOM);
  }

  void removeEvent(EventModel e) {
    favoriteEvents.remove(e);
    e.isFavorite = false;
    Get.snackbar('تمت الإزالة', 'تمت إزالة "${e.name}" من المفضلة', snackPosition: SnackPosition.BOTTOM);
  }

  void removeBooth(BoothModel b) {
    favoriteBooths.remove(b);
    b.isFavorite = false;
    Get.snackbar('تمت الإزالة', 'تمت إزالة "جناح ${b.number}" من المفضلة', snackPosition: SnackPosition.BOTTOM);
  }
}
