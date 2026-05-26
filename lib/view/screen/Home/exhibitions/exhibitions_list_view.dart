import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/exhibitions_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/constant/routes.dart';
import '../../../widget/Home/bottom_nav_custom.dart';
import '../../../widget/Home/exhibition_card.dart';
import '../../../widget/Home/loading_widget.dart';
import '../../../widget/Home/empty_widget.dart';

class ExhibitionsListView extends GetView<ExhibitionsController> {
  const ExhibitionsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المعارض', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBg : AppColors.lightBg,
        elevation: 0,
      ),
      bottomNavigationBar: const BottomNavCustom(),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(children: [
            TextField(
              controller: controller.searchCtrl,
              textDirection: TextDirection.rtl,
              onChanged: controller.onSearch,
              decoration: InputDecoration(
                hintText: 'ابحث عن معرض...',
                prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.lightCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: controller.filters.map((f) {
                final active = controller.statusFilter.value == f;
                return GestureDetector(
                  onTap: () => controller.applyFilter(f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: active ? AppColors.darkCTAGradient : null,
                      color: active ? null : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.lightSurface),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(f, style: TextStyle(fontSize: 12, color: active ? Colors.white : AppColors.grey, fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
                  ),
                );
              }).toList()),
            )),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(child: Obx(() {
          if (controller.isLoading.value) return const LoadingWidget();
          if (controller.filtered.isEmpty) return EmptyWidget(message: 'لا توجد معارض', buttonLabel: 'تحديث', onAction: controller.refresh);
          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView.builder(
              itemCount: controller.filtered.length,
              itemBuilder: (_, i) {
                final e = controller.filtered[i];
                return ExhibitionCard(
                  exhibition: e,
                  onTap: () => Get.toNamed(AppRoutes.EXHIBITION_DETAIL, arguments: e),
                  onFavorite: () => controller.toggleFavorite(e),
                );
              },
            ),
          );
        })),
      ]),
    );
  }
}
