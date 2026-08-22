import 'dart:convert';
import '../../../core/constant/app_env.dart';

class SponsorDurationOption {
  final String label;
  final int days;
  final String? startDate;
  final String? endDate;
  final double price;

  SponsorDurationOption({
    required this.label,
    required this.days,
    this.startDate,
    this.endDate,
    required this.price,
  });

  factory SponsorDurationOption.fromJson(Map<String, dynamic> j) =>
      SponsorDurationOption(
        label: j['label'] ?? '',
        days: _toInt(j['days'], 1),
        startDate: j['start_date'] ?? j['startDate'],
        endDate: j['end_date'] ?? j['endDate'],
        price: _toDouble(j['price']),
      );

  static int _toInt(dynamic value, [int fallback = 0]) => value is num
      ? value.toInt()
      : int.tryParse(value?.toString() ?? '') ?? fallback;

  static double _toDouble(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0;

  Map<String, dynamic> toJson() => {
    'label': label,
    'days': days,
    'start_date': startDate,
    'end_date': endDate,
    'price': price,
  };
}

class ExhibitionSponsorEvent {
  final int id;
  final String name;
  final String type;
  final int exhibitionId;
  final String exhibitionName;
  final String exhibitionImageUrl;
  final String date;
  final String startTime;
  final String endTime;
  final String place;
  final int listingDays;
  final String description;
  final int capacity;
  final int registeredCount;
  final int scannedCount;
  final String ticketType;
  final double ticketPrice;
  final String status;
  final String? publishDate;
  final List<String> images;
  final List<Map<String, dynamic>> activities;
  final List<SponsorDurationOption> durationOptions;
  bool isFavorite;

  ExhibitionSponsorEvent({
    required this.id,
    required this.name,
    required this.type,
    required this.exhibitionId,
    required this.exhibitionName,
    required this.exhibitionImageUrl,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.place,
    required this.listingDays,
    required this.description,
    this.capacity = 0,
    this.registeredCount = 0,
    this.scannedCount = 0,
    this.ticketType = 'invitation',
    this.ticketPrice = 0,
    this.status = 'upcoming',
    this.publishDate,
    this.images = const [],
    this.activities = const [],
    required this.durationOptions,
    this.isFavorite = false,
  });

