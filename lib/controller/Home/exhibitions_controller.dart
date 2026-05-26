import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/exhibition/exhibition_model.dart';
import '../../data/sourcedata/static/exhibitions_dummy.dart';

class ExhibitionsController extends GetxController {
  final searchCtrl    = TextEditingController();
  final exhibitions   = <ExhibitionModel>[].obs;
  final filtered      = <ExhibitionModel>[].obs;
  final statusFilter  = 'الكل'.obs;
  final filters       = ['الكل', 'قادم', 'جارٍ', 'منتهٍ'];
  final isLoading     = false.obs;

  @override
  void onInit() {
    exhibitions.value = DummyData.exhibitions;
    filtered.value    = exhibitions;
    super.onInit();
  }

  void applyFilter(String f) {
    statusFilter.value = f;
    _filterList();
  }

  void onSearch(String q) => _filterList(query: q);

  void _filterList({String? query}) {
    final q = (query ?? searchCtrl.text).toLowerCase();
    filtered.value = exhibitions.where((e) {
      final matchQuery  = q.isEmpty || e.name.contains(q) || e.city.contains(q);
      final matchStatus = statusFilter.value == 'الكل' ||
          (statusFilter.value == 'قادم'  && e.status == 'upcoming') ||
          (statusFilter.value == 'جارٍ'  && e.status == 'active')   ||
          (statusFilter.value == 'منتهٍ' && e.status == 'ended');
      return matchQuery && matchStatus;
    }).toList();
  }

  void toggleFavorite(ExhibitionModel e) {
    e.isFavorite = !e.isFavorite;
    exhibitions.refresh();
    filtered.refresh();
  }

  Future<void> refresh() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    isLoading.value = false;
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }
}
