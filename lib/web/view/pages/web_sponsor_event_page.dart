import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/events_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../controllers/web_nav_controller.dart';

class WebSponsorEventPage extends StatelessWidget {
  final ExhibitionSponsorEvent event;
  const WebSponsorEventPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<EventsController>();
    c.selectedSponsorDuration.value = null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _back(),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(28),
                decoration: _dec(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 54, height: 54,
                          decoration: BoxDecoration(gradient: AppColors.favoriteGradient, borderRadius: BorderRadius.circular(14)),
                          child: Icon(Icons.campaign_rounded, color: WebTheme.text, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event.name, style: TextStyle(color: WebTheme.text, fontSize: 22, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text(event.type, style: TextStyle(color: AppColors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (event.description.isNotEmpty) ...[
                      Text(event.description, style: TextStyle(color: AppColors.grey.withOpacity(0.9), fontSize: 14, height: 1.7)),
                      const SizedBox(height: 18),
                    ],
                    _row(Icons.storefront_rounded, 'المعرض', event.exhibitionName),
                    _row(Icons.calendar_today_outlined, 'التاريخ', '${event.date} • ${event.startTime} - ${event.endTime}'),
                    _row(Icons.location_on_outlined, 'المكان', event.place),
                    const SizedBox(height: 24),

                    _section('اختر مدة الرعاية'),
                    const SizedBox(height: 12),
                    if (event.durationOptions.isEmpty)
                      Text('لا توجد خيارات رعاية متاحة لهذه الفعالية',
                          style: TextStyle(color: AppColors.grey.withOpacity(0.8), fontSize: 13))
                    else
                      Obx(() => Column(
                            children: event.durationOptions.map((opt) {
                              final sel = c.selectedSponsorDuration.value?.label == opt.label;
                              return GestureDetector(
                                onTap: () => c.selectedSponsorDuration.value = opt,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: sel ? AppColors.favoriteGradient : null,
                                    color: sel ? null : WebTheme.surfaceAlt,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: sel ? Colors.transparent : WebTheme.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(sel ? Icons.radio_button_checked : Icons.radio_button_off,
                                          color: sel ? WebTheme.text : AppColors.grey, size: 22),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(opt.label, style: TextStyle(color: sel ? WebTheme.text : WebTheme.text, fontSize: 15, fontWeight: FontWeight.w700)),
                                            Text('${opt.days} أيام', style: TextStyle(color: sel ? WebTheme.text70 : AppColors.grey, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      Text('${opt.price.toInt()} ر.س',
                                          style: TextStyle(color: sel ? WebTheme.text : WebTheme.accent, fontSize: 16, fontWeight: FontWeight.w800)),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )),
                    const SizedBox(height: 24),

                    _section('بيانات الشركة'),
                    const SizedBox(height: 12),
                    _field(c.companyNameCtrl, 'اسم الشركة', Icons.business_outlined),
                    const SizedBox(height: 12),
                    _field(c.companyPhoneCtrl, 'رقم الجوال', Icons.phone_outlined),
                    const SizedBox(height: 12),
                    _field(c.companyWebCtrl, 'الموقع الإلكتروني', Icons.language_outlined),
                    const SizedBox(height: 12),
                    _field(c.productNamesCtrl, 'المنتجات/الخدمات المعروضة', Icons.inventory_2_outlined),
                    const SizedBox(height: 28),

                    Obx(() => SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: c.isBooking.value ? null : () => _book(c),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(gradient: AppColors.favoriteGradient, borderRadius: BorderRadius.circular(14)),
                              child: c.isBooking.value
                                  ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text('تأكيد طلب الرعاية', style: TextStyle(color: WebTheme.text, fontSize: 16, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _book(EventsController c) async {
    final ok = await c.submitSponsorship(event);
    if (ok) WebNavController.to.select(4); // → رعاياتي
  }

  Widget _back() => GestureDetector(
        onTap: WebNavController.to.closeDetail,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: WebTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: WebTheme.border)),
            child: Icon(Icons.arrow_forward_rounded, color: WebTheme.text, size: 20),
          ),
          const SizedBox(width: 10),
          Text('رجوع', style: TextStyle(color: AppColors.grey, fontSize: 14)),
        ]),
      );

  BoxDecoration _dec() => BoxDecoration(
        color: WebTheme.surface, borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WebTheme.border),
      );

  Widget _section(String t) => Row(children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(gradient: AppColors.favoriteGradient, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(t, style: TextStyle(color: WebTheme.text, fontSize: 16, fontWeight: FontWeight.w800)),
      ]);

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          Icon(icon, size: 19, color: WebTheme.primary),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(color: AppColors.grey, fontSize: 14)),
          Expanded(child: Text(value, style: TextStyle(color: WebTheme.text, fontSize: 14, fontWeight: FontWeight.w600))),
        ]),
      );

  Widget _field(TextEditingController ctrl, String hint, IconData icon) => TextField(
        controller: ctrl,
        style: TextStyle(color: WebTheme.text),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
          filled: true, fillColor: WebTheme.surfaceAlt,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}
