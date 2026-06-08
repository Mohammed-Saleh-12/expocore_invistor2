import 'package:flutter/material.dart';
import '../../core/constant/appcolors.dart';

// ════════════════════════════════════════════════════════════
//  WebStatusChip  —  شارة حالة موحّدة
// ════════════════════════════════════════════════════════════
class WebStatusChip extends StatelessWidget {
  final String status;
  const WebStatusChip({super.key, required this.status});

  static const _map = {
    'active':   ('نشط',          AppColors.success),
    'upcoming': ('قادم',         AppColors.info),
    'pending':  ('قيد المراجعة', AppColors.info),
    'rejected': ('مرفوض',        AppColors.error),
    'ended':    ('منتهٍ',        AppColors.grey),
    'paused':   ('متوقف',        AppColors.orange),
  };

  @override
  Widget build(BuildContext context) {
    final (label, color) = _map[status] ?? ('—', AppColors.grey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
