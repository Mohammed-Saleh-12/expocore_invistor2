import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/booth_management_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/constant/routes.dart';
import '../../../widget/Home/custom_app_bar.dart';
import '../../../widget/Home/custom_button.dart';

class BoothManagementView extends GetView<BoothManagementController> {
  const BoothManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: CustomAppBar(
        title: 'إدارة الجناح ${controller.booth.number}',
        actions: [
          Obx(
            () => controller.isSaving.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.save_rounded, color: Colors.white),
                    tooltip: 'save'.tr,
                    onPressed: controller.saveProfile,
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BoothInfoCard(isDark: isDark),
            const SizedBox(height: 16),
            _BasicInfoCard(isDark: isDark),
            const SizedBox(height: 12),
            _CompanyProfileForm(isDark: isDark),
            const SizedBox(height: 12),
            _SocialLinksSection(isDark: isDark),
            const SizedBox(height: 12),
            _ImagesSection(isDark: isDark),
            const SizedBox(height: 20),
            _SectionHeader(
              icon: Icons.event_rounded,
              title: 'booth_mgmt_events_title'.tr,
              subtitle: 'booth_mgmt_events_subtitle'.tr,
              action: TextButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.CREATE_EVENT),
                icon: const Icon(
                  Icons.add_rounded,
                  size: 16,
                  color: AppColors.darkPrimary,
                ),
                label: Text(
                  'booth_mgmt_add_event'.tr,
                  style: const TextStyle(color: AppColors.darkPrimary, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _BoothEventsList(isDark: isDark),
            const SizedBox(height: 28),
            CustomButton(
              label: 'booth_mgmt_save_btn'.tr,
              onTap: controller.saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: AppColors.darkCTAGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppColors.grey),
              ),
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _BoothInfoCard extends GetView<BoothManagementController> {
  final bool isDark;
  const _BoothInfoCard({required this.isDark});

  Color _statusColor(String s) {
    switch (s) {
      case 'active':
        return AppColors.success;
      case 'pending':
        return AppColors.info;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = controller.booth;
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkCardGradient : null,
        color: isDark ? null : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Image.network(
                  b.imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: AppColors.darkSurface,
                    child: const Icon(
                      Icons.store,
                      size: 48,
                      color: AppColors.grey,
                    ),
                  ),
                ),
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.55),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'جناح ${b.number}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        b.exhibitionName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(b.status).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'booth_mgmt_active'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem(
                  Icons.straighten_rounded,
                  '${b.area.toInt()}م²',
                  'booth_mgmt_area_label'.tr,
                ),
                _divider(),
                _statItem(Icons.location_on_outlined, b.location, 'booth_mgmt_location_label'.tr),
                _divider(),
                _statItem(
                  Icons.monetization_on_outlined,
                  '${b.price.toInt()} ر',
                  'booth_mgmt_price_label'.tr,
                ),
                _divider(),
                _statItem(Icons.calendar_today_outlined, b.endDate, 'booth_mgmt_end_label'.tr),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String val, String label) => Column(
    children: [
      Icon(icon, size: 15, color: AppColors.darkPrimary),
      const SizedBox(height: 3),
      Text(
        val,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        overflow: TextOverflow.ellipsis,
      ),
      Text(label, style: const TextStyle(fontSize: 9, color: AppColors.grey)),
    ],
  );

  Widget _divider() =>
      Container(width: 1, height: 30, color: AppColors.grey.withOpacity(0.2));
}

class _BasicInfoCard extends GetView<BoothManagementController> {
  final bool isDark;
  const _BasicInfoCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkPrimary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkPrimary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.darkCTAGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'شركة التقنية الرائدة',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'investor@leadtech.sa',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompanyProfileForm extends GetView<BoothManagementController> {
  final bool isDark;
  const _CompanyProfileForm({required this.isDark});

  InputDecoration _decoration(
    String label,
    IconData icon,
    bool isDark,
  ) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 18, color: AppColors.darkPrimary),
    filled: true,
    fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.grey.withOpacity(0.25)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
    ),
    labelStyle: const TextStyle(fontSize: 13, color: AppColors.grey),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller.companyNatureCtrl,
          decoration: _decoration(
            'booth_mgmt_company_nature'.tr,
            Icons.category_outlined,
            isDark,
          ),
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller.servicesProductsCtrl,
          decoration: _decoration(
            'booth_mgmt_services_products'.tr,
            Icons.inventory_2_outlined,
            isDark,
          ),
          maxLines: 3,
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller.headquartersCtrl,
          decoration: _decoration(
            'booth_mgmt_headquarters'.tr,
            Icons.location_city_outlined,
            isDark,
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}

class _SocialLinksSection extends GetView<BoothManagementController> {
  final bool isDark;
  const _SocialLinksSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link_rounded, size: 16, color: AppColors.darkPrimary),
              const SizedBox(width: 8),
              Text(
                'booth_mgmt_social_links'.tr,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'booth_mgmt_link_hint'.tr,
            style: const TextStyle(fontSize: 11, color: AppColors.grey),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 6,
              children: controller.profileLinks.map((link) {
                final isAdded = controller.socialLinks.contains(link);
                return GestureDetector(
                  onTap: () => isAdded
                      ? controller.removeSocialLink(link)
                      : controller.addProfileLink(link),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isAdded
                          ? AppColors.darkPrimary.withOpacity(0.12)
                          : (isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isAdded
                            ? AppColors.darkPrimary
                            : AppColors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAdded ? Icons.check_rounded : Icons.add_rounded,
                          size: 12,
                          color: isAdded
                              ? AppColors.darkPrimary
                              : AppColors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _shortLink(link),
                          style: TextStyle(
                            fontSize: 11,
                            color: isAdded
                                ? AppColors.darkPrimary
                                : AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => Column(
              children: controller.socialLinks
                  .where((l) => !controller.profileLinks.contains(l))
                  .map(
                    (l) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.darkPrimary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.link_rounded,
                            size: 13,
                            color: AppColors.darkPrimary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.darkPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.removeSocialLink(l),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.newLinkCtrl,
                  decoration: InputDecoration(
                    hintText: 'booth_mgmt_new_link_hint'.tr,
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(
                      Icons.add_link_rounded,
                      size: 16,
                      color: AppColors.grey,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: controller.addSocialLink,
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    gradient: AppColors.darkCTAGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _shortLink(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }
}

class _ImagesSection extends GetView<BoothManagementController> {
  final bool isDark;
  const _ImagesSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ImageGrid(
          isDark: isDark,
          title: 'booth_mgmt_product_images'.tr,
          icon: Icons.inventory_2_outlined,
          images: controller.productImages,
          onAdd: controller.addProductImage,
        ),
        const SizedBox(height: 12),
        _ImageGrid(
          isDark: isDark,
          title: 'booth_mgmt_booth_images'.tr,
          icon: Icons.photo_library_outlined,
          images: controller.boothImages,
          onAdd: controller.addBoothImage,
        ),
      ],
    );
  }
}

class _ImageGrid extends StatelessWidget {
  final bool isDark;
  final String title;
  final IconData icon;
  final RxList<String> images;
  final VoidCallback onAdd;

  const _ImageGrid({
    required this.isDark,
    required this.title,
    required this.icon,
    required this.images,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.darkPrimary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...images.map(
                    (url) => Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(url),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onAdd,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.darkPrimary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.darkPrimary.withOpacity(0.3),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: AppColors.darkPrimary,
                            size: 24,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'إضافة',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.darkPrimary,
                            ),
                          ),
                        ],
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
}

class _BoothEventsList extends GetView<BoothManagementController> {
  final bool isDark;
  const _BoothEventsList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.boothEvents.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(
                Icons.event_busy_rounded,
                size: 36,
                color: AppColors.grey.withOpacity(0.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'لا توجد فعاليات لهذا المعرض بعد',
                style: TextStyle(color: AppColors.grey, fontSize: 13),
              ),
            ],
          ),
        );
      }
      return Column(
        children: controller.boothEvents
            .map((e) => _EventItem(event: e, isDark: isDark))
            .toList(),
      );
    });
  }
}

class _EventItem extends StatelessWidget {
  final dynamic event;
  final bool isDark;
  const _EventItem({required this.event, required this.isDark});

  Color _statusColor(String s) {
    switch (s) {
      case 'upcoming':
        return AppColors.info;
      case 'active':
        return AppColors.success;
      case 'ended':
        return AppColors.grey;
      default:
        return AppColors.grey;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'upcoming':
        return 'قادمة';
      case 'active':
        return 'جارية';
      case 'ended':
        return 'منتهية';
      default:
        return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.darkPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.event_rounded,
              color: AppColors.darkPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 11,
                      color: AppColors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.access_time_rounded,
                      size: 11,
                      color: AppColors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(event.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _statusLabel(event.status),
                  style: TextStyle(
                    fontSize: 10,
                    color: _statusColor(event.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${event.registeredCount} مسجّل',
                style: const TextStyle(fontSize: 10, color: AppColors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
