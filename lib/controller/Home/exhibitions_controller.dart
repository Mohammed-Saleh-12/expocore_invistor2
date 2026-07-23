import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../data/model/exhibition/exhibition_model.dart';
import '../../data/sourcedata/remote/Exhibitions/ExhibitionsData.dart';
import '../../data/sourcedata/remote/Favorites/FavoritesData.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class ExhibitionsController extends GetxController {
  final ExhibitionsData _exhibitionsData = ExhibitionsData(Crud());
  final FavoritesData   _favoritesData   = FavoritesData(Crud());

  final searchCtrl  = TextEditingController();
  final exhibitions = <ExhibitionModel>[].obs;
  final filtered    = <ExhibitionModel>[].obs;
  final isLoading   = false.obs;
  final isLoadingMore = false.obs;

  // ── Pagination ────────────────────────────────────────────
  int  _currentPage = 1;
  int  _totalPages  = 1;
  static const int _perPage = 15;
  bool get hasMore => _currentPage < _totalPages;

  // ── Filters ───────────────────────────────────────────────
  final statusFilter = 'الكل'.obs;
  final sectorFilter = 'الكل'.obs;
  final cityFilter   = 'الكل'.obs;

  final filters = ['الكل', 'قادم', 'جارٍ', 'منتهٍ'];

  // status to API param
  static const _statusApi = {
    'قادم': 'upcoming',
    'جارٍ': 'active',
    'منتهٍ': 'ended',
  };

  @override
  void onInit() {
    _loadExhibitions(reset: true);
    super.onInit();
  }

  Future<void> _loadExhibitions({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      exhibitions.clear();
    }
    isLoading.value = true;
    final result = await _exhibitionsData.getExhibitions(
      page:    _currentPage,
      perPage: _perPage,
      status:  _statusApi[statusFilter.value],
      city:    cityFilter.value == 'الكل' ? null : cityFilter.value,
      sector:  sectorFilter.value == 'الكل' ? null : sectorFilter.value,
    );
    if (result['status'] == true) {
      final body = _body(result['data']);
      final list = _asList(body['data'] ?? body);
      final items = list.map((e) => ExhibitionModel.fromJson(e)).toList();
      if (reset) {
        exhibitions.value = items;
      } else {
        exhibitions.addAll(items);
      }
      // pagination meta
      final meta = body['meta'] ?? body['pagination'] ?? {};
      _totalPages = meta['last_page'] ?? meta['total_pages'] ?? 1;
    } else {
      if (reset) exhibitions.value = DummyData.exhibitions;
    }
    _applyLocalFilter();
    isLoading.value = false;
  }

  /// تحميل الصفحة التالية (لا تُعيد التحميل من الأول)
  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore.value) return;
    isLoadingMore.value = true;
    _currentPage++;
    await _loadExhibitions(reset: false);
    isLoadingMore.value = false;
  }

  // ── Dynamic filter options (extracted from loaded data) ───
  List<String> get availableCities {
    final set = exhibitions.map((e) => e.city).where((c) => c.isNotEmpty).toSet();
    return ['الكل', ...set];
  }

  List<String> get availableSectors {
    final set = <String>{};
    for (final e in exhibitions) { set.addAll(e.sectors); }
    return ['الكل', ...set];
  }

  int get activeFilterCount {
    var n = 0;
    if (statusFilter.value != 'الكل') n++;
    if (sectorFilter.value != 'الكل') n++;
    if (cityFilter.value   != 'الكل') n++;
    return n;
  }

  // ── Filter actions ─────────────────────────────────────────
  void applyFilter(String f) {
    statusFilter.value = f;
    _loadExhibitions(reset: true);
  }

  void setSector(String s) {
    sectorFilter.value = s;
    _loadExhibitions(reset: true);
  }

  void setCity(String c) {
    cityFilter.value = c;
    _loadExhibitions(reset: true);
  }

  void clearFilters() {
    statusFilter.value = 'الكل';
    sectorFilter.value = 'الكل';
    cityFilter.value   = 'الكل';
    _loadExhibitions(reset: true);
  }

  void onSearch(String q) => _applyLocalFilter(query: q);

  void _applyLocalFilter({String? query}) {
    final q = (query ?? searchCtrl.text).toLowerCase();
    filtered.value = exhibitions.where((e) {
      final matchQuery = q.isEmpty ||
          e.name.toLowerCase().contains(q) ||
          e.city.toLowerCase().contains(q);
      return matchQuery;
    }).toList();
  }

  // ── Favorite toggle (unified API) ─────────────────────────
  void toggleFavorite(ExhibitionModel e) {
    final wasFav = e.isFavorite;
    e.isFavorite = !wasFav;
    exhibitions.refresh();
    filtered.refresh();
    if (wasFav) {
      _favoritesData.removeFavorite(e.id, FavoriteType.exhibition);
    } else {
      _favoritesData.addFavorite(e.id, FavoriteType.exhibition);
    }
  }

  Future<void> refresh() => _loadExhibitions(reset: true);

  List _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['data']         is List) return data['data'];
      if (data['exhibitions']  is List) return data['exhibitions'];
    }
    return [];
  }

  dynamic _body(dynamic data) =>
      (data is Map && data['data'] is Map) ? data['data'] : (data ?? {});

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }
}