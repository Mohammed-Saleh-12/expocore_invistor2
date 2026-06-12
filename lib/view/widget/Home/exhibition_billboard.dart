import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/appcolors.dart';
import '../../../controller/Home/exhibition_billboard_controller.dart';
import '../../../data/model/exhibition/exhibition_model.dart';

class ExhibitionBillboard extends StatelessWidget {
  final List<ExhibitionModel> exhibitions;
  final void Function(ExhibitionModel)? onTap;

  const ExhibitionBillboard({super.key, required this.exhibitions, this.onTap});

  String _statusLabel(String status) {
    switch (status) {
      case 'active':   return 'جارٍ الآن';
      case 'upcoming': return 'قادم';
      default:         return 'منتهٍ';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':   return AppColors.success;
      case 'upcoming': return AppColors.info;
      default:         return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (exhibitions.isEmpty) return const SizedBox.shrink();
    final ctrl = Get.put(ExhibitionBillboardController(), tag: 'exhibition_billboard');
    ctrl.init(exhibitions.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 210,
              child: PageView.builder(
                controller: ctrl.pageCtrl,
                itemCount: exhibitions.length,
                onPageChanged: ctrl.onPageChanged,
                itemBuilder: (_, index) {
                  final ex = exhibitions[index];
                  return GestureDetector(
                    onTap: () => onTap?.call(ex),
                    child: _BillboardSlide(
                      exhibition: ex,
                      statusLabel: _statusLabel(ex.status),
                      statusColor: _statusColor(ex.status),
                    ),
                  );
                },
              ),
            ),
            Positioned(left: 6, child: _NavButton(icon: Icons.chevron_left_rounded, onTap: ctrl.prev)),
            Positioned(right: 6, child: _NavButton(icon: Icons.chevron_right_rounded, onTap: ctrl.next)),
            Positioned(
              bottom: 10,
              child: Obx(() => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(exhibitions.length, (i) {
                      final isActive = i == ctrl.currentIndex.value;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 20 : 6, height: 6,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.white54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  )),
            ),
          ],
        ),
      ],
    );
  }
}

class _BillboardSlide extends StatelessWidget {
  final ExhibitionModel exhibition;
  final String statusLabel;
  final Color statusColor;

  const _BillboardSlide({required this.exhibition, required this.statusLabel, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(exhibition.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.darkSurface, child: const Icon(Icons.image, size: 64, color: AppColors.grey))),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC000000)], stops: [0.35, 1.0]),
              ),
            ),
            Positioned(
              top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.85), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(statusLabel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.darkPrimary, AppColors.darkSecondary]), borderRadius: BorderRadius.circular(20)),
                child: const Text('إعلان مميز', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exhibition.name,
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.2, shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text('${exhibition.startDate} — ${exhibition.endDate}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(width: 14),
                        const Icon(Icons.location_on_outlined, size: 13, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(child: Text('${exhibition.location}، ${exhibition.city}', style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
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

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      );
}
