import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/report_type_helper.dart';
import '../../data/model/report/report_model.dart';

// ════════════════════════════════════════════════════════════
//  PdfExportService  —  mobile / non-web stub
//  Generates a plain-text summary of the report and shares it
//  via share_plus so the user can email/copy/print it.
// ════════════════════════════════════════════════════════════
class PdfExportService {
  PdfExportService._();

  static void printReport(ReportModel r, ReportTypeContent c) {
    _shareReport(r, c);
  }

  static void _shareReport(ReportModel r, ReportTypeContent c) async {
    try {
      final text = _buildText(r, c);

      // Save as a .txt file in temp dir so share_plus can attach it
      final tmpPath =
          '${Directory.systemTemp.path}/expocore_report_${r.id}.txt';
      await File(tmpPath).writeAsString(text, flush: true);

      await Share.shareXFiles(
        [XFile(tmpPath, mimeType: 'text/plain')],
        subject: r.title,
        text: 'تقرير ExpoCore — ${r.title}',
      );
    } catch (e) {
      debugPrint('Mobile report share failed: $e');
      Get.snackbar(
        'تصدير التقرير',
        'تعذّر المشاركة — يرجى المحاولة لاحقاً',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  static String _buildText(ReportModel r, ReportTypeContent c) {
    final sep = '─' * 40;
    final kpis = c.kpis
        .map((k) =>
            '  • ${k.label}: ${k.value}${k.trend.isNotEmpty ? "  (${k.trend})" : ""}')
        .join('\n');
    final headers = c.tableHeaders.join(' | ');
    final rows = c.tableRows.map((row) => '  ${row.join(' | ')}').join('\n');
    final insights =
        c.insights.map((i) => '  💡 $i').join('\n');

    return '''
══════════════════════════════════════════
  EXPOCORE — تقرير الأداء
══════════════════════════════════════════
  العنوان  : ${r.title}
  النوع    : ${c.typeLabel}
  الجناح   : ${r.boothName}
  المعرض   : ${r.exhibitionName}
  الفترة   : ${r.period}
  تاريخ الإنشاء: ${r.createdAt}
  نمو الفترة: ${r.trend.toStringAsFixed(1)}%
$sep
المؤشرات الرئيسية:
$kpis
$sep
البيانات التفصيلية:
  $headers
$rows
$sep
رؤى وتوصيات:
$insights
$sep
تم التصدير بواسطة منصة ExpoCore للمستثمرين
══════════════════════════════════════════
''';
  }
}
