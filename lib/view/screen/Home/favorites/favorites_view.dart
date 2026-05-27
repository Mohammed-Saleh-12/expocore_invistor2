import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/favorites_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/constant/routes.dart';
import '../../../widget/Home/bottom_nav_custom.dart';
import '../../../widget/Home/exhibition_card.dart';
import '../../../widget/Home/event_card.dart';
import '../../../widget/Home/booth_card.dart';
import '../../../widget/Home/empty_widget.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FavoritesController());
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8),
              const Text(
                'مفضلاتي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBg
              : AppColors.lightBg,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: Obx(
              () => TabBar(
                onTap: (i) => controller.selectedTab.value = i,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.store_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'المعارض (${controller.favoriteExhibitions.length})',
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text('الفعاليات (${controller.favoriteEvents.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.grid_view_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text('الأجنحة (${controller.favoriteBooths.length})'),
                      ],
                    ),
                  ),
                ],
                labelColor: AppColors.darkPrimary,
                indicatorColor: AppColors.darkPrimary,
                unselectedLabelColor: AppColors.grey,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavCustom(),
        body: TabBarView(
          children: [_exhibitionsTab(), _eventsTab(), _boothsTab()],
        ),
      ),
    );
  }

  Widget _exhibitionsTab() => Obx(() {
    if (controller.favoriteExhibitions.isEmpty) {
      return EmptyWidget(
        message: 'لم تضف أي معارض للمفضلة بعد',
        buttonLabel: 'تصفح المعارض',
        onAction: () => Get.toNamed(AppRoutes.EXHIBITIONS),
      );
    }
    return ListView.builder(
      itemCount: controller.favoriteExhibitions.length,
      itemBuilder: (_, i) {
        final e = controller.favoriteExhibitions[i];
        return Dismissible(
          key: Key('fav_ex_${e.id}'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => controller.removeExhibition(e),
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 28,
            ),
          ),
          child: ExhibitionCard(
            exhibition: e,
            onTap: () => Get.toNamed(AppRoutes.EXHIBITION_DETAIL, arguments: e),
            onFavorite: () => controller.removeExhibition(e),
          ),
        );
      },
    );
  });

  Widget _eventsTab() => Obx(() {
    if (controller.favoriteEvents.isEmpty) {
      return EmptyWidget(
        message: 'لم تضف أي فعاليات للمفضلة بعد',
        buttonLabel: 'تصفح الفعاليات',
        onAction: () => Get.toNamed(AppRoutes.EVENTS),
      );
    }
    return ListView.builder(
      itemCount: controller.favoriteEvents.length,
      itemBuilder: (_, i) {
        final e = controller.favoriteEvents[i];
        return Dismissible(
          key: Key('fav_ev_${e.id}'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => controller.removeEvent(e),
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 28,
            ),
          ),
          child: EventCard(
            event: e,
            onTap: () {},
            showFavorite: true,
            onFavorite: () => controller.removeEvent(e),
          ),
        );
      },
    );
  });

  Widget _boothsTab() => Obx(() {
    if (controller.favoriteBooths.isEmpty) {
      return EmptyWidget(
        message: 'لم تضف أي أجنحة للمفضلة بعد',
        buttonLabel: 'تصفح الأجنحة',
        onAction: () => Get.toNamed(AppRoutes.BOOTHS),
      );
    }
    return ListView.builder(
      itemCount: controller.favoriteBooths.length,
      itemBuilder: (_, i) {
        final b = controller.favoriteBooths[i];
        return Dismissible(
          key: Key('fav_bo_${b.id}'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => controller.removeBooth(b),
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 28,
            ),
          ),
          child: BoothCard(
            booth: b,
            onTap: () => Get.toNamed(AppRoutes.BOOTH_DETAIL, arguments: b),
            onFavorite: () => controller.removeBooth(b),
            onReport: () => Get.toNamed(AppRoutes.REPORTS),
          ),
        );
      },
    );
  });
}
