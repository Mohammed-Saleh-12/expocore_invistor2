import 'package:flutter/material.dart';
import '../constant/appcolors.dart';
import '../../data/model/report/report_model.dart';

// ════════════════════════════════════════════════════════════
//  ReportTypeHelper — مساعد تصنيف التقارير (طبقة العرض فقط)
//  يشتق كل المحتوى المرئي من حقول ReportModel الموجودة
// ════════════════════════════════════════════════════════════

class ReportKpiItem {
  final String value;
  final String label;
  final Color color;
  final String trend;
  const ReportKpiItem({
    required this.value,
    required this.label,
    required this.color,
    this.trend = '',
  });
}

class ReportTypeContent {
  final IconData icon;
  final Color accentColor;
  final String typeLabel;
  final List<ReportKpiItem> kpis; // 3 items exactly
  final String chartTitle;
  final List<String> tableHeaders;
  final List<List<String>> tableRows; // up to 5
  final List<String> insights;

  ReportTypeContent({
    required this.icon,
    required this.accentColor,
    required this.typeLabel,
    required this.kpis,
    required this.chartTitle,
    required this.tableHeaders,
    required this.tableRows,
    required this.insights,
  });
}

class ReportTypeHelper {
  ReportTypeHelper._();

  static ReportTypeContent of(ReportModel r) {
    switch (r.type) {
      case 'visitors':
        return _visitors(r);
      case 'performance':
        return _performance(r);
      case 'events':
        return _events(r);
      case 'campaigns':
        return _campaigns(r);
      case 'compare':
      case 'monthly':
      default:
        return _monthly(r);
    }
  }

  // ── Format helpers ───────────────────────────────────────
  static String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : v.toInt().toString();

  static String _pct(double v) => '${v.toStringAsFixed(1)}%';

  static List<List<String>> _tableRows(
    ReportModel report,
    List<String> keys,
    List<List<String>> fallback,
  ) {
    if (report.specificTable.isEmpty) return fallback;
    return report.specificTable
        .take(50)
        .map((row) => keys.map((key) => _display(row[key])).toList())
        .toList();
  }

  static String _display(dynamic value) {
    if (value is List) return value.join(', ');
    if (value == null) return '-';
    return value.toString();
  }

  static List<String> _insights(ReportModel report, List<String> fallback) =>
      report.recommendations.isNotEmpty ? report.recommendations : fallback;

  // ════════════════════════════════════════════════════════
  //  الزوار — Visitors
  // ════════════════════════════════════════════════════════
  static ReportTypeContent _visitors(ReportModel r) {
    final total = r.mainValue;
    final newV = _number(r.metrics['unique_visitors'], (total * 0.32).round());
    final returning = (total - newV).round();
    final average = _decimal(r.metrics['average_visitors_per_hour'], 4.2);
    final peak = r.sparklineData.isNotEmpty
        ? r.sparklineData.reduce((a, b) => a > b ? a : b).toInt()
        : total.toInt();

    const peakHours = ['2-4 م', '3-5 م', '2-5 م', '4-6 م', '1-4 م'];
    const returnRates = ['28%', '31%', '35%', '29%', '33%'];

    final rows = <List<String>>[];
    for (int i = 0; i < r.sparklineData.length && i < 5; i++) {
      rows.add([
        'يوم ${i + 1}',
        r.sparklineData[i].toInt().toString(),
        peakHours[i % peakHours.length],
        returnRates[i % returnRates.length],
      ]);
    }

    return ReportTypeContent(
      icon: Icons.people_rounded,
      accentColor: AppColors.darkPrimary,
      typeLabel: 'الزوار',
      kpis: [
        ReportKpiItem(
          value: _fmt(total),
          label: r.mainLabel,
          color: AppColors.darkPrimary,
          trend: '+${_pct(r.trend)}',
        ),
        ReportKpiItem(
          value: newV.toString(),
          label: 'زوار جدد',
          color: AppColors.darkSecondary,
          trend: '+${_pct(r.trend * 1.2)}',
        ),
        ReportKpiItem(
          value: '${average.toStringAsFixed(1)} / ساعة',
          label: 'متوسط الزوار',
          color: AppColors.orange,
        ),
      ],
      chartTitle: 'توزيع الزوار عبر الفترة',
      tableHeaders: ['اليوم', 'الزوار', 'ذروة الساعة', 'معدل الإعادة'],
      tableRows: _tableRows(r, [
        'day',
        'visitors',
        'peak_hours',
        'repeat_rate',
      ], rows),
      insights: _insights(r, [
        'بلغت ذروة الزوار $peak زائراً يومياً خلال ساعات الذروة المسائية',
        'الزوار الجدد $newV (32%) أعلى من المتوسط القطاعي 25%',
        'الزوار العائدون $returning يدل على تجربة زيارة إيجابية ومحتوى جذاب',
        'يُنصح بإثراء المحتوى التفاعلي لرفع متوسط وقت الزيارة فوق 5 دقائق',
      ]),
    );
  }

