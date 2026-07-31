// ════════════════════════════════════════════════════════════
//  SHARED WIDGET — booth day picker dialog + helper function
//  Used by both CreateEventView (mobile) and
//  WebCreateEventPage (web).
// ════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/Home/events_controller.dart';
import '../../../core/constant/appcolors.dart';

// ── Top-level helper ─────────────────────────────────────────
/// يفتح نافذة اختيار أيام الجناح ويكتب النتيجة في الكنترولر.
/// [isDark] : وضع الإضاءة الحالي
/// [isEnd]  : true → يكتب في selectedEndDate، false → selectedDate
Future<void> showBoothDayPicker(
  BuildContext context,
  bool isDark, {
  required bool isEnd,
}) async {
  final ctrl = Get.find<EventsController>();

  if (ctrl.selectedBooth.value == null) {
    Get.snackbar(
      'تنبيه',
      'يرجى اختيار الجناح أولاً',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFF7941D),
      colorText: const Color(0xFFFFFFFF),
    );
    return;
  }

  final days = ctrl.boothDayDates;
  if (days.isEmpty) {
    Get.snackbar(
      'تنبيه',
      'لا توجد أيام متاحة لهذا الجناح',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFF7941D),
      colorText: const Color(0xFFFFFFFF),
    );
    return;
  }

  // تحديد اليوم المحدد مسبقاً (إن وجد)
  int? initialIndex;
  final currentStr = isEnd
      ? ctrl.selectedEndDate.value
      : ctrl.selectedDate.value;
  if (currentStr.isNotEmpty) {
    final currentDt = DateTime.tryParse(currentStr);
    if (currentDt != null) {
      final found = days.indexWhere(
        (d) =>
            d.year == currentDt.year &&
            d.month == currentDt.month &&
            d.day == currentDt.day,
      );
      if (found >= 0) initialIndex = found;
    }
  }

  // الحد الأدنى لتاريخ النهاية (لا يجوز أن يكون قبل البداية)
  int minIndex = 0;
  if (isEnd && ctrl.selectedDate.value.isNotEmpty) {
    final startDt = DateTime.tryParse(ctrl.selectedDate.value);
    if (startDt != null) {
      final found = days.indexWhere(
        (d) =>
            d.year == startDt.year &&
            d.month == startDt.month &&
            d.day == startDt.day,
      );
      if (found >= 0) minIndex = found;
    }
  }

  final result = await showDialog<int>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => BoothDayPickerDialog(
      days: days,
      initialIndex: initialIndex,
      minIndex: minIndex,
      isDark: isDark,
    ),
  );

  if (result != null && result >= 0 && result < days.length) {
    final picked = days[result];
    final formatted =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    if (isEnd) {
      ctrl.selectedEndDate.value = formatted;
    } else {
      ctrl.selectedDate.value = formatted;
      // إذا أصبح تاريخ النهاية قبل البداية الجديدة → اجعله نفس اليوم
      final endDt = DateTime.tryParse(ctrl.selectedEndDate.value);
      if (endDt != null && endDt.isBefore(picked)) {
        ctrl.selectedEndDate.value = formatted;
      }
    }
  }
}

// ── Dialog widget ─────────────────────────────────────────────
class BoothDayPickerDialog extends StatefulWidget {
  final List<DateTime> days;
  final int? initialIndex;
  final int minIndex; // للتاريخ النهاية: أقل يوم مسموح بتحديده
  final bool isDark;

  const BoothDayPickerDialog({
    super.key,
    required this.days,
    required this.initialIndex,
    required this.minIndex,
    required this.isDark,
  });

  @override
  State<BoothDayPickerDialog> createState() => _BoothDayPickerDialogState();
}

class _BoothDayPickerDialogState extends State<BoothDayPickerDialog> {
  int? _selectedIndex;

  static const _monthNames = [
    '',
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  String _formatDate(DateTime d) =>
      '${d.day} ${_monthNames[d.month]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final dialogBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: AppColors.favoriteGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'اختر اليوم',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'أيام حجز الجناح — اضغط على اليوم المطلوب',
                style: TextStyle(fontSize: 11, color: AppColors.grey),
              ),
            ),
            const SizedBox(height: 22),

            // ── Days list ────────────────────────────────────────
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.days.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (_, i) {
                  final day = widget.days[i];
                  final isSelected = _selectedIndex == i;
                  final isDisabled = i < widget.minIndex;

                  return GestureDetector(
                    onTap: isDisabled
                        ? null
                        : () => setState(() => _selectedIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.darkPrimary.withOpacity(0.10)
                            : isDisabled
                            ? (isDark
                                  ? Colors.white.withOpacity(0.03)
                                  : Colors.black.withOpacity(0.03))
                            : cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.darkPrimary.withOpacity(0.50)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // رقم اليوم
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? AppColors.favoriteGradient
                                  : null,
                              color: isSelected
                                  ? null
                                  : isDisabled
                                  ? AppColors.grey.withOpacity(0.15)
                                  : AppColors.darkPrimary.withOpacity(0.10),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : isDisabled
                                      ? AppColors.grey
                                      : AppColors.darkPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // اسم اليوم
                          Expanded(
                            child: Text(
                              'اليوم ${i + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isDisabled ? AppColors.grey : null,
                              ),
                            ),
                          ),

                          // التاريخ — يظهر عند التحديد
                          AnimatedOpacity(
                            opacity: isSelected ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.darkPrimary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formatDate(day),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkPrimary,
                                ),
                              ),
                            ),
                          ),

                          if (isDisabled) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.lock_outline_rounded,
                              size: 14,
                              color: AppColors.grey,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // ── Action buttons ───────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.grey.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedIndex == null
                        ? null
                        : () => Navigator.pop(context, _selectedIndex),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPrimary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.darkPrimary
                          .withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'تأكيد',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
