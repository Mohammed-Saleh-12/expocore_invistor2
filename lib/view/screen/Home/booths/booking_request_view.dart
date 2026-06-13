import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/booking_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../data/model/booth/booth_model.dart';
import '../../../../data/sourcedata/static/exhibitions_dummy.dart';
import '../../../widget/Home/custom_app_bar.dart';
import '../../../widget/Home/custom_button.dart';
import '../../../widget/Home/custom_text_field.dart';

class BookingRequestView extends GetView<BookingController> {
  const BookingRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    final booth = Get.arguments as BoothModel? ?? DummyData.myBooths.first;
    controller.setBooth(booth);
    return Scaffold(
      appBar: CustomAppBar(title: 'booking_request_title'.tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _boothSummary(context, booth),
          const SizedBox(height: 20),
          Text('booking_duration_label'.tr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Obx(() => Row(children: List.generate(5, (i) {
            final d = i + 1;
            final active = controller.duration.value == d;
            return GestureDetector(
              onTap: () => controller.duration.value = d,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(left: 8),
                width: 52, height: 52,
                decoration: BoxDecoration(
                  gradient: active ? AppColors.darkCTAGradient : null,
                  color: active ? null : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.lightSurface),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: active ? Colors.transparent : AppColors.grey.withOpacity(0.3)),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('$d', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: active ? Colors.white : null)),
                  Text('booking_day'.tr, style: TextStyle(fontSize: 9, color: active ? Colors.white70 : AppColors.grey)),
                ]),
              ),
            );
          }))),
          const SizedBox(height: 20),
          Text('booking_extra_services'.tr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _serviceCheck('booking_screen_ads'.tr, controller.screenService, Icons.tv_outlined),
          _serviceCheck('booking_setup'.tr, controller.setupService, Icons.chair_outlined),
          _serviceCheck('booking_security'.tr, controller.securitySvc, Icons.security_outlined),
          _serviceCheck('booking_cleaning'.tr, controller.cleaningService, Icons.cleaning_services_outlined),
          const SizedBox(height: 20),
          Text('booking_notes_label'.tr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          CustomTextField(controller: controller.notesCtrl, hint: 'booking_notes_hint'.tr, maxLines: 3),
          const SizedBox(height: 20),
          _costSummary(context, booth),
          const SizedBox(height: 24),
          Obx(() => CustomButton(
            label: 'booking_submit_btn'.tr,
            onTap: controller.submitBooking,
            isLoading: controller.isSubmitting.value,
          )),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _boothSummary(BuildContext context, BoothModel booth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkCardGradient : null,
        color: isDark ? null : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkPrimary.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(gradient: AppColors.darkCTAGradient, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.grid_view, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${'event_booth_prefix'.tr} ${booth.number}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text(booth.exhibitionName, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
          Text('${booth.price.toInt()} ${'booking_per_exhibition'.tr}', style: const TextStyle(fontSize: 13, color: AppColors.orange, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }

  Widget _serviceCheck(String label, RxBool val, IconData icon) => Obx(() => CheckboxListTile(
    value: val.value,
    onChanged: (_) => val.toggle(),
    activeColor: AppColors.darkPrimary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    secondary: Icon(icon, color: AppColors.darkPrimary, size: 22),
    title: Text(label, style: const TextStyle(fontSize: 14)),
    contentPadding: EdgeInsets.zero,
  ));

  Widget _costSummary(BuildContext context, BoothModel booth) => Obx(() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkCardGradient : null,
        color: isDark ? null : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('booking_cost_summary'.tr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const Divider(height: 16),
        _costRow('booking_base_rent'.tr, '${(booth.price * controller.duration.value).toInt()} ريال'),
        if (controller.screenService.value) _costRow('booking_screen_ads_price'.tr, '500 ريال'),
        if (controller.setupService.value)  _costRow('booking_setup_price'.tr, '800 ريال'),
        if (controller.securitySvc.value)   _costRow('booking_security_price'.tr, '300 ريال'),
        if (controller.cleaningService.value) _costRow('booking_cleaning_price'.tr, '200 ريال'),
        const Divider(height: 16),
        Row(children: [
          Text('booking_total'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text('${controller.total.toInt()} ريال', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.orange)),
        ]),
      ]),
    );
  });

  Widget _costRow(String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
      const Spacer(),
      Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    ]),
  );
}
