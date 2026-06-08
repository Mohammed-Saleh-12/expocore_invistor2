import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/events_controller.dart';
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
        appBar: CustomAppBar(title: 'فعالياتي'),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
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
                      onTap: () =>
                          Get.toNamed(AppRoutes.MY_EVENT_DETAIL, arguments: ev),
                      showFavorite: false,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
