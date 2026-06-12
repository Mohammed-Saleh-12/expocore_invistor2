import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/booth/booth_model.dart';
import '../../controllers/web_nav_controller.dart';
import '../../models/web_theme.dart';
import '../widgets/web_status_chip.dart';

// ════════════════════════════════════════════════════════════
//  WebBookingDetailPage  —  تفاصيل الحجز (نسخة الويب)
// ════════════════════════════════════════════════════════════
class WebBookingDetailPage extends StatelessWidget {
  final BoothModel booth;
  const WebBookingDetailPage({super.key, required this.booth});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _backBar(),
              const SizedBox(height: 20),
              _statusBanner(),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (_, cons) {
                  final isWide = cons.maxWidth > 580;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _boothCard()),
                        const SizedBox(width: 16),
                        Expanded(child: _bookingDetailsCard()),
                      ],
                    );
                  }
                  return Column(children: [_boothCard(), const SizedBox(height: 16), _bookingDetailsCard()]);
                },
              ),
              const SizedBox(height: 16),
              _paymentCard(),
              const SizedBox(height: 16),
              _servicesCard(),
              const SizedBox(height: 28),
              _actionButtons(),
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

  Widget _statusBanner() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.success, Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الحجز مؤكد',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  Text('رقم الحجز: #BK-20260715-001',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                ],
              ),
            ),
            WebStatusChip(status: booth.status),
          ],
        ),
      );

  Widget _boothCard() => _InfoCard(
        title: 'تفاصيل الجناح',
        icon: Icons.grid_view_rounded,
        rows: [
          _Row('رقم الجناح', booth.number),
          _Row('المعرض', booth.exhibitionName),
          _Row('الموقع', booth.location),
          _Row('المساحة', '${booth.area.toInt()} م²'),
        ],
      );

  Widget _bookingDetailsCard() => _InfoCard(
        title: 'تفاصيل الحجز',
        icon: Icons.event_note_rounded,
        rows: const [
          _Row('تاريخ البدء', '2026-07-15'),
          _Row('تاريخ الانتهاء', '2026-07-20'),
          _Row('المدة', '5 أيام'),
          _Row('تاريخ الحجز', '2026-06-01'),
        ],
      );

  Widget _paymentCard() => Container(
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
                  child: const Icon(Icons.payments_outlined, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text('الدفعات', style: TextStyle(color: WebTheme.text, fontSize: 15, fontWeight: FontWeight.w700)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Get.snackbar('', 'تم تنزيل الفاتورة', snackPosition: SnackPosition.BOTTOM),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.darkPrimary.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.receipt_outlined, size: 16, color: AppColors.darkPrimary),
                        SizedBox(width: 6),
                        Text('تنزيل الفاتورة',
                            style: TextStyle(fontSize: 12, color: AppColors.darkPrimary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Divider(color: WebTheme.border, height: 20),
            _payRow('الإيجار الأساسي', '${booth.price.toInt()} ريال'),
            _payRow('خدمات إضافية', '1,500 ريال'),
            Divider(color: WebTheme.border, height: 16),
            _payRow('الإجمالي', '${(booth.price + 1500).toInt()} ريال', valueColor: AppColors.orange, bold: true),
            const SizedBox(height: 4),
            _payRow('المدفوع', '${((booth.price + 1500) / 2).toInt()} ريال', valueColor: AppColors.success),
            _payRow('المتبقي', '${((booth.price + 1500) / 2).toInt()} ريال', valueColor: AppColors.error),
          ],
        ),
      );

  Widget _servicesCard() => Container(
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
                  child: const Icon(Icons.room_service_rounded, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text('الخدمات المحجوزة',
                    style: TextStyle(color: WebTheme.text, fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['واي فاي', 'كهرباء', 'إضاءة مميزة', 'إعلانات الشاشات']
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.darkPrimary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.darkPrimary.withOpacity(0.3)),
                        ),
                        child: Text(s,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.darkPrimary, fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
            ),
          ],
        ),
      );

  Widget _actionButtons() => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _actionBtn(
            'إدارة الجناح',
            filled: true,
            icon: Icons.manage_accounts_rounded,
            onTap: () => WebNavController.to.openBoothManagement(booth),
          ),
          _actionBtn(
            'تنزيل العقد PDF',
            filled: false,
            icon: Icons.download_outlined,
            onTap: () => Get.snackbar('نجاح', 'تم تنزيل العقد PDF', snackPosition: SnackPosition.BOTTOM),
          ),
          _actionBtn(
            'إلغاء الحجز',
            filled: false,
            icon: Icons.cancel_outlined,
            danger: true,
            onTap: () => Get.dialog(AlertDialog(
              backgroundColor: WebTheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Text('إلغاء الحجز', style: TextStyle(color: WebTheme.text)),
              content: Text('هل أنت متأكد من رغبتك في إلغاء هذا الحجز؟',
                  style: TextStyle(color: AppColors.grey)),
              actions: [
                TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('تراجع', style: TextStyle(color: AppColors.darkPrimary))),
                TextButton(
                    onPressed: () {
                      Get.back();
                      Get.snackbar('تم', 'تم إلغاء الحجز', snackPosition: SnackPosition.BOTTOM);
                    },
                    child: const Text('تأكيد الإلغاء', style: TextStyle(color: AppColors.error))),
              ],
            )),
          ),
        ],
      );

  Widget _payRow(String label, String val, {Color? valueColor, bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
            const Spacer(),
            Text(val,
                style: TextStyle(
                    fontSize: 14,
                    color: valueColor ?? WebTheme.text,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
          ],
        ),
      );

  Widget _actionBtn(String label,
          {required bool filled,
          required IconData icon,
          required VoidCallback onTap,
          bool danger = false}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: BoxDecoration(
            gradient: filled ? AppColors.favoriteGradient : null,
            color: danger ? AppColors.error.withOpacity(0.1) : null,
            border: filled
                ? null
                : Border.all(
                    color: danger ? AppColors.error.withOpacity(0.5) : AppColors.darkPrimary.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 18,
                  color: filled
                      ? Colors.white
                      : (danger ? AppColors.error : AppColors.darkPrimary)),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: filled
                        ? Colors.white
                        : (danger ? AppColors.error : AppColors.darkPrimary),
                  )),
            ],
          ),
        ),
      );
}

// ── Helper widgets ───────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_Row> rows;
  const _InfoCard({required this.title, required this.icon, required this.rows});

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
              Text(title, style: TextStyle(color: WebTheme.text, fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          Divider(color: WebTheme.border, height: 20),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text(r.label, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
                    const Spacer(),
                    Text(r.value,
                        style: TextStyle(
                            fontSize: 13, color: WebTheme.text, fontWeight: FontWeight.w600)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _Row {
  final String label;
  final String value;
  const _Row(this.label, this.value);
}
