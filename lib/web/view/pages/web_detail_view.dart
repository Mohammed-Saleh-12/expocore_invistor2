import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/events_controller.dart';
import '../../../controller/Home/favorites_controller.dart';
import '../../../controller/Home/messages_controller.dart';
import '../../../controller/Home/reports_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../core/utils/report_type_helper.dart';
import '../../../data/model/booth/booth_model.dart';
import '../../../data/model/event/event_model.dart';
import '../../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../../data/model/exhibition/exhibition_model.dart';
import '../../../data/model/report/report_model.dart';
import '../../controllers/web_nav_controller.dart';
import '../../models/web_detail_request.dart';
import '../widgets/web_status_chip.dart';
import '../../../data/model/event/sponsorship_booking_model.dart';
import 'web_create_event_page.dart';
import 'web_ticket_requests_page.dart';
import 'web_sponsorship_detail_page.dart';
import 'web_scanner_page.dart';
import 'web_notifications_page.dart';
import 'web_sponsor_event_page.dart';
import 'web_map_page.dart';

// ════════════════════════════════════════════════════════════
//  WebDetailView  —  موجّه الصفحات الداخلية (يعرض الصفحة المناسبة)
// ════════════════════════════════════════════════════════════
class WebDetailView extends StatelessWidget {
  final WebDetailRequest request;
  const WebDetailView({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    switch (request.type) {
      case WebDetailType.exhibition:
        return _ExhibitionDetail(e: request.data as ExhibitionModel);
      case WebDetailType.booth:
        return _BoothDetail(
          b: request.data as BoothModel,
          report: request.extra as ReportModel?,
        );
      case WebDetailType.event:
        return _EventDetail(e: request.data as EventModel);
      case WebDetailType.report:
        return _ReportDetail(r: request.data as ReportModel);
      case WebDetailType.createEvent:
        return const WebCreateEventPage();
      case WebDetailType.ticketRequests:
        return WebTicketRequestsPage(event: request.data as EventModel);
      case WebDetailType.sponsorship:
        return WebSponsorshipDetailPage(
          booking: request.data as SponsorshipBookingModel,
        );
      case WebDetailType.scanner:
        return const WebScannerPage();
      case WebDetailType.notifications:
        return const WebNotificationsPage();
      case WebDetailType.sponsorEvent:
        return WebSponsorEventPage(
          event: request.data as ExhibitionSponsorEvent,
        );
      case WebDetailType.map:
        return const WebMapPage();
    }
  }
}

// ════════════════════════════════════════════════════════════
//  Shared scaffold for detail pages
// ════════════════════════════════════════════════════════════
class _DetailScaffold extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final Widget? badge;
  final List<Widget> children;
  final List<Widget> actions;

  const _DetailScaffold({
    required this.title,
    this.imageUrl,
    this.badge,
    required this.children,
    this.actions = const [],
  });

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
              // ── Back bar ─────────────────────────────────
              GestureDetector(
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
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: WebTheme.text,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'رجوع',
                      style: TextStyle(color: AppColors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Card ─────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: WebTheme.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: WebTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                        child: Image.network(
                          imageUrl!,
                          height: 260,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 260,
                            color: AppColors.darkSurface,
                            child: Icon(
                              Icons.image,
                              color: AppColors.grey,
                              size: 56,
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    color: WebTheme.text,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              if (badge != null) badge!,
                            ],
                          ),
                          const SizedBox(height: 20),
                          ...children,
                          if (actions.isNotEmpty) ...[
                            const SizedBox(height: 28),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: actions,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared helpers ──────────────────────────────────────────
Widget _infoRow(IconData icon, String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 9),
  child: Row(
    children: [
      Icon(icon, size: 20, color: AppColors.darkPrimary),
      const SizedBox(width: 12),
      Text('$label: ', style: TextStyle(color: AppColors.grey, fontSize: 14)),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            color: WebTheme.text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  ),
);

Widget _desc(String t) => Text(
  t,
  style: TextStyle(
    color: AppColors.grey.withOpacity(0.9),
    fontSize: 14,
    height: 1.8,
  ),
);

Widget _chips(String label, List<String> items) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      label,
      style: TextStyle(
        color: AppColors.grey,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
    const SizedBox(height: 10),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.darkPrimary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                s,
                style: TextStyle(color: AppColors.darkPink, fontSize: 12),
              ),
            ),
          )
          .toList(),
    ),
  ],
);