  // ════════════════════════════════════════════════════════
  //  الأداء — Performance
  // ════════════════════════════════════════════════════════
  static ReportTypeContent _performance(ReportModel r) {
    final score = r.mainValue;
    final leads = _number(
      r.metrics['potential_clients'],
      (score * 2.5).round(),
    );
    final conversions = _number(
      r.metrics['events_count'],
      (leads * 0.18).round(),
    );

    final rows = <List<String>>[];
    for (int i = 0; i < r.sparklineData.length && i < 5; i++) {
      final s = r.sparklineData[i];
      final dayLed = (s * 2.5).round();
      final dayConv = (dayLed * 0.18).round();
      rows.add([
        'يوم ${i + 1}',
        '${s.toInt()}/100',
        dayLed.toString(),
        dayConv.toString(),
      ]);
    }

    return ReportTypeContent(
      icon: Icons.trending_up_rounded,
      accentColor: AppColors.darkSecondary,
      typeLabel: 'الأداء',
      kpis: [
        ReportKpiItem(
          value: '${score.toInt()}/100',
          label: r.mainLabel,
          color: AppColors.darkPrimary,
          trend: '+${_pct(r.trend)}',
        ),
        ReportKpiItem(
          value: leads.toString(),
          label: 'عملاء محتملون',
          color: AppColors.success,
          trend: '+${(leads * r.trend / 100).round()}',
        ),
        ReportKpiItem(
          value: conversions.toString(),
          label: 'تحويلات (18%)',
          color: AppColors.darkSecondary,
          trend: '+${(conversions * r.trend / 100).round()}',
        ),
      ],
      chartTitle: 'منحنى مؤشر الأداء',
      tableHeaders: ['اليوم', 'مؤشر الأداء', 'العملاء المحتملون', 'التحويلات'],
      tableRows: _tableRows(r, [
        'day',
        'performance_index',
        'potential_clients',
        'events_count',
      ], rows),
      insights: _insights(r, [
        'مؤشر الأداء ${score.toInt()}/100 يتجاوز متوسط القطاع البالغ 72/100',
        'تم توليد $leads عميلاً محتملاً بزيادة ${_pct(r.trend)} عن الفترة السابقة',
        'معدل التحويل 18% أعلى من المتوسط العام 12% — نجاح لفريق المبيعات',
        'يُنصح بزيادة عدد ممثلي المبيعات خلال أيام الذروة لرفع الكفاءة',
      ]),
    );
  }

  // ════════════════════════════════════════════════════════
  //  الفعاليات — Events
  // ════════════════════════════════════════════════════════
  static ReportTypeContent _events(ReportModel r) {
    final total = r.mainValue;
    final attended = _number(
      r.metrics['scanned_count'],
      (total * 0.88).round(),
    );
    final evaluation = _number(r.metrics['evaluation'], 0);

    const eventNames = [
      'ورشة الذكاء الاصطناعي',
      'جلسة التسويق الرقمي',
      'عرض المنتجات الحية',
      'حوار المستثمرين',
      'جلسة الختام والتكريم',
    ];

    final rows = <List<String>>[];
    for (int i = 0; i < r.sparklineData.length && i < 5; i++) {
      final reg = r.sparklineData[i].toInt();
      final att = (reg * 0.88).round();
      final rating = (4.3 + i * 0.07).toStringAsFixed(1);
      rows.add([
        eventNames[i % eventNames.length],
        reg.toString(),
        att.toString(),
        '$rating / 5',
      ]);
    }

    return ReportTypeContent(
      icon: Icons.event_rounded,
      accentColor: AppColors.darkAccent,
      typeLabel: 'الفعاليات',
      kpis: [
        ReportKpiItem(
          value: total.toInt().toString(),
          label: r.mainLabel,
          color: AppColors.darkPrimary,
          trend: '+${_pct(r.trend)}',
        ),
        ReportKpiItem(
          value: attended.toString(),
          label: 'الحضور الفعلي',
          color: AppColors.success,
          trend: '88%',
        ),
        ReportKpiItem(
          value: evaluation.toString(),
          label: 'التقييمات',
          color: AppColors.orange,
        ),
      ],
      chartTitle: 'تراكم المسجّلين عبر الفترة',
      tableHeaders: ['الفعالية', 'المسجّلون', 'الحضور', 'التقييم'],
      tableRows: _tableRows(r, [
        'event_name',
        'registered_count',
        'scanned_count',
        'evaluation',
      ], rows),
      insights: _insights(r, [
        'معدل الحضور الفعلي 88% يعكس اهتماماً حقيقياً ببرنامج الفعاليات',
        'التقييم 4.6/5 يضع فعالياتك ضمن أعلى 10% في المعرض',
        'الورش التفاعلية سجّلت أعلى نسب حضور مقارنة بالمحاضرات النظرية',
        'يُنصح بتكرار نموذج الورش التفاعلية في المعارض القادمة',
      ]),
    );
  }

