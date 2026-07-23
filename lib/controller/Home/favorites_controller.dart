import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../data/model/exhibition/exhibition_model.dart';
import '../../data/model/booth/booth_model.dart';
import '../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../data/sourcedata/remote/Favorites/FavoritesData.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class FavoritesController extends GetxController {
  final FavoritesData _favoritesData = FavoritesData(Crud());

  final favoriteExhibitions = <ExhibitionModel>[].obs;
  final favoriteEvents      = <ExhibitionSponsorEvent>[].obs;
  final favoriteBooths      = <BoothModel>[].obs;
  final selectedTab         = 0.obs;
  final isLoading           = false.obs;
  final sortBy              = 'تاريخ الإضافة'.obs;
  final sortOptions         = ['تاريخ الإضافة', 'الاسم', 'الحالة'];

  // ── Web filter bar ─────────────────────────────────────────
  static const webFilters = ['معارض', 'فعاليات', 'أجنحة'];
  final webCategoryFilter  = 'معارض'.obs;

  void setWebFilter(String f) => webCategoryFilter.value = f;

  @override
  void onInit() {
    _loadFavorites();
    super.onInit();
  }

  Future<void> _loadFavorites() async {
    isLoading.value = true;
    final result = await _favoritesData.getFavorites();
    if (result['status'] == true) {
      final d = _body(result['data']);
      favoriteExhibitions.value = _asList(d['exhibitions'])
          .map((e) => ExhibitionModel.fromJson(e))
          .toList();
      favoriteBooths.value = _asList(d['booths'])
          .map((e) => BoothModel.fromJson(e))
          .toList();
      favoriteEvents.value = _asList(d['events'])
          .map((e) => ExhibitionSponsorEvent.fromJson(e))
          .toList();
    } else {
      favoriteExhibitions.value =
          DummyData.exhibitions.where((e) => e.isFavorite).toList();
      favoriteEvents.value =
          DummyData.exhibitionSponsorEvents.where((e) => e.isFavorite).toList();
      favoriteBooths.value =
          DummyData.myBooths.where((b) => b.isFavorite).toList();
    }
    isLoading.value = false;
  }

  bool isExhibitionFavorited(int id) =>
      favoriteExhibitions.any((e) => e.id == id);
  bool isEventFavorited(int id) => favoriteEvents.any((e) => e.id == id);
  bool isBoothFavorited(int id) => favoriteBooths.any((b) => b.id == id);

  // ── Toggle: المعارض ───────────────────────────────────────
  void toggleFavoriteExhibition(ExhibitionModel exhibition) {
    if (isExhibitionFavorited(exhibition.id)) {
      removeExhibition(exhibition);
    } else {
      exhibition.isFavorite = true;
      favoriteExhibitions.add(exhibition);
      _favoritesData.addFavorite(exhibition.id, FavoriteType.exhibition);
    }
  }

  // ── Toggle: الفعاليات الإعلانية ───────────────────────────
  void toggleFavoriteEvent(ExhibitionSponsorEvent event) {
    if (isEventFavorited(event.id)) {
      removeEvent(event);
    } else {
      event.isFavorite = true;
      favoriteEvents.add(event);
      _favoritesData.addFavorite(event.id, FavoriteType.event);
    }
  }

  // ── Toggle: الأجنحة ───────────────────────────────────────
  void toggleFavoriteBooth(BoothModel booth) {
    if (isBoothFavorited(booth.id)) {
      removeBooth(booth);
    } else {
      booth.isFavorite = true;
      favoriteBooths.add(booth);
      _favoritesData.addFavorite(booth.id, FavoriteType.booth);
    }
  }

  // ── Remove ────────────────────────────────────────────────
  void removeExhibition(ExhibitionModel e) {
    favoriteExhibitions.remove(e);
    e.isFavorite = false;
    _favoritesData.removeFavorite(e.id, FavoriteType.exhibition);
    Get.snackbar('fav_removed_title'.tr,
        'fav_removed_item_msg'.trParams({'name': e.name}),
        snackPosition: SnackPosition.BOTTOM);
  }

  void removeEvent(ExhibitionSponsorEvent e) {
    favoriteEvents.remove(e);
    e.isFavorite = false;
    _favoritesData.removeFavorite(e.id, FavoriteType.event);
    Get.snackbar('fav_removed_title'.tr,
        'fav_removed_item_msg'.trParams({'name': e.name}),
        snackPosition: SnackPosition.BOTTOM);
  }

  void removeBooth(BoothModel b) {
    final existing = favoriteBooths.firstWhereOrNull((e) => e.id == b.id);
    if (existing != null) {
      favoriteBooths.remove(existing);
      existing.isFavorite = false;
    } else {
      favoriteBooths.removeWhere((e) => e.id == b.id);
    }
    b.isFavorite = false;
    _favoritesData.removeFavorite(b.id, FavoriteType.booth);
    Get.snackbar('fav_removed_title'.tr,
        'fav_removed_booth_msg'.trParams({'number': b.number}),
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> refresh() => _loadFavorites();

  List _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  dynamic _body(dynamic data) =>
      (data is Map && data['data'] is Map) ? data['data'] : (data ?? {});
}