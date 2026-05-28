import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/events_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/constant/routes.dart';
import '../../../widget/Home/event_card.dart';
import '../../../widget/Home/empty_widget.dart';
import '../../../widget/Home/custom_app_bar.dart';
import '../../../widget/Home/sponsor_event_card.dart';
import '../../../widget/Home/sponsorship_bottom_sheet.dart';
import '../../../../data/model/event/exhibition_sponsor_event_model.dart';

class EventsView extends GetView<EventsController> {
  const EventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'الفعاليات',
          showBack: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  color: AppColors.darkPrimary),
              onPressed: () => Get.toNamed(AppRoutes.CREATE_EVENT),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(AppRoutes.CREATE_EVENT),
          backgroundColor: AppColors.darkPrimary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('نشر فعالية',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        body: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'فعالياتي'),
                Tab(text: 'فعاليات المعارض'),
              ],
              labelColor: AppColors.darkPrimary,
              indicatorColor: AppColors.darkPrimary,
              unselectedLabelColor: AppColors.grey,
            ),
            Expanded(
              child: TabBarView(
                children: [_myEventsTab(), _exhibitionEventsTab(context)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _myEventsTab() => Obx(() {
        if (controller.myEvents.isEmpty) {
          return EmptyWidget(
            message: 'لم تنشئ أي فعاليات بعد',
            buttonLabel: 'نشر فعالية',
            onAction: () => Get.toNamed(AppRoutes.CREATE_EVENT),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: controller.myEvents.length,
          itemBuilder: (_, i) {
            final ev = controller.myEvents[i];
            return EventCard(
              event: ev,
              onTap: () => Get.toNamed(
                AppRoutes.MY_EVENT_DETAIL,
                arguments: ev,
              ),
              showFavorite: false,
            );
          },
        );
      });

  Widget _exhibitionEventsTab(BuildContext context) => Obx(() {
        if (controller.exhibitionSponsorEvents.isEmpty) {
          return EmptyWidget(
            message: 'لا توجد فعاليات إعلانية متاحة',
            buttonLabel: 'تحديث',
            onAction: () {},
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: controller.exhibitionSponsorEvents.length,
          itemBuilder: (_, i) {
            final ev = controller.exhibitionSponsorEvents[i];
            return SponsorEventCard(
              event: ev,
              onTap: () => _showSheet(context, ev),
              onFavorite: () => controller.toggleSponsorFavorite(ev),
            );
          },
        );
      });

  void _showSheet(BuildContext context, ExhibitionSponsorEvent event) {
    controller.selectedSponsorDuration.value = null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SponsorshipBottomSheet(event: event),
    );
  }
}
