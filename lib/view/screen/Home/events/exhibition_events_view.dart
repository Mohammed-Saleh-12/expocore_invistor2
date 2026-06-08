import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/events_controller.dart';
import '../../../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../../widget/Home/custom_app_bar.dart';
import '../../../widget/Home/empty_widget.dart';
import '../../../widget/Home/sponsor_event_card.dart';
import '../../../widget/Home/sponsorship_bottom_sheet.dart';

class ExhibitionEventsView extends GetView<EventsController> {
  const ExhibitionEventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'فعاليات المعارض الإعلانية'),
      body: Obx(() {
        if (controller.exhibitionSponsorEvents.isEmpty) {
          return const EmptyWidget(
              message: 'لا توجد فعاليات إعلانية متاحة حالياً');
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
      }),
    );
  }

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
