import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../data/model/exhibition/exhibition_model.dart';
import '../../data/model/event/exhibition_sponsor_event_model.dart';
import '../../data/sourcedata/remote/Dashboard/HomeBillboardData.dart';

/// يدير جلب بيانات اللوحتين الإعلانيتين في الصفحة الرئيسية:
///   • لوحة المعارض المميزة      ← GET /exhibitions/featured
///   • لوحة الفعاليات الإعلانية  ← GET /investor/sponsor-events/featured
///
/// كلاهما يعتمد Pagination بـ 5 عناصر في كل استدعاء.
class HomeBillboardController extends GetxController {
  final HomeBillboardData _data = HomeBillboardData(Crud());

  // ── المعارض المميزة ──────────────────────────────────────────────────
  final featuredExhibitions         = <ExhibitionModel>[].obs;
  final isLoadingExhibitions        = false.obs;
  final isLoadingMoreExhibitions    = false.obs;
  int  _exhibitionsPage             = 1;
  int  _exhibitionsTotalPages       = 1;
  bool get hasMoreExhibitions       => _exhibitionsPage < _exhibitionsTotalPages;

  // ── الفعاليات الإعلانية المميزة ──────────────────────────────────────
  final featuredSponsorEvents       = <ExhibitionSponsorEvent>[].obs;
  final isLoadingSponsorEvents      = false.obs;
  final isLoadingMoreSponsorEvents  = false.obs;
  int  _sponsorEventsPage           = 1;
  int  _sponsorEventsTotalPages     = 1;
  bool get hasMoreSponsorEvents     => _sponsorEventsPage < _sponsorEventsTotalPages;

  // ── حجم الصفحة (ثابت) ────────────────────────────────────────────────
  static const int _perPage = 5;

  @override
  void onInit() {
    _loadInitial();
    super.onInit();
  }

  // ════════════════════════════════════════════════════════════════════════
  //  التحميل الأوّلي (الصفحة 1 لكليهما بالتوازي)
  // ════════════════════════════════════════════════════════════════════════
  Future<void> _loadInitial() async {
    await Future.wait([
      _fetchExhibitions(page: 1),
      _fetchSponsorEvents(page: 1),
    ]);
  }

  // ════════════════════════════════════════════════════════════════════════
  //  المعارض المميزة
  // ════════════════════════════════════════════════════════════════════════

  Future<void> _fetchExhibitions({required int page}) async {
    final isFirst = page == 1;
    if (isFirst) {
      isLoadingExhibitions.value = true;
    } else {
      isLoadingMoreExhibitions.value = true;
    }

    final result = await _data.getFeaturedExhibitions(
      page:    page,
      perPage: _perPage,
    );

    if (result['status'] == true) {
      final body   = result['data'];
      final list   = _asList(body is Map ? (body['data'] ?? body) : body);
      final models = list.map((e) => ExhibitionModel.fromJson(e)).toList();

      if (isFirst) {
        featuredExhibitions.value = models;
      } else {
        featuredExhibitions.addAll(models);
      }

      // تحديث إجمالي الصفحات من meta
      if (body is Map) {
        final meta = body['meta'] ?? body['pagination'] ?? {};
        _exhibitionsTotalPages =
            meta['last_page'] ?? meta['total_pages'] ?? 1;
      }
      _exhibitionsPage = page;
    }

    isLoadingExhibitions.value     = false;
    isLoadingMoreExhibitions.value = false;
  }

  /// يُحمِّل الصفحة الأولى من المعارض من جديد (سحب للتحديث)
  Future<void> refreshExhibitions() async {
    _exhibitionsPage       = 1;
    _exhibitionsTotalPages = 1;
    await _fetchExhibitions(page: 1);
  }

  /// يُحمِّل الصفحة التالية من المعارض (تُستدعى عند الوصول للعنصر الأخير)
  Future<void> loadMoreExhibitions() async {
    if (!hasMoreExhibitions || isLoadingMoreExhibitions.value) return;
    await _fetchExhibitions(page: _exhibitionsPage + 1);
  }

  // ════════════════════════════════════════════════════════════════════════
  //  الفعاليات الإعلانية المميزة
  // ════════════════════════════════════════════════════════════════════════

  Future<void> _fetchSponsorEvents({required int page}) async {
    final isFirst = page == 1;
    if (isFirst) {
      isLoadingSponsorEvents.value = true;
    } else {
      isLoadingMoreSponsorEvents.value = true;
    }

    final result = await _data.getFeaturedSponsorEvents(
      page:    page,
      perPage: _perPage,
    );

    if (result['status'] == true) {
      final body   = result['data'];
      final list   = _asList(body is Map ? (body['data'] ?? body) : body);
      final models =
          list.map((e) => ExhibitionSponsorEvent.fromJson(e)).toList();

      if (isFirst) {
        featuredSponsorEvents.value = models;
      } else {
        featuredSponsorEvents.addAll(models);
      }

      // تحديث إجمالي الصفحات من meta
      if (body is Map) {
        final meta = body['meta'] ?? body['pagination'] ?? {};
        _sponsorEventsTotalPages =
            meta['last_page'] ?? meta['total_pages'] ?? 1;
      }
      _sponsorEventsPage = page;
    }

    isLoadingSponsorEvents.value     = false;
    isLoadingMoreSponsorEvents.value = false;
  }

  /// يُحمِّل الصفحة الأولى من الفعاليات من جديد (سحب للتحديث)
  Future<void> refreshSponsorEvents() async {
    _sponsorEventsPage       = 1;
    _sponsorEventsTotalPages = 1;
    await _fetchSponsorEvents(page: 1);
  }

  /// يُحمِّل الصفحة التالية من الفعاليات (تُستدعى عند الوصول للعنصر الأخير)
  Future<void> loadMoreSponsorEvents() async {
    if (!hasMoreSponsorEvents || isLoadingMoreSponsorEvents.value) return;
    await _fetchSponsorEvents(page: _sponsorEventsPage + 1);
  }

  // ════════════════════════════════════════════════════════════════════════
  //  مساعد
  // ════════════════════════════════════════════════════════════════════════
  List<dynamic> _asList(dynamic d) {
    if (d is List) return d;
    if (d is Map && d['data'] is List) return d['data'] as List;
    return [];
  }
}