Widget _actionBtn(
  String label, {
  required bool filled,
  required VoidCallback onTap,
}) => GestureDetector(
  onTap: onTap,
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
    decoration: BoxDecoration(
      gradient: filled ? AppColors.favoriteGradient : null,
      border: filled
          ? null
          : Border.all(color: AppColors.darkPrimary.withOpacity(0.5)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: filled ? WebTheme.text : AppColors.darkPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),
);

// ════════════════════════════════════════════════════════════
//  Exhibition detail
// ════════════════════════════════════════════════════════════
class _ExhibitionDetail extends StatelessWidget {
  final ExhibitionModel e;
  const _ExhibitionDetail({required this.e});

  // خدمات المعرض (مطابقة لنسخة الجوال)
  static const _services = [
    (Icons.wifi, 'واي فاي مجاني'),
    (Icons.local_parking, 'موقف سيارات مجاني'),
    (Icons.security, 'أمن وحراسة على مدار الساعة'),
    (Icons.restaurant, 'منطقة طعام ومقاهي'),
    (Icons.settings_input_component, 'دعم تقني وكهربائي'),
    (Icons.person, 'استقبال وخدمة عملاء'),
  ];

  @override
  Widget build(BuildContext context) {
    final fav = Get.find<FavoritesController>();
    final events = Get.find<EventsController>();

    return _DetailScaffold(
      title: e.name,
      imageUrl: e.imageUrl,
      badge: WebStatusChip(status: e.status),
      children: [
        _desc(e.description),
        const SizedBox(height: 18),
        _infoRow(
          Icons.location_on_outlined,
          'الموقع',
          '${e.location}، ${e.city}',
        ),
        _infoRow(
          Icons.calendar_today_outlined,
          'التاريخ',
          '${e.startDate} — ${e.endDate}',
        ),
        _infoRow(
          Icons.grid_view_rounded,
          'الأجنحة المتاحة',
          '${e.availableBooths} جناح',
        ),
        const SizedBox(height: 16),
        _chips('القطاعات', e.sectors),
        const SizedBox(height: 24),

        // ── خدمات المعرض ─────────────────────────────────
        _subHeader('خدمات المعرض'),
        const SizedBox(height: 12),
        ..._services.map(
          (s) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(s.$1, size: 20, color: AppColors.darkPrimary),
                const SizedBox(width: 12),
                Text(
                  s.$2,
                  style: TextStyle(color: WebTheme.text, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ── فعاليات المعرض ───────────────────────────────
        _subHeader('فعاليات المعرض'),
        const SizedBox(height: 12),
        Obx(() {
          final list = events.exhibitionSponsorEvents
              .where((ev) => ev.exhibitionId == e.id)
              .toList();
          if (list.isEmpty) {
            return Text(
              'لا توجد فعاليات إعلانية لهذا المعرض حالياً',
              style: TextStyle(
                color: AppColors.grey.withOpacity(0.8),
                fontSize: 13,
              ),
            );
          }
          return Column(
            children: list
                .map((ev) => _SponsorEventRow(event: ev, ctrl: events))
                .toList(),
          );
        }),
      ],
      actions: [
        // مفضلة
        Obx(() {
          final isFav = fav.isExhibitionFavorited(e.id);
          return _actionBtn(
            isFav ? '★ في المفضلة' : '☆ أضف للمفضلة',
            filled: false,
            onTap: () => fav.toggleFavoriteExhibition(e),
          );
        }),
        // تواصل
        _actionBtn(
          'تواصل مع الإدارة',
          filled: false,
          onTap: () {
            Get.find<MessagesController>().prepareConversationForExhibition(
              e.name,
            );
            WebNavController.to.select(6);
          },
        ),
        // استكشاف الأجنحة
        _actionBtn(
          'خريطة المعرض 3D',
          filled: true,
          onTap: () => WebNavController.to.openMap(),
        ),
      ],
    );
  }
}

// ── Sub header ──────────────────────────────────────────────
Widget _subHeader(String t) => Row(
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
    Text(
      t,
      style: TextStyle(
        color: WebTheme.text,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    ),
  ],
);

// ── Sponsor event row ───────────────────────────────────────
class _SponsorEventRow extends StatelessWidget {
  final ExhibitionSponsorEvent event;
  final EventsController ctrl;
  const _SponsorEventRow({required this.event, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => WebNavController.to.openSponsorEvent(event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: WebTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.favoriteGradient,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                Icons.campaign_rounded,
                color: WebTheme.text,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: TextStyle(
                      color: WebTheme.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${event.date} • ${event.place}',
                    style: TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Obx(() {
              ctrl.exhibitionSponsorEvents.length; // تتبّع
              return IconButton(
                onPressed: () => ctrl.toggleSponsorFavorite(event),
                icon: Icon(
                  event.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.darkSecondary,
                  size: 20,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Booth detail
// ════════════════════════════════════════════════════════════
class _BoothDetail extends StatelessWidget {
  final BoothModel b;
  final ReportModel? report;
  const _BoothDetail({required this.b, this.report});

  @override
  Widget build(BuildContext context) => _DetailScaffold(
    title: 'جناح ${b.number}',
    imageUrl: b.imageUrl,
    badge: WebStatusChip(status: b.status),
    children: [
      _infoRow(Icons.storefront_rounded, 'المعرض', b.exhibitionName),
      _infoRow(Icons.location_on_outlined, 'الموقع', b.location),
      _infoRow(Icons.straighten_rounded, 'المساحة', '${b.area.toInt()} م²'),
      _infoRow(Icons.payments_outlined, 'السعر', '${b.price.toInt()} ر.س'),
      _infoRow(Icons.event_outlined, 'ينتهي في', b.endDate),
      const SizedBox(height: 16),
      _chips('الخدمات', b.amenities),
    ],
    actions: [
      if (b.status == 'active' && report != null)
        _actionBtn(
          'عرض التقرير',
          filled: false,
          onTap: () => WebNavController.to.openReport(report!),
        ),
      if (b.status == 'active' && report != null) const SizedBox(width: 12),
      _actionBtn(
        'حفظ',
        filled: true,
        onTap: () {
          Get.snackbar(
            'تم',
            'تم تحديث بيانات الجناح',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      ),
    ],
  );
}

// ════════════════════════════════════════════════════════════
//  Event detail
// ════════════════════════════════════════════════════════════
class _EventDetail extends StatelessWidget {
  final EventModel e;
  const _EventDetail({required this.e});

  @override
  Widget build(BuildContext context) => _DetailScaffold(
    title: e.name,
    badge: WebStatusChip(status: e.status),
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.darkPrimary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          e.type,
          style: TextStyle(
            color: AppColors.darkPink,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(height: 16),
      _desc(e.description),
      const SizedBox(height: 18),
      _infoRow(
        Icons.calendar_today_outlined,
        'التاريخ',
        '${e.date} • ${e.time}',
      ),
      _infoRow(
        Icons.store_outlined,
        'الجناح',
        e.boothNumber.isEmpty ? '—' : e.boothNumber,
      ),
      _infoRow(
        Icons.people_outline,
        'المسجّلون',
        '${e.registeredCount} / ${e.maxParticipants}',
      ),
      if (e.hasBookableSeats)
        _infoRow(
          Icons.event_seat_outlined,
          'المقاعد',
          '${e.bookedSeats} / ${e.totalSeats}',
        ),
      if (e.ticketPrice > 0)
        _infoRow(
          Icons.payments_outlined,
          'سعر التذكرة',
          '${e.ticketPrice.toInt()} ر.س',
        ),
    ],
    actions: [
      _actionBtn(
        'طلبات التذاكر',
        filled: true,
        onTap: () => WebNavController.to.openTicketRequests(e),
      ),
    ],
  );
}

// ════════════════════════════════════════════════════════════
//  Report detail — type-aware
// ════════════════════════════════════════════════════════════
class _ReportDetail extends StatelessWidget {
  final ReportModel r;
  const _ReportDetail({required this.r});

  @override
  Widget build(BuildContext context) {
    final rc = Get.find<ReportsController>();
    final content = ReportTypeHelper.of(r);

    return _DetailScaffold(
      title: r.title,
      badge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: content.accentColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(content.icon, size: 13, color: content.accentColor),
            const SizedBox(width: 5),
            Text(
              content.typeLabel,
              style: TextStyle(
                color: content.accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      children: [
        _desc(r.description),
        const SizedBox(height: 18),

        // ── Hero metric card ──────────────────────────────
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: AppColors.favoriteGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.kpis.first.value,
                    style: TextStyle(
                      color: WebTheme.text,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    content.kpis.first.label,
                    style: TextStyle(color: WebTheme.text70, fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: WebTheme.text.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+${r.trend}%',
                  style: TextStyle(
                    color: WebTheme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Sparkline chart ───────────────────────────────
        if (r.sparklineData.isNotEmpty) ...[
          _subHeader(content.chartTitle),
          const SizedBox(height: 12),
          Container(
            height: 130,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: WebTheme.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
            child: CustomPaint(
              size: Size.infinite,
              painter: _SparklinePainter(r.sparklineData),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // ── Info rows ─────────────────────────────────────
        _infoRow(Icons.storefront_rounded, 'الجناح', r.boothName),
        _infoRow(Icons.event_outlined, 'الفترة', r.period),
        _infoRow(Icons.access_time_rounded, 'تاريخ الإنشاء', r.createdAt),
        const SizedBox(height: 22),

        // ── KPIs — type-specific ──────────────────────────
        _subHeader('المؤشرات الرئيسية'),
        const SizedBox(height: 12),
        Row(
          children: content.kpis
              .map(
                (kpi) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: content.kpis.indexOf(kpi) < content.kpis.length - 1
                          ? 12
                          : 0,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: WebTheme.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text(
                          kpi.value,
                          style: TextStyle(
                            color: kpi.color,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          kpi.label,
                          style: TextStyle(color: AppColors.grey, fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                        if (kpi.trend.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            kpi.trend,
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 22),

        // ── Data table — type-specific ────────────────────
        _subHeader('البيانات التفصيلية'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: WebTheme.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Table(
            border: TableBorder.all(color: WebTheme.border, width: 0.5),
            children: [
              _webTableRow(content.tableHeaders, isHeader: true),
              ...content.tableRows.map((row) => _webTableRow(row)),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // ── Insights — type-specific ──────────────────────
        _subHeader('رؤى وتوصيات'),
        const SizedBox(height: 12),
        ...content.insights.map(
          (text) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.darkAccent,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: WebTheme.text,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      actions: [
        _actionBtn(
          'تصدير PDF (طباعة)',
          filled: true,
          onTap: () => rc.exportToPdf(r),
        ),
        const SizedBox(width: 12),
        Obx(
          () => _actionBtn(
            rc.isDownloading.value ? 'جارٍ التنزيل...' : 'تنزيل Excel',
            filled: false,
            onTap: () => rc.downloadReport(r.id, format: 'excel'),
          ),
        ),
      ],
    );
  }

  TableRow _webTableRow(List<String> cells, {bool isHeader = false}) =>
      TableRow(
        decoration: isHeader
            ? BoxDecoration(color: AppColors.darkPrimary.withOpacity(0.15))
            : null,
        children: cells
            .map(
              (cell) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Text(
                  cell,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isHeader ? FontWeight.w700 : FontWeight.w400,
                    color: isHeader ? AppColors.darkPrimary : WebTheme.text,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
            .toList(),
      );
}

// ── Sparkline painter ───────────────────────────────────────
class _SparklinePainter extends CustomPainter {
  final List<double> data;
  const _SparklinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final maxV = data.reduce((a, b) => a > b ? a : b);
    final minV = data.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV).abs() < 0.001 ? 1.0 : (maxV - minV);
    final dx = size.width / (data.length - 1);

    Offset pt(int i) =>
        Offset(i * dx, size.height - ((data[i] - minV) / range) * size.height);

    final path = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (var i = 1; i < data.length; i++) {
      path.lineTo(pt(i).dx, pt(i).dy);
    }

    // gradient fill under line
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.darkPrimary.withOpacity(0.4),
            AppColors.darkPrimary.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // line
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.darkPrimary, AppColors.darkSecondary],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // dots
    for (var i = 0; i < data.length; i++) {
      canvas.drawCircle(pt(i), 3, Paint()..color = AppColors.darkSecondary);
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.data != data;
}
