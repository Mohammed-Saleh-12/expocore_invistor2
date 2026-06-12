import 'package:expocore_invistor2/controller/Home/messages_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/constant/routes.dart';
import '../../../../controller/Home/events_controller.dart';
import '../../../../controller/Home/exhibition_detail_controller.dart';
import '../../../../data/model/exhibition/exhibition_model.dart';
import '../../../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../../widget/Home/favorite_button.dart';
import '../../../widget/Home/custom_button.dart';
import '../../../widget/Home/sponsor_event_card.dart';
import '../../../widget/Home/sponsorship_bottom_sheet.dart';

class ExhibitionDetailView extends StatelessWidget {
  const ExhibitionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ExhibitionDetailController>();
    final eventsCtrl = Get.find<EventsController>();
    final exhibition = ctrl.exhibition;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(exhibition.imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppColors.darkSurface, child: const Icon(Icons.image, size: 64, color: AppColors.grey))),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12, left: 12,
                    child: SafeArea(
                      child: Obx(() => FavoriteButton(
                            isFavorite: ctrl.isFavorite.value,
                            onTap: ctrl.toggleFavorite,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: Get.back,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(exhibition.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _statusColor(exhibition.status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _statusColor(exhibition.status)),
                        ),
                        child: Text(_statusLabel(exhibition.status),
                            style: TextStyle(color: _statusColor(exhibition.status), fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _infoRow(Icons.calendar_today_outlined, '${exhibition.startDate} — ${exhibition.endDate}'),
                  const SizedBox(height: 6),
                  _infoRow(Icons.location_on_outlined, '${exhibition.location}، ${exhibition.city}'),
                  const SizedBox(height: 16),
                  Text(exhibition.description, style: const TextStyle(fontSize: 14, color: AppColors.grey, height: 1.7)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: exhibition.sectors.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.darkPrimary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text(s, style: const TextStyle(color: AppColors.darkPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.grid_view, color: AppColors.success, size: 22),
                        const SizedBox(width: 10),
                        Text('${exhibition.availableBooths} جناح متاح للحجز',
                            style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 15)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TabBar(
                    controller: ctrl.tabCtrl,
                    tabs: const [Tab(text: 'تفاصيل المعرض'), Tab(text: 'فعاليات المعرض')],
                    labelColor: AppColors.darkPrimary,
                    indicatorColor: AppColors.darkPrimary,
                    unselectedLabelColor: AppColors.grey,
                  ),
                  SizedBox(
                    height: 340,
                    child: TabBarView(
                      controller: ctrl.tabCtrl,
                      children: [_servicesTab(), _eventsTab(context, eventsCtrl, exhibition)],
                    ),
                  ),
                  const SizedBox(height: 50),
                  CustomButton(label: 'استعراض الأجنحة وحجز', onTap: () => Get.toNamed(AppRoutes.BOOTH_MAP_3D)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.find<MessagesController>().openConversationForExhibitionName(exhibition.name),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                      label: Text('booth_contact_mgmt'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPrimary, foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String s) => s == 'active' ? AppColors.success : s == 'upcoming' ? AppColors.info : AppColors.grey;
  String _statusLabel(String s) => s == 'active' ? 'جارٍ' : s == 'upcoming' ? 'قادم' : 'منته';

  Widget _infoRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 16, color: AppColors.grey),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
        ],
      );

  Widget _servicesTab() => ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _serviceItem(Icons.wifi, 'واي فاي مجاني'),
          _serviceItem(Icons.local_parking, 'موقف سيارات مجاني'),
          _serviceItem(Icons.security, 'أمن وحراسة على مدار الساعة'),
          _serviceItem(Icons.restaurant, 'منطقة طعام ومقاهي'),
          _serviceItem(Icons.settings_input_component, 'دعم تقني وكهربائي'),
          _serviceItem(Icons.person, 'استقبال وخدمة عملاء'),
        ],
      );

  Widget _serviceItem(IconData icon, String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [Icon(icon, size: 18, color: AppColors.darkPrimary), const SizedBox(width: 10), Text(label, style: const TextStyle(fontSize: 13))],
        ),
      );

  Widget _eventsTab(BuildContext context, EventsController eventsCtrl, ExhibitionModel exhibition) {
    final events = eventsCtrl.exhibitionSponsorEvents.where((e) => e.exhibitionId == exhibition.id).toList();
    if (events.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('لا توجد فعاليات إعلانية لهذا المعرض حالياً', style: TextStyle(color: AppColors.grey, fontSize: 14), textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: events.length,
      itemBuilder: (_, i) {
        final ev = events[i];
        return SponsorEventCard(
          event: ev,
          onTap: () {
            eventsCtrl.selectedSponsorDuration.value = null;
            showModalBottomSheet(
              context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
              builder: (_) => SponsorshipBottomSheet(event: ev),
            );
          },
          onFavorite: () => eventsCtrl.toggleSponsorFavorite(ev),
        );
      },
    );
  }
}
