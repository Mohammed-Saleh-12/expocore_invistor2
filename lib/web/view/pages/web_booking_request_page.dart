import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/Home/booking_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/booth/booth_model.dart';
import '../../controllers/web_nav_controller.dart';
import '../../models/web_theme.dart';

// ════════════════════════════════════════════════════════════
//  WebBookingRequestPage  —  طلب حجز جناح (نسخة الويب)
// ════════════════════════════════════════════════════════════
class WebBookingRequestPage extends StatefulWidget {
  final BoothModel booth;
  const WebBookingRequestPage({super.key, required this.booth});

  @override
  State<WebBookingRequestPage> createState() => _WebBookingRequestPageState();
}

class _WebBookingRequestPageState extends State<WebBookingRequestPage> {
  late final BookingController c;

  @override
  void initState() {
    super.initState();
    c = Get.isRegistered<BookingController>()
        ? Get.find<BookingController>()
        : Get.put(BookingController());
    c.setBooth(widget.booth);
    c.duration.value = 1;
    c.screenService.value = false;
    c.setupService.value = false;
    c.securitySvc.value = false;
    c.cleaningService.value = false;
    c.notesCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _backBar(),
              const SizedBox(height: 20),
              Text(
                'طلب حجز جناح',
                style: TextStyle(color: WebTheme.text, fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text('أكمل البيانات لإرسال طلب الحجز', style: TextStyle(color: AppColors.grey, fontSize: 14)),
              const SizedBox(height: 20),
              _boothSummary(),
              const SizedBox(height: 20),
              _durationSection(),
              const SizedBox(height: 20),
              _servicesSection(),
              const SizedBox(height: 20),
              _notesSection(),
              const SizedBox(height: 20),
              _costSummary(),
              const SizedBox(height: 24),
              _submitButton(),
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
              child: Icon(Icons.arrow_forward_rounded, color: WebTheme.text, size: 20),
            ),
            const SizedBox(width: 10),
            Text('رجوع', style: TextStyle(color: AppColors.grey, fontSize: 14)),
          ],
        ),
      );

  Widget _boothSummary() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: WebTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkPrimary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(gradient: AppColors.darkCTAGradient, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('جناح ${widget.booth.number}',
                      style: TextStyle(color: WebTheme.text, fontSize: 18, fontWeight: FontWeight.w800)),
                  Text(widget.booth.exhibitionName,
                      style: const TextStyle(color: AppColors.grey, fontSize: 13)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${widget.booth.price.toInt()} ريال',
                    style: const TextStyle(
                        color: AppColors.orange, fontSize: 16, fontWeight: FontWeight.w800)),
                const Text('للمعرض كاملاً',
                    style: TextStyle(color: AppColors.grey, fontSize: 11)),
              ],
            ),
          ],
        ),
      );

  Widget _durationSection() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: WebTheme.surface,
          borderRadius: BorderRadius.circular(16),
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
                  child: const Icon(Icons.calendar_today_rounded, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text('مدة المشاركة', style: TextStyle(color: WebTheme.text, fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => Row(
                  children: List.generate(5, (i) {
                    final d = i + 1;
                    final active = c.duration.value == d;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => c.duration.value = d,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: active ? AppColors.darkCTAGradient : null,
                            color: active ? null : WebTheme.surfaceAlt,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: active ? Colors.transparent : WebTheme.border,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$d',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: active ? Colors.white : WebTheme.text,
                                ),
                              ),
                              Text(
                                'يوم',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: active ? Colors.white70 : AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                )),
          ],
        ),
      );

  Widget _servicesSection() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: WebTheme.surface,
          borderRadius: BorderRadius.circular(16),
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
                  child: const Icon(Icons.room_service_rounded, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text('خدمات إضافية', style: TextStyle(color: WebTheme.text, fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (_, cons) {
                final isWide = cons.maxWidth > 500;
                final services = [
                  (c.screenService, Icons.tv_outlined, 'إعلانات على الشاشات', '500'),
                  (c.setupService, Icons.chair_outlined, 'تجهيزات وأثاث', '800'),
                  (c.securitySvc, Icons.security_outlined, 'أمن خاص', '300'),
                  (c.cleaningService, Icons.cleaning_services_outlined, 'خدمة تنظيف', '200'),
                ];
                if (isWide) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: services.map((s) => SizedBox(
                          width: (cons.maxWidth - 12) / 2,
                          child: _serviceToggle(s.$1, s.$2, s.$3, s.$4),
                        )).toList(),
                  );
                }
                return Column(
                  children: services.map((s) => _serviceToggle(s.$1, s.$2, s.$3, s.$4)).toList(),
                );
              },
            ),
          ],
        ),
      );

  Widget _serviceToggle(RxBool val, IconData icon, String label, String price) => Obx(() => GestureDetector(
        onTap: () => val.toggle(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: val.value ? AppColors.darkPrimary.withOpacity(0.12) : WebTheme.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: val.value ? AppColors.darkPrimary : WebTheme.border,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: val.value ? AppColors.darkPrimary : AppColors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: val.value ? WebTheme.text : AppColors.grey,
                    fontWeight: val.value ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              Text(
                '$price ر.س',
                style: TextStyle(
                  fontSize: 12,
                  color: val.value ? AppColors.orange : AppColors.grey,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  gradient: val.value ? AppColors.darkCTAGradient : null,
                  color: val.value ? null : WebTheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: val.value ? Colors.transparent : AppColors.grey.withOpacity(0.4),
                  ),
                ),
                child: val.value
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                    : null,
              ),
            ],
          ),
        ),
      ));

  Widget _notesSection() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: WebTheme.surface,
          borderRadius: BorderRadius.circular(16),
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
                  child: const Icon(Icons.note_alt_outlined, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text('ملاحظات للإدارة (اختياري)',
                    style: TextStyle(color: WebTheme.text, fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: c.notesCtrl,
              maxLines: 4,
              style: TextStyle(fontSize: 13, color: WebTheme.text),
              decoration: InputDecoration(
                hintText: 'أضف أي ملاحظات أو متطلبات خاصة...',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.grey),
                filled: true,
                fillColor: WebTheme.surfaceAlt,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ],
        ),
      );

  Widget _costSummary() => Obx(() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: WebTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkPrimary.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ملخص التكلفة',
                style: TextStyle(color: WebTheme.text, fontSize: 15, fontWeight: FontWeight.w700)),
            Divider(color: WebTheme.border, height: 20),
            _costRow('الإيجار الأساسي',
                '${(widget.booth.price * c.duration.value).toInt()} ر.س'),
            if (c.screenService.value) _costRow('إعلانات الشاشات', '500 ر.س'),
            if (c.setupService.value) _costRow('تجهيزات وأثاث', '800 ر.س'),
            if (c.securitySvc.value) _costRow('أمن خاص', '300 ر.س'),
            if (c.cleaningService.value) _costRow('خدمة تنظيف', '200 ر.س'),
            Divider(color: WebTheme.border, height: 20),
            Row(
              children: [
                Text('الإجمالي',
                    style: TextStyle(color: WebTheme.text, fontSize: 16, fontWeight: FontWeight.w800)),
                const Spacer(),
                Text(
                  '${c.total.toInt()} ر.س',
                  style: const TextStyle(color: AppColors.orange, fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ],
        ),
      ));

  Widget _costRow(String label, String val) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
            const Spacer(),
            Text(val, style: TextStyle(fontSize: 13, color: WebTheme.text, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _submitButton() => Obx(() => GestureDetector(
        onTap: c.isSubmitting.value ? null : c.submitBooking,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: c.isSubmitting.value ? null : AppColors.favoriteGradient,
            color: c.isSubmitting.value ? AppColors.grey.withOpacity(0.3) : null,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: c.isSubmitting.value
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : const Text(
                  'إرسال طلب الحجز',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
        ),
      ));
}
