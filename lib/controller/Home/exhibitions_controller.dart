import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../data/model/exhibition/exhibition_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';
import '../../linkapi.dart';

class ExhibitionsController extends GetxController {
  final _crud       = Crud();
  final searchCtrl  = TextEditingController();
  final exhibitions = <ExhibitionModel>[].obs;
  final filtered    = <ExhibitionModel>[].obs;
  final isLoading   = false.obs;

  // ── Filters ──────────────────────────────────────────────
  final statusFilter = 'الكل'.obs;
  final sectorFilter = 'الكل'.obs;
  final cityFilter   = 'الكل'.obs;

  final filters = ['الكل', 'قادم', 'جارٍ', 'منتهٍ'];

  @override
  void onInit() {
    _loadExhibitions();
    super.onInit();
  }

  Future<void> _loadExhibitions() async {
    isLoading.value = true;
    final result = await _crud.getData(AppLink.exhibitions);
    if (result['status'] == true) {
      final list = _asList(result['data']);
      exhibitions.value = list.map((e) => ExhibitionModel.fromJson(e)).toList();
    } else {
      exhibitions.value = DummyData.exhibitions;
    }
    filtered.value = exhibitions;
    isLoading.value = false;
  }

  // ── Dynamic filter options (extracted from data) ──────────
  List<String> get availableCities {
    final set = exhibitions.map((e) => e.city).where((c) => c.isNotEmpty).toSet();
    return ['الكل', ...set];
  }

  List<String> get availableSectors {
    final set = <String>{};
    for (final e in exhibitions) {
      set.addAll(e.sectors);
    }
    return ['الكل', ...set];
  }

  // ── Active filter count (for badge) ───────────────────────
  int get activeFilterCount {
    var n = 0;
    if (statusFilter.value != 'الكل') n++;
    if (sectorFilter.value != 'الكل') n++;
    if (cityFilter.value   != 'الكل') n++;
    return n;
  }

  // ── Filter actions ────────────────────────────────────────
  void applyFilter(String f) {
    statusFilter.value = f;
    _filterList();
  }

  void setSector(String s) {
    sectorFilter.value = s;
    _filterList();
  }

  void setCity(String c) {
    cityFilter.value = c;
    _filterList();
  }

  void clearFilters() {
    statusFilter.value = 'الكل';
    sectorFilter.value = 'الكل';
    cityFilter.value   = 'الكل';
    _filterList();
  }

  void onSearch(String q) => _filterList(query: q);

  void _filterList({String? query}) {
    final q = (query ?? searchCtrl.text).toLowerCase();
    filtered.value = exhibitions.where((e) {
      final matchQuery = q.isEmpty ||
          e.name.toLowerCase().contains(q) ||
          e.city.toLowerCase().contains(q);

      final matchStatus = statusFilter.value == 'الكل' ||
          (statusFilter.value == 'قادم'  && e.status == 'upcoming') ||
          (statusFilter.value == 'جارٍ'  && e.status == 'active')   ||
          (statusFilter.value == 'منتهٍ' && e.status == 'ended');

      final matchCity = cityFilter.value == 'الكل' || e.city == cityFilter.value;

      final matchSector = sectorFilter.value == 'الكل' ||
          e.sectors.contains(sectorFilter.value);

      return matchQuery && matchStatus && matchCity && matchSector;
    }).toList();
  }

  void toggleFavorite(ExhibitionModel e) {
    final wasFav = e.isFavorite;
    e.isFavorite = !wasFav;
    exhibitions.refresh();
    filtered.refresh();
    if (wasFav) {
      _crud.deleteData(AppLink.favoriteExhibition(e.id));
    } else {
      _crud.postData(AppLink.favoriteExhibition(e.id), {});
    }
  }

  Future<void> refresh() => _loadExhibitions();

  List _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['data'] is List) return data['data'];
      if (data['exhibitions'] is List) return data['exhibitions'];
    }
    return [];
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }
}
