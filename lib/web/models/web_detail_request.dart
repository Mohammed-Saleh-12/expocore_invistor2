// ════════════════════════════════════════════════════════════
//  MODEL  —  WebDetailRequest
//  يصف الصفحة الداخلية المطلوب عرضها داخل منطقة المحتوى
// ════════════════════════════════════════════════════════════
enum WebDetailType {
  exhibition, booth, event, report,
  createEvent, ticketRequests, sponsorship, scanner,
  notifications, sponsorEvent, map,
}

class WebDetailRequest {
  final WebDetailType type;
  final Object?       data;       // الموديل المرتبط (معرض/جناح/...)
  final Object?       extra;      // بيانات إضافية اختيارية

  const WebDetailRequest(this.type, {this.data, this.extra});
}
