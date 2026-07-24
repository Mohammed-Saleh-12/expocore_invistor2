import 'package:expocore_invistor2/controller/Home/messages_controller.dart';
import 'package:expocore_invistor2/view/widget/Home/exhibition_image_gallery.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/constant/routes.dart';
import '../../../../controller/Home/exhibition_detail_controller.dart';
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

    return Scaffold(
      body: Obx(() {
        final exhibition = ctrl.exhibition.value;
        if (exhibition == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.darkPrimary));
        }

        return CustomScrollView(
          slivers: [
            // ── Hero image (أول صورة) ───────────────────────
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      exhibition.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.darkSurface,
                        child: const Icon(Icons.image, size: 64, color: AppColors.grey),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
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
                    // ── Name + status ──────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text(exhibition.name,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _statusColor(exhibition.status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _statusColor(exhibition.status)),
                          ),
                          child: Text(_statusLabel(exhibition.status),
                              style: TextStyle(
                                  color: _statusColor(exhibition.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _infoRow(Icons.calendar_today_outlined,
                        '${exhibition.startDate} — ${exhibition.endDate}'),
                    const SizedBox(height: 6),
                    _infoRow(Icons.location_on_outlined,
                        '${exhibition.location}، ${exhibition.city}'),
                    const SizedBox(height: 16),
                    Text(exhibition.description,
                        style: const TextStyle(fontSize: 14, color: AppColors.grey, height: 1.7)),
                    const SizedBox(height: 16),

                    // ── Sectors ────────────────────────────────
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: exhibition.sectors
                          .map((s) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: AppColors.darkPrimary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(s,
                                    style: const TextStyle(
                                        color: AppColors.darkPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),

                    // ── Available booths ───────────────────────
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
                          Text(
                            '${'exhibition_available_booths_detail'.tr} ${exhibition.availableBooths}',
                            style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Image gallery (شبكة الصور) ─────────────
                    if (exhibition.images.length > 1) ...[
                      ExhibitionImageGallery(images: exhibition.images),
                      const SizedBox(height: 20),
                    ],

                    // ── Tabs ───────────────────────────────────
                    TabBar(
                      controller: ctrl.tabCtrl,
                      tabs: [
                        Tab(text: 'exhibition_tab_details'.tr),
                        Tab(text: 'exhibition_tab_events'.tr),
                      ],
                      labelColor: AppColors.darkPrimary,
                      indicatorColor: AppColors.darkPrimary,
                      unselectedLabelColor: AppColors.grey,
                    ),
                    SizedBox(
                      height: 340,
                      child: TabBarView(
                        controller: ctrl.tabCtrl,
                        children: [
                          _servicesTab(ctrl.services),
                          _eventsTab(context, ctrl.sponsorEvents),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),

                    // ── CTA buttons ────────────────────────────
                    CustomButton(
                      label: 'btn_browse_book_booths'.tr,
                      onTap: () => Get.toNamed(AppRoutes.BOOTH_MAP_3D),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.find<MessagesController>()
                            .openConversationForExhibitionName(exhibition.name),
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                        label: Text('booth_contact_mgmt'.tr,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Color _statusColor(String s) =>
      s == 'active' ? AppColors.success : s == 'upcoming' ? AppColors.info : AppColors.grey;
  String _statusLabel(String s) =>
      s == 'active' ? 'status_ongoing'.tr : s == 'upcoming' ? 'status_upcoming_f'.tr : 'status_ended_f'.tr;

  Widget _infoRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 16, color: AppColors.grey),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
        ],
      );

  // ── Services tab — ديناميكي من الـ API ──────────────────────
  Widget _servicesTab(List<String> services) {
    if (services.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('لا توجد خدمات مُضافة',
              style: TextStyle(color: AppColors.grey, fontSize: 14)),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: services
          .map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        size: 18, color: AppColors.darkPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(s, style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  // ── Events tab — من بيانات المعرض نفسه ──────────────────────
  Widget _eventsTab(BuildContext context, List<ExhibitionSponsorEvent> events) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('no_ad_events'.tr,
              style: const TextStyle(color: AppColors.grey, fontSize: 14),
              textAlign: TextAlign.center),
        ),
      );
    }
    // ignore: deprecated_member_use_from_same_package
    Get.find<ExhibitionDetailController>();
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: events.length,
      itemBuilder: (_, i) {
        final ev = events[i];
        return SponsorEventCard(
          event: ev,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => SponsorshipBottomSheet(event: ev),
            );
          },
          onFavorite: () {},
        );
      },
    );
  }
}
