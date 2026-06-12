import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/booth_detail_controller.dart';
import '../../../../controller/Home/messages_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../widget/Home/favorite_button.dart';

class BoothDetailView extends StatelessWidget {
  const BoothDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BoothDetailController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    ctrl.booth.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.darkSurface,
                      child: const Icon(Icons.store, size: 64, color: AppColors.grey),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
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
                  Row(
                    children: [
                      Text(
                        '${'booth_number'.tr} ${ctrl.booth.number}',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _statusColor(ctrl.booth.status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _statusColor(ctrl.booth.status)),
                        ),
                        child: Text(
                          _statusLabel(ctrl.booth.status),
                          style: TextStyle(color: _statusColor(ctrl.booth.status), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(ctrl.booth.exhibitionName, style: const TextStyle(fontSize: 15, color: AppColors.grey)),
                  const SizedBox(height: 4),
                  _infoGrid(ctrl.booth, context, isDark),
                  const SizedBox(height: 16),
                  Text('booth_amenities'.tr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: ctrl.booth.amenities.map((a) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.darkPink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.darkPink.withOpacity(0.4)),
                      ),
                      child: Text(a, style: const TextStyle(fontSize: 12, color: AppColors.darkPink)),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  _proximityTags(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.find<MessagesController>().openConversationForExhibitionName(ctrl.booth.exhibitionName),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                      label: Text('booth_contact_mgmt'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPrimary, foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String s) => s == 'active' ? AppColors.success : s == 'available' ? AppColors.info : AppColors.grey;

  String _statusLabel(String s) {
    switch (s) {
      case 'active':    return 'status_active'.tr;
      case 'available': return 'status_available'.tr;
      case 'pending':   return 'status_pending'.tr;
      case 'rejected':  return 'status_rejected'.tr;
      case 'ended':     return 'status_ended'.tr;
      default:          return s;
    }
  }

  Widget _infoGrid(booth, BuildContext context, bool isDark) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10, mainAxisSpacing: 10,
        childAspectRatio: 2.5,
        children: [
          _infoTile(Icons.location_on_outlined, 'booth_location'.tr, booth.location, isDark),
          _infoTile(Icons.straighten, 'booth_area'.tr, '${booth.area.toInt()}م²', isDark),
          _infoTile(Icons.monetization_on_outlined, 'booth_price'.tr, '${booth.price.toInt()} ريال', isDark),
          _infoTile(Icons.calendar_today_outlined, 'booth_end_date'.tr, booth.endDate, isDark),
        ],
      );

  Widget _infoTile(IconData icon, String label, String val, bool isDark) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.darkPrimary),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: const TextStyle(fontSize: 10, color: AppColors.grey)),
                  Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _proximityTags() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('booth_proximity'.tr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            children: ['المدخل الرئيسي', 'المسرح', 'منطقة الطعام'].map((t) => Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.4)),
              ),
              child: Text(t, style: const TextStyle(fontSize: 11, color: AppColors.info)),
            )).toList(),
          ),
        ],
      );
}
