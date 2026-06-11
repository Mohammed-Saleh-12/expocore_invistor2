import 'package:flutter/material.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/report/report_model.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onView;
  final VoidCallback onDownload;
  final bool isDownloading;

  const ReportCard({
    super.key,
    required this.report,
    required this.onView,
    required this.onDownload,
    this.isDownloading = false,
  });

  IconData _typeIcon(String type) {
    switch (type) {
      case 'visitors':
        return Icons.people_outline;
      case 'performance':
        return Icons.trending_up;
      case 'events':
        return Icons.event_outlined;
      case 'campaigns':
        return Icons.campaign_outlined;
      case 'monthly':
        return Icons.calendar_month_outlined;
      default:
        return Icons.bar_chart;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'visitors':
        return 'الزوار';
      case 'performance':
        return 'الأداء';
      case 'events':
        return 'الفعاليات';
      case 'campaigns':
        return 'الحملات';
      case 'monthly':
        return 'شهري';
      default:
        return 'تحليل';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkCardGradient : null,
        color: isDark ? null : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.darkPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _typeIcon(report.type),
                  color: AppColors.darkPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${report.boothName} • ${report.period}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.darkPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _typeLabel(report.type),
                  style: const TextStyle(
                    color: AppColors.darkPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.mainValue.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkPrimary,
                    ),
                  ),
                  Text(
                    report.mainLabel,
                    style: const TextStyle(fontSize: 11, color: AppColors.grey),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${report.trend}%',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onView,
                  child: Container(
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: AppColors.favoriteGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'عرض',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: isDownloading ? null : onDownload,
                  child: Container(
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.darkPrimary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isDownloading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.darkPrimary,
                            ),
                          )
                        : const Text(
                            'تنزيل PDF',
                            style: TextStyle(
                              color: AppColors.darkPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
