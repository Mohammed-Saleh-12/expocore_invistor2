// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/report_type_helper.dart';
import '../../data/model/report/report_model.dart';

class PdfExportService {
  PdfExportService._();

  static String? _cachedFontBase64;

  static Future<void> printReport(ReportModel r, ReportTypeContent c) async {
    _cachedFontBase64 ??= await _loadFontBase64();
    final htmlContent = _buildHtml(r, c, _cachedFontBase64);
    final bytes  = utf8.encode(htmlContent);
    final blob   = html.Blob([bytes], 'text/html; charset=utf-8');
    final url    = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    Future.delayed(
      const Duration(seconds: 60),
      () => html.Url.revokeObjectUrl(url),
    );
  }

  static Future<String?> _loadFontBase64() async {
    try {
      final data = await rootBundle.load(
        'assets/fonts/Cairo-Regular.ttf',
      );
      return base64Encode(data.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  // ── HTML builder ──────────────────────────────────────────
  static String _buildHtml(ReportModel r, ReportTypeContent c, String? fontBase64) {
    final accent      = _hex(c.accentColor);
    final accentLight = _hex(c.accentColor.withOpacity(0.12));

    final kpiHtml = c.kpis.map((kpi) => '''
      <div class="kpi-box">
        <div class="kpi-value" style="color:${_hex(kpi.color)}">${kpi.value}</div>
        <div class="kpi-label">${_esc(kpi.label)}</div>
        ${kpi.trend.isNotEmpty ? '<div class="kpi-trend">${_esc(kpi.trend)}</div>' : ''}
      </div>''').join('');

    final tableHeaderHtml = c.tableHeaders
        .map((h) => '<th>${_esc(h)}</th>')
        .join('');
    final tableBodyHtml   = c.tableRows
        .map((row) =>
            '<tr>${row.map((cell) => '<td>${_esc(cell)}</td>').join('')}</tr>')
        .join('');

    final insightsHtml = c.insights.map((t) => '''
        <div class="insight">
          <span class="bulb">💡</span>
          <span class="insight-text">${_esc(t)}</span>
        </div>''').join('');

    // SVG chart — just the raw <svg> element (no section wrapper here)
    final svgHtml = r.sparklineData.length >= 2
        ? _svgChart(r.sparklineData, accent)
        : '';

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return '''<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>${_esc(r.title)}</title>
<style>
  ${fontBase64 != null ? "@font-face{font-family:'Cairo';src:url('data:font/truetype;base64,$fontBase64') format('truetype');font-weight:100 900;font-style:normal}" : ''}
  *{margin:0;padding:0;box-sizing:border-box}
  body{font-family:'Cairo','Arial',sans-serif;direction:rtl;background:#f4f4f8;color:#1a1a2e;min-height:100vh}

  /* ── Print settings ─────────────────────────────────── */
  @page{size:A4;margin:12mm 14mm}
  @media print{
    body{background:#fff}
    .print-btn{display:none!important}
    *{-webkit-print-color-adjust:exact;print-color-adjust:exact}
    .page{box-shadow:none;border-radius:0;padding:0}
    .section{break-inside:avoid}
  }

  /* ── Page wrapper ───────────────────────────────────── */
  .page{
    max-width:860px;margin:30px auto;background:#fff;
    border-radius:20px;overflow:hidden;
    box-shadow:0 4px 40px rgba(0,0,0,.12)
  }

  /* ── Header ─────────────────────────────────────────── */
  .header{
    background:linear-gradient(135deg,#7A1FFF 0%,#FF1592 100%);
    padding:32px 36px;color:#fff
  }
  .header-top{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px}
  .brand{font-size:12px;font-weight:900;letter-spacing:3px;opacity:.85}
  .type-badge{
    background:rgba(255,255,255,.22);border-radius:8px;
    padding:5px 14px;font-size:12px;font-weight:700;display:flex;align-items:center;gap:6px
  }
  .report-title{font-size:24px;font-weight:900;margin-bottom:8px;line-height:1.3}
  .report-sub{font-size:13px;opacity:.8;margin-bottom:4px}
  .trend-pill{
    display:inline-block;margin-top:10px;
    background:rgba(255,255,255,.22);border-radius:20px;
    padding:4px 14px;font-size:13px;font-weight:700
  }

  /* ── Body padding ───────────────────────────────────── */
  .body{padding:30px 36px}

  /* ── Description ────────────────────────────────────── */
  .description{
    background:#f8f8fc;border-radius:10px;padding:14px 18px;
    font-size:13px;color:#555;line-height:1.9;margin-bottom:24px;
    border-right:4px solid $accent
  }

  /* ── Section header ─────────────────────────────────── */
  .sec-title{
    font-size:14px;font-weight:800;color:#1a1a2e;
    border-right:4px solid $accent;padding-right:10px;margin-bottom:14px
  }

  /* ── KPIs ───────────────────────────────────────────── */
  .kpis{display:grid;grid-template-columns:repeat(3,1fr);gap:14px;margin-bottom:26px}
  .kpi-box{
    border:1.5px solid #e8e8f0;border-radius:12px;
    padding:18px 14px;text-align:center
  }
  .kpi-value{font-size:26px;font-weight:900}
  .kpi-label{font-size:11px;color:#777;margin-top:5px;line-height:1.4}
  .kpi-trend{font-size:11px;color:#4CAF50;font-weight:700;margin-top:5px}

  /* ── Sections ───────────────────────────────────────── */
  .section{
    border:1.5px solid #e8e8f0;border-radius:12px;
    padding:20px;margin-bottom:22px;overflow:hidden
  }

  /* ── Table ───────────────────────────────────────────── */
  table{width:100%;border-collapse:collapse;font-size:12px}
  thead tr{background:$accentLight}
  th{padding:10px 12px;font-weight:800;text-align:center;color:$accent;border:1px solid #e8e8f0}
  td{padding:9px 12px;text-align:center;border:1px solid #e8e8f0;color:#333}
  tr:nth-child(even) td{background:#f9f9fc}

  /* ── Insights ───────────────────────────────────────── */
  .insight{display:flex;align-items:flex-start;gap:10px;margin-bottom:12px}
  .bulb{font-size:16px;flex-shrink:0;padding-top:2px}
  .insight-text{font-size:13px;line-height:1.9;color:#333}

  /* ── Footer ─────────────────────────────────────────── */
  .footer{
    padding:18px 36px;border-top:1.5px solid #e8e8f0;
    display:flex;justify-content:space-between;flex-wrap:wrap;gap:8px;
    font-size:11px;color:#aaa;background:#fafafa
  }

  /* ── Print button ───────────────────────────────────── */
  .print-btn{
    position:fixed;bottom:28px;left:28px;z-index:999;
    background:linear-gradient(135deg,#7A1FFF,#FF1592);
    color:#fff;border:none;border-radius:12px;
    padding:13px 26px;font-size:14px;font-weight:700;
    cursor:pointer;font-family:'Cairo',sans-serif;
    box-shadow:0 4px 20px rgba(122,31,255,.4);
    display:flex;align-items:center;gap:8px
  }
  .print-btn:hover{opacity:.92;transform:translateY(-1px)}
</style>
<script>window.addEventListener('load',()=>setTimeout(()=>window.print(),700))</script>
</head>
<body>

<button class="print-btn" onclick="window.print()">🖨️ طباعة / حفظ PDF</button>

<div class="page">

  <!-- ── Header ── -->
  <div class="header">
    <div class="header-top">
      <span class="brand">EXPOCORE</span>
      <span class="type-badge">${_esc(c.typeLabel)}</span>
    </div>
    <div class="report-title">${_esc(r.title)}</div>
    <div class="report-sub">${_esc(r.boothName)} &bull; ${_esc(r.exhibitionName)}</div>
    <div class="report-sub">الفترة: ${_esc(r.period)}</div>
    <span class="trend-pill">&#x25B2; ${r.trend.toStringAsFixed(1)}% نمو</span>
  </div>

  <!-- ── Body ── -->
  <div class="body">

    <!-- Description -->
    <div class="description">${_esc(r.description)}</div>

    <!-- KPIs -->
    <div class="sec-title">المؤشرات الرئيسية</div>
    <div class="kpis">$kpiHtml</div>

    <!-- Chart (only when data is available) -->
    ${svgHtml.isNotEmpty ? '''
    <div class="section">
      <div class="sec-title">${_esc(c.chartTitle)}</div>
      $svgHtml
    </div>''' : ''}

    <!-- Data table -->
    <div class="section">
      <div class="sec-title">البيانات التفصيلية</div>
      <table>
        <thead><tr>$tableHeaderHtml</tr></thead>
        <tbody>$tableBodyHtml</tbody>
      </table>
    </div>

    <!-- Insights -->
    <div class="section">
      <div class="sec-title">رؤى وتوصيات</div>
      $insightsHtml
    </div>

  </div><!-- /.body -->

  <!-- ── Footer ── -->
  <div class="footer">
    <span>EXPOCORE Investor Platform</span>
    <span>${_esc(r.title)}</span>
    <span>تاريخ التصدير: $dateStr</span>
  </div>

</div><!-- /.page -->

</body>
</html>''';
  }

  // ── Helpers ───────────────────────────────────────────────
  static String _hex(Color color) =>
      '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';

  static String _esc(String text) => text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');

  // Returns only the <svg> element — the caller wraps it in .section
  // Builds a smooth cubic-bezier sparkline from the actual [data] values.
  static String _svgChart(List<double> data, String accent) {
    if (data.length < 2) return '';

    const double xMin  = 10;
    const double xMax  = 490;
    const double yMin  = 10;   // top of chart area
    const double yMax  = 120;  // bottom of chart area
    const double yFill = 132;  // fill extends a little below chart area

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range  = (maxVal - minVal) == 0 ? 1.0 : maxVal - minVal;
    final n      = data.length;

    // Compute (x, y) for each data point
    final pts = List.generate(n, (i) {
      final x = xMin + (xMax - xMin) * i / (n - 1);
      final y = yMax - (yMax - yMin) * (data[i] - minVal) / range;
      return [x, y];
    });

    // Build smooth cubic-bezier path
    final sb = StringBuffer();
    sb.write('M${_f(pts[0][0])},${_f(pts[0][1])}');
    for (int i = 1; i < pts.length; i++) {
      final cp1x = (pts[i - 1][0] + pts[i][0]) / 2;
      final cp1y = pts[i - 1][1];
      final cp2x = (pts[i - 1][0] + pts[i][0]) / 2;
      final cp2y = pts[i][1];
      sb.write(' C${_f(cp1x)},${_f(cp1y)} ${_f(cp2x)},${_f(cp2y)} ${_f(pts[i][0])},${_f(pts[i][1])}');
    }
    final linePath = sb.toString();
    final fillPath =
        '$linePath L${_f(pts.last[0])},$yFill L${_f(pts.first[0])},$yFill Z';

    return '''<svg viewBox="0 0 500 140" width="100%" height="180"
        role="img" aria-label="Sparkline chart">
      <defs>
        <linearGradient id="chartGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="$accent" stop-opacity="0.85"/>
          <stop offset="100%" stop-color="$accent" stop-opacity="0.08"/>
        </linearGradient>
      </defs>
      <!-- grid lines -->
      <line x1="10" y1="43"  x2="490" y2="43"  stroke="#e0e0ee" stroke-width="1"/>
      <line x1="10" y1="76"  x2="490" y2="76"  stroke="#e0e0ee" stroke-width="1"/>
      <line x1="10" y1="109" x2="490" y2="109" stroke="#e0e0ee" stroke-width="1"/>
      <!-- fill area -->
      <path d="$fillPath" fill="url(#chartGrad)"/>
      <!-- trend line -->
      <path d="$linePath"
            fill="none" stroke="$accent" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>''';
  }

  static String _f(double v) => v.toStringAsFixed(1);
}
