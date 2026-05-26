import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/events_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/constant/routes.dart';
import '../../../widget/Home/event_card.dart';
import '../../../widget/Home/empty_widget.dart';
import '../../../widget/Home/custom_app_bar.dart';

class EventsView extends GetView<EventsController> {
  const EventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(title: 'الفعاليات', showBack: false, actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.darkPrimary), onPressed: () => Get.toNamed(AppRoutes.CREATE_EVENT)),
        ]),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(AppRoutes.CREATE_EVENT),
          backgroundColor: AppColors.darkPrimary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('إنشاء فعالية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        body: Column(children: [
          const TabBar(
            tabs: [Tab(text: 'فعالياتي'), Tab(text: 'فعاليات المعرض')],
            labelColor: AppColors.darkPrimary,
            indicatorColor: AppColors.darkPrimary,
            unselectedLabelColor: AppColors.grey,
          ),
          Expanded(
            child: TabBarView(children: [
              _myEventsTab(),
              _exhibitionEventsTab(),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _myEventsTab() => Obx(() {
    if (controller.myEvents.isEmpty) return EmptyWidget(message: 'لم تنشئ أي فعاليات بعد', buttonLabel: 'إنشاء فعالية', onAction: () => Get.toNamed(AppRoutes.CREATE_EVENT));
    return ListView.builder(
      itemCount: controller.myEvents.length,
      itemBuilder: (_, i) => EventCard(event: controller.myEvents[i], onTap: () {}, showFavorite: false),
    );
  });

  Widget _exhibitionEventsTab() => Obx(() {
    if (controller.exhibitionEvents.isEmpty) return const EmptyWidget(message: 'لا توجد فعاليات');
    return ListView.builder(
      itemCount: controller.exhibitionEvents.length,
      itemBuilder: (_, i) => EventCard(
        event: controller.exhibitionEvents[i],
        onTap: () {},
        showFavorite: true,
        onFavorite: () => controller.toggleFavorite(controller.exhibitionEvents[i]),
      ),
    );
  });
}
