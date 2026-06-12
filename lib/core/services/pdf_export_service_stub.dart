import 'package:flutter/foundation.dart';
import '../utils/report_type_helper.dart';
import '../../data/model/report/report_model.dart';

class PdfExportService {
  PdfExportService._();

  static void printReport(ReportModel r, ReportTypeContent c) {
    debugPrint('PDF export is not available on this platform.');
  }
}