  factory ExhibitionSponsorEvent.fromJson(Map<String, dynamic> json) {
    final nested = json['event'] is Map
        ? Map<String, dynamic>.from(json['event'])
        : <String, dynamic>{};
    final j = {...nested, ...json};
    final images = _imageUrls(
      j['images'] ?? j['event_images'] ?? j['photos'] ?? j['eventImages'],
    );
    final activities = j['activities'] ?? j['programs'] ?? [];
    dynamic options =
        j['duration_options'] ??
        j['durationOptions'] ??
        j['sponsorshipOptions'] ??
        [];
    if (options is String && options.trim().isNotEmpty) {
      try {
        options = jsonDecode(options);
      } catch (_) {
        options = const [];
      }
    }
    if (options is! List || options.isEmpty) {
      final days = SponsorDurationOption._toInt(
        j['listing_days'] ?? j['duration_days'] ?? j['durationDays'],
      );
      final dailyPrice = SponsorDurationOption._toDouble(
        j['daily_price'] ?? j['dailyPrice'],
      );
      if (days > 0 && dailyPrice > 0) {
        options = List.generate(days, (index) {
          final optionDays = index + 1;
          return {
            'days': optionDays,
            'start_date': j['date'] ?? j['start_date'],
            'end_date': j['date'] ?? j['start_date'],
            'price': dailyPrice * optionDays,
          };
        });
      }
    }
    final start = (j['start_time'] ?? j['startAt'] ?? '').toString();
    final end = (j['end_time'] ?? j['endAt'] ?? '').toString();
    final exhibition = j['exhibition'];
    final directExhibitionName =
        (j['exhibition_name'] ?? j['exhibitionName'] ?? '').toString().trim();
    final nestedExhibitionName = exhibition is Map
        ? (exhibition['name'] ??
                  exhibition['title'] ??
                  exhibition['exhibition_name'] ??
                  '')
              .toString()
              .trim()
        : exhibition?.toString().trim() ?? '';
    final exhibitionName = directExhibitionName.isNotEmpty
        ? directExhibitionName
        : nestedExhibitionName;
    return ExhibitionSponsorEvent(
      id: SponsorDurationOption._toInt(j['id']),
      name: (j['name'] ?? j['title'] ?? '').toString(),
      type: (j['type'] ?? '').toString(),
      exhibitionId: SponsorDurationOption._toInt(
        j['exhibition_id'] ?? j['exhibitionId'],
      ),
      exhibitionName: exhibitionName.toString(),
      exhibitionImageUrl: _validUrl(
        j['exhibition_image_url'] ?? j['exhibitionImageUrl'],
      ),
      date: _dateOnly(j['date'] ?? j['start_date'] ?? start),
      startTime: _timeOnly(start),
      endTime: _timeOnly(end),
      place: (j['place'] ?? j['venueName'] ?? '').toString(),
      listingDays: SponsorDurationOption._toInt(
        j['listing_days'] ?? j['duration_days'] ?? j['durationDays'],
        1,
      ),
      description: (j['description'] ?? '').toString(),
      capacity: SponsorDurationOption._toInt(
        j['capacity'] ?? j['max_participants'],
      ),
      registeredCount: SponsorDurationOption._toInt(
        j['registered_count'] ?? j['registered'],
      ),
      scannedCount: SponsorDurationOption._toInt(
        j['scanned_count'] ?? j['attended'],
      ),
      ticketType: (j['ticket_type'] ?? j['ticketType'] ?? 'invitation')
          .toString(),
      ticketPrice: SponsorDurationOption._toDouble(
        j['ticket_price'] ?? j['ticketPrice'],
      ),
      status: (j['status'] ?? 'upcoming').toString(),
      publishDate: (j['publish_date'] ?? j['publishedAt'])?.toString(),
      images: images,
      activities: (activities is List ? activities : const [])
          .whereType<Map>()
          .map(Map<String, dynamic>.from)
          .toList(),
      durationOptions: (options is List ? options : const [])
          .whereType<Map>()
          .map(
            (o) => SponsorDurationOption.fromJson(Map<String, dynamic>.from(o)),
          )
          .toList(),
      isFavorite: j['is_favorite'] ?? false,
    );
  }

  static String _validUrl(dynamic value) {
    final url = value?.toString().trim() ?? '';
    if (url.startsWith('data:image/')) return url;
    final parsed = Uri.tryParse(url);
    if (parsed == null) return '';

    if (!parsed.hasScheme || parsed.host.isEmpty) {
      final apiUri = Uri.parse(AppEnv.baseUrl);
      final path = url.replaceFirst(RegExp(r'^/+'), '');
      final publicPath = path.startsWith('storage/')
          ? '/$path'
          : '/storage/$path';
      return apiUri.replace(path: publicPath).toString();
    }

    // Laravel may build local asset URLs from APP_URL=http://localhost.
    if (parsed.host == 'localhost' ||
        parsed.host == '127.0.0.1' ||
        parsed.host == '::1') {
      final apiUri = Uri.parse(AppEnv.baseUrl);
      return parsed
          .replace(
            scheme: apiUri.scheme,
            host: apiUri.host,
            port: apiUri.hasPort ? apiUri.port : null,
          )
          .toString();
    }
    return url;
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
    if (source is Map && source['data'] is List) {
      source = source['data'];
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
        .map(_validUrl)
        .where((image) => image.isNotEmpty)
        .toList();
  }

  static String _dateOnly(dynamic value) {
    final raw = value?.toString() ?? '';
    final parsed = DateTime.tryParse(raw);
    return parsed == null
        ? raw
        : raw.length >= 10
        ? raw.substring(0, 10)
        : raw;
  }

  static String _timeOnly(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
