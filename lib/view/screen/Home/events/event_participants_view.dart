import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../widget/Home/custom_app_bar.dart';

class EventParticipantsView extends StatelessWidget {
  const EventParticipantsView({super.key});

  static const _participants = [
    {'name': 'أحمد محمد الزهراني', 'company': 'شركة الابتكار التقني', 'status': 'confirmed'},
    {'name': 'سارة عبدالله الأحمد', 'company': 'مجموعة ريادة الأعمال', 'status': 'confirmed'},
    {'name': 'خالد إبراهيم السعد', 'company': 'شركة التقنية المتقدمة', 'status': 'pending'},
    {'name': 'نورة محمد العتيبي', 'company': 'مؤسسة الإبداع الرقمي', 'status': 'confirmed'},
    {'name': 'عبدالرحمن سعد الدوسري', 'company': 'شركة المستقبل للحلول', 'status': 'cancelled'},
    {'name': 'فاطمة علي الشمري', 'company': 'مركز التميز للتقنية', 'status': 'confirmed'},
    {'name': 'محمد عمر البلوي', 'company': 'شركة القيادة الرقمية', 'status': 'pending'},
    {'name': 'لمى حسن القحطاني', 'company': 'مجموعة نماء الأعمال', 'status': 'confirmed'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = _participants.where((p) => p['status'] == 'confirmed').length;
    final pending   = _participants.where((p) => p['status'] == 'pending').length;

    return Scaffold(
      appBar: CustomAppBar(title: 'المشاركون', actions: [
        IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.darkPrimary), onPressed: () {
          Get.snackbar('', 'تم إرسال الإشعار لجميع المسجلين', snackPosition: SnackPosition.BOTTOM);
        }),
      ]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Row(children: [
          _statPill('مؤكد', confirmed, AppColors.success),
          const SizedBox(width: 8),
          _statPill('معلق', pending, AppColors.info),
          const SizedBox(width: 8),
          _statPill('إجمالي', _participants.length, AppColors.darkPrimary),
        ])),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: _participants.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final p = _participants[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.darkPrimary.withOpacity(0.15),
                  child: Text((p['name'] as String).substring(0, 1), style: const TextStyle(color: AppColors.darkPrimary, fontWeight: FontWeight.w700)),
                ),
                title: Text(p['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(p['company'] as String, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                trailing: _statusChip(p['status'] as String),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _statPill(String label, int count, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
    child: Row(children: [
      Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: color)),
    ]),
  );

  Widget _statusChip(String status) {
    final map = {'confirmed': (AppColors.success, 'مؤكد'), 'pending': (AppColors.info, 'معلق'), 'cancelled': (AppColors.error, 'ملغي')};
    final (color, label) = map[status] ?? (AppColors.grey, 'غير معروف');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
