import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/constant/routes.dart';
import '../../../widget/Home/custom_app_bar.dart';
import '../../../widget/Home/custom_button.dart';

class BookingDetailView extends StatelessWidget {
  const BookingDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(title: 'تفاصيل الحجز', actions: [
        IconButton(icon: const Icon(Icons.download_outlined, color: AppColors.darkPrimary), onPressed: () {
          Get.snackbar('نجاح', 'تم تنزيل العقد PDF', snackPosition: SnackPosition.BOTTOM);
        }),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _statusBanner(context, isDark),
          const SizedBox(height: 16),
          _boothCard(context, isDark),
          const SizedBox(height: 16),
          _bookingDetails(context, isDark),
          const SizedBox(height: 16),
          _paymentCard(context, isDark),
          const SizedBox(height: 16),
          _servicesCard(context, isDark),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: CustomButton(label: 'إدارة الجناح', onTap: () => Get.toNamed(AppRoutes.BOOTH_DETAIL))),
            const SizedBox(width: 12),
            Expanded(child: CustomButton(label: 'التقرير', onTap: () => Get.toNamed(AppRoutes.REPORTS), isOutlined: true)),
          ]),
          const SizedBox(height: 10),
          CustomButton(
            label: 'إلغاء الحجز',
            isOutlined: true,
            onTap: () => Get.dialog(AlertDialog(
              title: const Text('إلغاء الحجز'),
              content: const Text('هل أنت متأكد من رغبتك في إلغاء هذا الحجز؟'),
              actions: [
                TextButton(onPressed: () => Get.back(), child: const Text('تراجع')),
                TextButton(onPressed: () { Get.back(); Get.snackbar('تم', 'تم إلغاء الحجز', snackPosition: SnackPosition.BOTTOM); }, child: const Text('تأكيد الإلغاء', style: TextStyle(color: AppColors.error))),
              ],
            )),
            gradient: const Color(0xFFFF6A6A),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _statusBanner(BuildContext context, bool isDark) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.success, Color(0xFF2E7D32)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      const Icon(Icons.check_circle_outline, color: Colors.white, size: 36),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('الحجز مؤكد', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const Text('رقم الحجز: #BK-20260715-001', style: TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    ]),
  );

  Widget _boothCard(BuildContext context, bool isDark) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(gradient: isDark ? AppColors.darkCardGradient : null, color: isDark ? null : AppColors.lightCard, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('تفاصيل الجناح', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      const Divider(height: 14),
      _detailRow('رقم الجناح', 'B12'),
      _detailRow('المعرض', 'معرض التقنية 2026'),
      _detailRow('الموقع', 'القاعة A - صف 3'),
      _detailRow('المساحة', '400 م²'),
    ]),
  );

  Widget _bookingDetails(BuildContext context, bool isDark) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(gradient: isDark ? AppColors.darkCardGradient : null, color: isDark ? null : AppColors.lightCard, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('تفاصيل الحجز', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      const Divider(height: 14),
      _detailRow('تاريخ البدء', '2026-07-15'),
      _detailRow('تاريخ الانتهاء', '2026-07-20'),
      _detailRow('المدة', '5 أيام'),
      _detailRow('تاريخ الحجز', '2026-06-01'),
    ]),
  );

  Widget _paymentCard(BuildContext context, bool isDark) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(gradient: isDark ? AppColors.darkCardGradient : null, color: isDark ? null : AppColors.lightCard, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('الدفعات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const Spacer(),
        IconButton(icon: const Icon(Icons.receipt_outlined, color: AppColors.darkPrimary, size: 20), onPressed: () {
          Get.snackbar('', 'تم تنزيل الفاتورة', snackPosition: SnackPosition.BOTTOM);
        }),
      ]),
      const Divider(height: 10),
      _detailRow('الإيجار الأساسي', '15,000 ريال'),
      _detailRow('خدمات إضافية', '1,500 ريال'),
      const Divider(height: 10),
      _detailRow('الإجمالي', '16,500 ريال', valueColor: AppColors.orange, valueBold: true),
      _detailRow('المدفوع', '8,250 ريال', valueColor: AppColors.success),
      _detailRow('المتبقي', '8,250 ريال', valueColor: AppColors.error),
    ]),
  );

  Widget _servicesCard(BuildContext context, bool isDark) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(gradient: isDark ? AppColors.darkCardGradient : null, color: isDark ? null : AppColors.lightCard, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('الخدمات المحجوزة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      const Divider(height: 14),
      Wrap(spacing: 8, runSpacing: 8, children: ['واي فاي', 'كهرباء', 'إضاءة مميزة', 'إعلانات الشاشات'].map((s) => Chip(
        label: Text(s, style: const TextStyle(fontSize: 11)),
        backgroundColor: AppColors.darkPrimary.withOpacity(0.15),
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
      )).toList()),
    ]),
  );

  Widget _detailRow(String label, String val, {Color? valueColor, bool valueBold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
      const Spacer(),
      Text(val, style: TextStyle(fontSize: 13, color: valueColor, fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500)),
    ]),
  );
}
