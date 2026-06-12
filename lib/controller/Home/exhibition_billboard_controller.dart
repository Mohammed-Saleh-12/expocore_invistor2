import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExhibitionBillboardController extends GetxController {
  final pageCtrl = PageController(viewportFraction: 1.0);
  final currentIndex = 0.obs;
  Timer? _timer;
  int _total = 0;

  void init(int total) {
    _total = total;
    _startAuto();
  }

  void _startAuto() {
    _timer?.cancel();
    if (_total < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => next());
  }

  void next() {
    if (_total == 0) return;
    final n = (currentIndex.value + 1) % _total;
    pageCtrl.animateToPage(
      n,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void prev() {
    if (_total == 0) return;
    final p = (currentIndex.value - 1 + _total) % _total;
    pageCtrl.animateToPage(
      p,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void onPageChanged(int index) => currentIndex.value = index;

  @override
  void onClose() {
    _timer?.cancel();
    pageCtrl.dispose();
    super.onClose();
  }
}