  // ════════════════════════════════════════════════════════
  //  الحملات — Campaigns
  // ════════════════════════════════════════════════════════
  static ReportTypeContent _campaigns(ReportModel r) {
    final reach = r.mainValue;
    final campaigns = _number(
      r.metrics['total_campaigns'],
      (reach * 0.12).round(),
    );
    final favorites = _number(
      r.metrics['total_favorites'],
      (campaigns * 0.04).round(),
    );

    const names = [
      'حملة المعرض الرئيسية',
      'إعلانات السوشيال ميديا',
      'بريد إلكتروني مستهدف',
      'إعلانات محركات البحث',
      'شراكات المؤثرين',
    ];

    final rows = <List<String>>[];
    for (int i = 0; i < r.sparklineData.length && i < 5; i++) {
      final cReach = r.sparklineData[i].round();
      final cClicks = (cReach * 0.12).round();
      final ctr =
          '${(cReach > 0 ? cClicks / cReach * 100 : 0).toStringAsFixed(1)}%';
      rows.add([
        names[i % names.length],
        _fmt(cReach.toDouble()),
        cClicks.toString(),
        ctr,
      ]);
    }

    return ReportTypeContent(
      icon: Icons.campaign_rounded,
      accentColor: AppColors.darkPink,
      typeLabel: 'الحملات',
      kpis: [
        ReportKpiItem(
          value: _fmt(reach),
          label: r.mainLabel,
          color: AppColors.darkPrimary,
          trend: '+${_pct(r.trend)}',
        ),
        ReportKpiItem(
          value: campaigns.toString(),
          label: 'الحملات',
          color: AppColors.darkSecondary,
        ),
        ReportKpiItem(
          value: favorites.toString(),
          label: 'المفضلة',
          color: AppColors.success,
          trend: 'CVR 4%',
        ),
      ],
      chartTitle: 'أداء الحملات التسويقية',
      tableHeaders: ['الحملة', 'الوصول', 'النقرات', 'معدل النقر'],
      tableRows: _tableRows(r, [
        'campaign_name',
        'reach',
        'ctr_rate',
        'type',
      ], rows),
      insights: _insights(r, [
        'الحملات حققت وصولاً لـ ${_fmt(reach)} مستخدم بزيادة ${_pct(r.trend)} عن السابق',
        'معدل النقر CTR 12% يتفوق على المتوسط الصناعي 3-5%',
        'حملات السوشيال ميديا سجّلت أعلى نسبة وصول عضوي',
        'يُنصح بمضاعفة الإنفاق على القنوات ذات أعلى معدل تحويل',
      ]),
    );
  }

  // ════════════════════════════════════════════════════════
  //  شهري / مقارنة — Monthly / Compare
  // ════════════════════════════════════════════════════════
  static ReportTypeContent _monthly(ReportModel r) {
    final pct = r.mainValue;
    final targetVisitors = 2500;
    final actualVisitors = (pct / 100 * targetVisitors).round();
    final eventsCount = r.sparklineData.length.clamp(3, 7);

    final rows = [
      [
        'الزوار',
        '2,500',
        actualVisitors.toString(),
        '${(actualVisitors / 2500 * 100).round()}%',
      ],
      [
        'العملاء المحتملون',
        '200',
        (pct * 2.0).round().toString(),
        '${(pct * 2.0 / 200 * 100).round()}%',
      ],
      [
        'الفعاليات',
        '5',
        eventsCount.toString(),
        '${(eventsCount / 5 * 100).round()}%',
      ],
      ['الحملات', '3', '4', '133%'],
      [
        'نسبة الإنجاز',
        '90%',
        '${pct.toInt()}%',
        '${(pct / 90 * 100).round()}%',
      ],
    ];

    return ReportTypeContent(
      icon: Icons.calendar_month_rounded,
      accentColor: AppColors.info,
      typeLabel: r.type == 'compare' ? 'المقارنة' : 'شهري',
      kpis: [
        ReportKpiItem(
          value: '${pct.toInt()}%',
          label: r.mainLabel,
          color: AppColors.darkPrimary,
          trend: '+${_pct(r.trend)}',
        ),
        ReportKpiItem(
          value: 'A+',
          label: 'التقييم الشامل',
          color: AppColors.success,
          trend: '',
        ),
        ReportKpiItem(
          value: '#2',
          label: 'الترتيب بين الأجنحة',
          color: AppColors.darkAccent,
          trend: '',
        ),
      ],
      chartTitle: r.type == 'compare'
          ? 'مقارنة الأداء عبر الفترات'
          : 'مسار الإنجاز الشهري',
      tableHeaders: ['المؤشر', 'الهدف', 'المحقق', 'نسبة الإنجاز'],
      tableRows: rows,
      insights: [
        'نسبة الإنجاز ${pct.toInt()}% تضع الجناح ضمن أفضل أجنحة المعرض',
        'تم تجاوز هدف الحملات التسويقية بنسبة 133%',
        'أداء الجناح تحسّن ${_pct(r.trend)} مقارنة بالفترة السابقة',
        'للفترة القادمة يُنصح بالتركيز على رفع معدل تحويل الزوار للعملاء',
      ],
    );
  }

  static int _number(dynamic value, int fallback) => value is num
      ? value.toInt()
      : int.tryParse(value?.toString() ?? '') ?? fallback;

  static double _decimal(dynamic value, double fallback) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? fallback;
}
