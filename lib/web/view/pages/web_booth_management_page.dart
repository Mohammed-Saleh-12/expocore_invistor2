import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controller/Home/booth_management_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/booth/booth_model.dart';
import '../../controllers/web_nav_controller.dart';
import '../../models/web_theme.dart';
import '../widgets/web_status_chip.dart';

class WebBoothManagementPage extends StatelessWidget {
  const WebBoothManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BoothManagementController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _backBar(),
              const SizedBox(height: 20),
              _titleRow(c),
              const SizedBox(height: 20),
              _BoothHeaderCard(booth: c.booth),
              const SizedBox(height: 20),
              _CompanyFormCard(c: c),
              const SizedBox(height: 16),
              _SocialLinksCard(c: c),
              const SizedBox(height: 16),
              _ImagesCard(
                title: 'صور منتجات الشركة',
                icon: Icons.inventory_2_outlined,
                images: c.productImages,
                imageFiles: c.productImageFiles,
                onAdd: c.addProductImage,
                onRemoveUrl: c.removeProductImage,
                onRemoveFile: c.removeProductImageFile,
              ),
              const SizedBox(height: 16),
              _ImagesCard(
                title: 'صور المشاركة في المعرض',
                icon: Icons.photo_library_outlined,
                images: c.boothImages,
                imageFiles: c.boothImageFiles,
                onAdd: c.addBoothImage,
                onRemoveUrl: c.removeBoothImage,
                onRemoveFile: c.removeBoothImageFile,
              ),
              const SizedBox(height: 16),
              _BoothEventsCard(c: c),
              const SizedBox(height: 28),
              _saveButton(c),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backBar() => GestureDetector(
    onTap: WebNavController.to.closeDetail,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: WebTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: WebTheme.border),
          ),
          child: Icon(
            Icons.arrow_forward_rounded,
            color: WebTheme.text,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text('رجوع', style: TextStyle(color: AppColors.grey, fontSize: 14)),
      ],
    ),
  );

  Widget _titleRow(BoothManagementController c) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إدارة الجناح ${c.booth.number}',
              style: TextStyle(
                color: WebTheme.text,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              c.booth.exhibitionName,
              style: TextStyle(color: AppColors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
      WebStatusChip(status: c.booth.status),
      const SizedBox(width: 12),
      Obx(
        () => GestureDetector(
          onTap: c.saveProfile,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: c.isSaving.value ? null : AppColors.favoriteGradient,
              color: c.isSaving.value ? AppColors.grey.withOpacity(0.3) : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: c.isSaving.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    children: [
                      Icon(Icons.save_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'حفظ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ],
  );

  Widget _saveButton(BoothManagementController c) => GestureDetector(
    onTap: c.saveProfile,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: AppColors.favoriteGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: const Text(
        'حفظ معلومات الشركة',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

// ── Booth header card ────────────────────────────────────────
class _BoothHeaderCard extends StatelessWidget {
  final BoothModel booth;
  const _BoothHeaderCard({required this.booth});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WebTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WebTheme.border),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                Image.network(
                  booth.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagePlaceholder(),
                ),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.65),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'جناح ${booth.number}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        booth.exhibitionName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat(
                  Icons.straighten_rounded,
                  '${booth.area.toInt()} م²',
                  'المساحة',
                ),
                _divider(),
                _stat(Icons.location_on_outlined, booth.location, 'الموقع'),
                _divider(),
                _stat(
                  Icons.monetization_on_outlined,
                  '${booth.price.toInt()} ر.س',
                  'السعر',
                ),
                _divider(),
                _stat(Icons.calendar_today_outlined, booth.endDate, 'الانتهاء'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String val, String label) => Column(
    children: [
      Icon(icon, size: 16, color: WebTheme.primary),
      const SizedBox(height: 4),
      Text(
        val,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: WebTheme.text,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.grey)),
    ],
  );

  Widget _divider() =>
      Container(width: 1, height: 32, color: AppColors.grey.withOpacity(0.2));
  Widget _imagePlaceholder() => Container(
    height: 180,
    width: double.infinity,
    color: WebTheme.surfaceAlt,
    child: Icon(Icons.image, size: 48, color: AppColors.grey.withOpacity(0.4)),
  );
}

// ── Company profile form card ────────────────────────────────
class _CompanyFormCard extends StatelessWidget {
  final BoothManagementController c;
  const _CompanyFormCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return _WebCard(
      icon: Icons.business_rounded,
      title: 'معلومات الشركة',
      subtitle: 'بيانات شركتك في هذا الجناح',
      child: LayoutBuilder(
        builder: (_, cons) {
          final isWide = cons.maxWidth > 500;
          final fields = [
            _field(
              c.companyNatureCtrl,
              'طبيعة الشركة',
              Icons.category_outlined,
            ),
            _field(
              c.headquartersCtrl,
              'عنوان المقر الرئيسي',
              Icons.location_city_outlined,
            ),
          ];
          return Column(
            children: [
              if (isWide)
                Row(
                  children: [
                    Expanded(child: fields[0]),
                    const SizedBox(width: 14),
                    Expanded(child: fields[1]),
                  ],
                )
              else ...[
                fields[0],
                const SizedBox(height: 12),
                fields[1],
              ],
              const SizedBox(height: 12),
              _field(
                c.servicesProductsCtrl,
                'الخدمات والمنتجات المقدمة',
                Icons.inventory_2_outlined,
                maxLines: 3,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) => TextField(
    controller: ctrl,
    maxLines: maxLines,
    style: TextStyle(fontSize: 13, color: WebTheme.text),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18, color: WebTheme.primary),
      filled: true,
      fillColor: WebTheme.surfaceAlt,
      labelStyle: const TextStyle(fontSize: 13, color: AppColors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: WebTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: WebTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: WebTheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );
}

// ── Social links card ────────────────────────────────────────
class _SocialLinksCard extends StatelessWidget {
  final BoothManagementController c;
  const _SocialLinksCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return _WebCard(
      icon: Icons.link_rounded,
      title: 'روابط التواصل',
      subtitle: 'اختر من روابط ملفك أو أضف روابط جديدة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 6,
              children: c.profileLinks.map((link) {
                final isAdded = c.socialLinks.contains(link);
                return GestureDetector(
                  onTap: () => isAdded
                      ? c.removeSocialLink(link)
                      : c.addProfileLink(link),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isAdded
                          ? WebTheme.primary.withOpacity(0.15)
                          : WebTheme.surfaceAlt,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isAdded
                            ? WebTheme.primary
                            : AppColors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAdded ? Icons.check_rounded : Icons.add_rounded,
                          size: 13,
                          color: isAdded ? WebTheme.primary : AppColors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _short(link),
                          style: TextStyle(
                            fontSize: 12,
                            color: isAdded ? WebTheme.primary : AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final custom = c.socialLinks
                .where((l) => !c.profileLinks.contains(l))
                .toList();
            if (custom.isEmpty) return const SizedBox.shrink();
            return Column(
              children: custom
                  .map(
                    (l) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: WebTheme.primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.link_rounded,
                            size: 14,
                            color: WebTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l,
                              style: TextStyle(
                                fontSize: 12,
                                color: WebTheme.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => c.removeSocialLink(l),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: c.newLinkCtrl,
                  style: TextStyle(fontSize: 13, color: WebTheme.text),
                  decoration: InputDecoration(
                    hintText: 'أضف رابطاً جديداً...',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(
                      Icons.add_link_rounded,
                      size: 16,
                      color: AppColors.grey,
                    ),
                    filled: true,
                    fillColor: WebTheme.surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: c.addSocialLink,
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    gradient: AppColors.darkCTAGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _short(String url) {
    try {
      return Uri.parse(url).host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }
}

// ── Images card ──────────────────────────────────────────────
class _ImagesCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final RxList<String> images;
  final RxList<XFile> imageFiles;
  final VoidCallback onAdd;
  final void Function(int) onRemoveUrl;
  final void Function(int) onRemoveFile;

  const _ImagesCard({
    required this.title,
    required this.icon,
    required this.images,
    required this.imageFiles,
    required this.onAdd,
    required this.onRemoveUrl,
    required this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
    return _WebCard(
      icon: icon,
      title: title,
      subtitle: null,
      child: Obx(
        () => Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // ── صور الشبكة (من السيرفر) ──
            ...images.asMap().entries.map(
              (e) => _WebImageTile(
                width: 100,
                height: 80,
                onRemove: () => onRemoveUrl(e.key),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    e.value,
                    width: 100,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 80,
                      color: WebTheme.surfaceAlt,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // ── صور محلية (من الجهاز) ──
            ...imageFiles.asMap().entries.map(
              (e) => _WebImageTile(
                width: 100,
                height: 80,
                onRemove: () => onRemoveFile(e.key),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _XFileImage(file: e.value, width: 100, height: 80),
                ),
              ),
            ),
            // ── زر الإضافة ──
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 100,
                height: 80,
                decoration: BoxDecoration(
                  color: WebTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: WebTheme.primary.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: WebTheme.primary,
                      size: 26,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'إضافة',
                      style: TextStyle(fontSize: 11, color: WebTheme.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// غلاف صورة في الويب مع زر ✕ للحذف
class _WebImageTile extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  final VoidCallback onRemove;

  const _WebImageTile({
    required this.width,
    required this.height,
    required this.child,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          SizedBox(width: width, height: height, child: child),
          Positioned(
            top: 4,
            left: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// عرض XFile كصورة (يعمل على موبايل وويب)
class _XFileImage extends StatelessWidget {
  final XFile file;
  final double width;
  final double height;

  const _XFileImage({
    required this.file,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (_, snap) {
        if (snap.hasData) {
          return Image.memory(
            snap.data!,
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
        }
        return Container(
          width: width,
          height: height,
          color: WebTheme.surfaceAlt,
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }
}

// ── Booth events card ────────────────────────────────────────
class _BoothEventsCard extends StatelessWidget {
  final BoothManagementController c;
  const _BoothEventsCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return _WebCard(
      icon: Icons.event_rounded,
      title: 'فعاليات الجناح',
      subtitle: 'الفعاليات التي أنشأتها في هذا المعرض',
      action: GestureDetector(
        onTap: () => WebNavController.to.openCreateEvent(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.favoriteGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                'إضافة فعالية',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      child: Obx(() {
        if (c.boothEvents.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'لا توجد فعاليات بعد',
                style: TextStyle(
                  color: AppColors.grey.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ),
          );
        }
        return Column(
          children: c.boothEvents
              .map(
                (e) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: WebTheme.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: AppColors.favoriteGradient,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.event_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.name,
                              style: TextStyle(
                                color: WebTheme.text,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${e.date} • ${e.time}',
                              style: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: WebTheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${e.registeredCount} مسجّل',
                          style: TextStyle(
                            fontSize: 11,
                            color: WebTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      }),
    );
  }
}

// ── Shared card wrapper ──────────────────────────────────────
class _WebCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? action;

  const _WebCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WebTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WebTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: WebTheme.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
