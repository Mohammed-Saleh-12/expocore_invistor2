import '../event/exhibition_sponsor_event_model.dart';
import '../../../core/constant/app_env.dart';
import 'dart:convert';

class ExhibitionModel {
  final int id;
  final String name;
  final String description;
  // ── Multi-image support ──────────────────────────────────────
  final List<String> images; // قائمة الصور (الأولى تُعرض في الكرت)
  // ── Dynamic services from API ────────────────────────────────
  final List<String> services; // خدمات المعرض من الـ API
  // ── Map data embedded in detail response ─────────────────────
  final Map<String, dynamic>? mapJson; // بيانات الخريطة 3D
  // ── Sponsor events embedded in detail response ───────────────
  final List<ExhibitionSponsorEvent> sponsorEvents;
  // ── Standard fields ──────────────────────────────────────────
  final String startDate;
  final String endDate;
  final String location;
  final String city;
  final String status;
  final int availableBooths;
  final List<String> sectors;
  bool isFavorite;

  ExhibitionModel({
    required this.id,
    required this.name,
    required this.description,
    this.images = const [],
    this.services = const [],
    this.mapJson,
    this.sponsorEvents = const [],
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.city,
    required this.status,
    required this.availableBooths,
    required this.sectors,
    this.isFavorite = false,
  });

  // ── imageUrl for backward-compatibility with cards/views ──────
  /// يُعيد أول صورة أو String فارغ — لا كسر للكود القديم
  String get imageUrl => images.isNotEmpty ? images.first : '';

  // ── Domain helpers ────────────────────────────────────────────
  String get statusLabel {
    switch (status) {
      case 'active':
        return 'جارٍ';
      case 'upcoming':
        return 'قادم';
      case 'ended':
        return 'منتهٍ';
      case 'hidden':
        return 'مخفي';
      default:
        return status.isEmpty ? 'غير محدد' : status;
    }
  }

  static String normalizeStatus(
    dynamic value, {
    String? startDate,
    String? endDate,
  }) {
    final raw = value?.toString().trim().toLowerCase() ?? '';
    if (raw == 'hidden') return 'hidden';

    // Dates are authoritative for lifecycle states when available. This also
    // corrects stale stored values such as "upcoming" after the end date.
    final start = DateTime.tryParse(startDate ?? '');
    final end = DateTime.tryParse(endDate ?? '');
    if (start != null || end != null) {
      final today = _dateOnly(DateTime.now());
      if (start != null && today.isBefore(_dateOnly(start))) {
        return 'upcoming';
      }
      if (end != null && today.isAfter(_dateOnly(end))) {
        return 'ended';
      }
      return 'active';
    }

    switch (raw) {
      case 'active':
      case 'ongoing':
      case 'live':
        return 'active';
      case 'far':
      case 'upcoming':
      case 'scheduled':
      case 'pending':
      case 'planned':
      case 'not_started':
      case 'not-started':
        return 'upcoming';
      case 'ended':
      case 'finished':
      case 'completed':
        return 'ended';
      default:
        return 'ended';
    }
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  factory ExhibitionModel.fromJson(Map<String, dynamic> j) {
    // ── Images: يقبل images (list) أو image_url (string قديم) ──
    List<String> imgs;
    if (j['images'] is List) {
      imgs = _imageUrls(j['images']);
    } else if ((j['image_url'] ?? '').toString().isNotEmpty) {
      imgs = _imageUrls([j['image_url']]);
    } else {
      imgs = [];
    }

    // ── Sponsor events ────────────────────────────────────────
    List<ExhibitionSponsorEvent> events = [];
    if (j['sponsor_events'] is List) {
      events = (j['sponsor_events'] as List)
          .map(
            (e) => ExhibitionSponsorEvent.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    }

    return ExhibitionModel(
      id: int.tryParse((j['id'] ?? 0).toString()) ?? 0,
      name: j['name'] ?? '',
      description: j['description'] ?? '',
      images: imgs,
      services: List<String>.from(j['services'] ?? []),
      mapJson: j['map_data'] is Map<String, dynamic>
          ? j['map_data'] as Map<String, dynamic>
          : null,
      sponsorEvents: events,
      startDate: j['start_date'] ?? '',
      endDate: j['end_date'] ?? '',
      location: j['location'] ?? '',
      city: j['city'] ?? '',
      status: normalizeStatus(
        j['status'],
        startDate: j['start_date']?.toString(),
        endDate: j['end_date']?.toString(),
      ),
      availableBooths: j['available_booths'] ?? 0,
      sectors: List<String>.from(j['sectors'] ?? []),
      isFavorite: j['is_favorite'] ?? false,
    );
  }

  static List<String> _imageUrls(dynamic value) {
    dynamic source = value;
    if (source is String && source.trim().isNotEmpty) {
      try {
        source = jsonDecode(source);
      } catch (_) {
        source = [source];
      }
    }
    if (source is! List) return const [];

    return source
        .map((image) {
          if (image is Map) {
            return image['url'] ??
                image['image_url'] ??
                image['imageUrl'] ??
                image['image'] ??
                '';
          }
          return image;
        })
        .map((image) => _validUrl(image))
        .where((image) => image.isNotEmpty)
        .toList();
  }

  static String _validUrl(dynamic value) {
    final url = value?.toString().trim() ?? '';
    if (url.isEmpty || url.startsWith('data:')) return url;
    final parsed = Uri.tryParse(url);
    if (parsed == null) return '';
    if (parsed.hasScheme && parsed.host.isNotEmpty) return url;

    final apiUri = Uri.parse(AppEnv.baseUrl);
    final path = url.replaceFirst(RegExp(r'^/+'), '');
    return apiUri
        .replace(
          path: path.startsWith('storage/') ? '/$path' : '/storage/$path',
        )
        .toString();
  }
}
