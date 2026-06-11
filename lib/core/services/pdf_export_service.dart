// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/report_type_helper.dart';
import '../../data/model/report/report_model.dart';

// ════════════════════════════════════════════════════════════
//  PdfExportService — تصدير التقرير بصيغة PDF عبر window.print()
//  يبني صفحة HTML منسّقة RTL مع مخطط SVG ويفتحها في تبويب جديد
// ════════════════════════════════════════════════════════════
class PdfExportService {
  PdfExportService._();

  static void printReport(ReportModel r, ReportTypeContent c) {
    final htmlContent = _buildHtml(r, c);
    final bytes       = utf8.encode(htmlContent);
    final blob        = html.Blob([bytes], 'text/html; charset=utf-8');
    final url         = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..target = '_blank'
      ..click();

    Future.delayed(const Duration(seconds: 60),
        () => html.Url.revokeObjectUrl(url));
  }

  // ── HTML builder ─────────────────────────────────────────
  static String _buildHtml(ReportModel r, ReportTypeContent c) {
    final accent = _hex(c.accentColor);
    final accentLight =
        _hex(c.accentColor.withOpacity(0.12)); // for table header tint

    final kpiHtml = c.kpis.map((kpi) => '''
      <div class="kpi-box">
        <div class="kpi-value" style="color:${_hex(kpi.color)}">${kpi.value}</div>
        <div class="kpi-label">${kpi.label}</div>
        ${kpi.trend.isNotEmpty ? '<div class="kpi-trend">${_esc(kpi.trend)}</div>' : ''}
      </div>''').join('');

    final tableHeaderHtml =
        c.tableHeaders.map((h) => '<th>${_esc(h)}</th>').join('');
    final tableBodyHtml = c.tableRows
        .map((row) =>
            '<tr>${row.map((cell) => '<td>${_esc(cell)}</td>').join('')}</tr>')
        .join('');

    final insightsHtml = c.insights
        .map((t) => '''
        <div class="insight">
          <span class="bulb">💡</span>
          <span class="insight-text">${_esc(t)}</span>
        </div>''')
        .join('');

    final chartHtml = r.sparklineData.length >= 2
        ? _svgChart(r.sparklineData, accent)
        : '';

    return '''<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>${_esc(r.title)}</title>
<link href="https://fonts.googleapis.com/css2?family=Tajawal:wght@400;500;700;800;900&display=swap" rel="stylesheet">
<style>
  *{margin:0;padding:0;box-sizing:border-box}
  body{font-family:'Tajawal','Arial',sans-serif;direction:rtl;background:#f4f4f8;color:#1a1a2e;min-height:100vh}

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

  /* ── Chart section ──────────────────────────────────── */
  .section{
    border:1.5px solid #e8e8f0;border-radius:12px;
    padding:20px;margin-bottom:22px;overflow:hidden
  }

  /* ── Table ──────────────────────────────────────────── */
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
    margin-top:28px;padding-top:18px;border-top:1.5px solid #e8e8f0;
    display:flex;justify-content:space-between;flex-wrap:wrap;gap:8px;
    font-size:11px;color:#aaa
  }

  /* ── Print button ───────────────────────────────────── */
  .print-btn{
    position:fixed;bottom:28px;left:28px;z-index:999;
    background:linear-gradient(135deg,#7A1FFF,#FF1592);
    color:#fff;border:none;border-radius:12px;
    padding:13px 26px;font-size:14px;font-weight:700;
    cursor:pointer;font-family:'Tajawal',sans-serif;
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

  <div class="body">

    <!-- ── Description ── -->
    <div class="description">${_esc(r.description)}</div>

    <!-- ── KPIs ── -->
    <div class="sec-title">المؤشرات الرئيسية</div>
    <div class="kpis">$kpiHtml</div>

    <!-- ── Chart ── -->
    ${chartHtml.isNotEmpty ? '''
    <div class="section">
      <div class="sec-title">${_esc(c.chartTitle)}</div>
      $chartHtml
    </div>''' : ''}

    <!-- ── Table ── -->
    <div class="section">
      <div class="sec-title">البيانات التفصيلية</div>
      <table>
        <thead><tr>$tableHeaderHtml</tr></thead>
        <tbody>$tableBodyHtml</tbody>
      </table>
    </div>

    <!-- ── Insights ── -->
    <div class="section">
      <div class="sec-title">رؤى وتوصيات</div>
      $insightsHtml
    </div>

    <!-- ── Footer ── -->
    <div class="footer">
      <span>منصة ExpoCore للمستثمرين &copy; 2026</span>
      <span>تاريخ الإنشاء: ${_esc(r.createdAt)}</span>
      <span>رقم التقرير: ${_esc(r.id)}</span>
    </div>

  </div><!-- /body -->
</div><!-- /page -->
</body>
</html>''';
  }

  // ── SVG sparkline chart ──────────────────────────────────
  static String _svgChart(List<double> data, String accent) {
    const w = 800.0, h = 150.0, pad = 16.0;

    final maxV  = data.reduce((a, b) => a > b ? a : b);
    final minV  = data.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV) == 0 ? 1.0 : (maxV - minV);

    double px(int i) =>
        pad + (w - pad * 2) * i / (data.length - 1);
    double py(int i) =>
        h - pad - (h - pad * 2) * (data[i] - minV) / range;

    final pts = List.generate(data.length, (i) =>
        '${px(i).toStringAsFixed(1)},${py(i).toStringAsFixed(1)}').join(' ');

    final fillPts =
        '$pts ${px(data.length - 1).toStringAsFixed(1)},${h.toStringAsFixed(1)} '
        '${pad.toStringAsFixed(1)},${h.toStringAsFixed(1)}';

    final gridLines = List.generate(
      4,
      (i) {
        final y = (h - pad) - (h - pad * 2) * i / 3;
        final val = minV + range * i / 3;
        return '<line x1="$pad" y1="${y.toStringAsFixed(1)}" '
            'x2="${(w - pad).toStringAsFixed(1)}" y2="${y.toStringAsFixed(1)}" '
            'stroke="#e8e8f0" stroke-width="1"/>'
            '<text x="${pad.toStringAsFixed(0)}" y="${(y - 3).toStringAsFixed(0)}" '
            'font-size="9" fill="#aaa" direction="ltr">${val.toInt()}</text>';
      },
    ).join('');

    final dots = List.generate(
      data.length,
      (i) => '<circle cx="${px(i).toStringAsFixed(1)}" cy="${py(i).toStringAsFixed(1)}" '
          'r="4" fill="$accent" stroke="#fff" stroke-width="2"/>',
    ).join('');

    return '''<svg width="100%" viewBox="0 0 $w $h" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="cg" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="$accent" stop-opacity="0.28"/>
      <stop offset="100%" stop-color="$accent" stop-opacity="0.02"/>
    </linearGradient>
  </defs>
  $gridLines
  <polygon points="$fillPts" fill="url(#cg)"/>
  <polyline points="$pts" fill="none" stroke="$accent" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
  $dots
</svg>''';
  }

  // ── Helpers ──────────────────────────────────────────────
  static String _hex(Color c) {
    final rgb = c.value & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0')}';
  }

  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
