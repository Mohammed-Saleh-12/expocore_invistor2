import 'package:flutter/material.dart';
import '../../../data/model/map/exhibition_map_model.dart';

class BoothHitArea {
  final MapBoothModel booth;
  final Path topFacePath;
  BoothHitArea(this.booth, this.topFacePath);
}

class IsometricMapPainter extends CustomPainter {
  final ExhibitionMapModel mapModel;
  final MapBoothModel? selectedBooth;
  final List<BoothHitArea> hitAreas;
  final bool isDark;

  static const double tileW   = 72.0;
  static const double tileH   = 36.0;
  static const double boxUnit = 28.0;

  IsometricMapPainter({
    required this.mapModel,
    required this.selectedBooth,
    required this.hitAreas,
    required this.isDark,
  });

  Offset _iso(double col, double row, double elevation, Offset origin) {
    final x = (col - row) * (tileW / 2) + origin.dx;
    final y = (col + row) * (tileH / 2) - elevation * boxUnit + origin.dy;
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    hitAreas.clear();

    final origin = Offset(size.width / 2, size.height * 0.18);

    _drawGround(canvas, size, origin);
    _drawHallLabels(canvas, origin);

    final sorted = List<MapBoothModel>.from(
      mapModel.halls.expand((h) => h.booths),
    )..sort((a, b) => (a.row + a.col).compareTo(b.row + b.col));

    for (final booth in sorted) {
      final hall = mapModel.halls.firstWhere(
        (h) => h.id == booth.hallId,
        orElse: () => mapModel.halls.first,
      );
      _drawBooth(canvas, booth, hall.color, origin);
    }

    _drawEntrance(canvas, origin);
  }

  void _drawGround(Canvas canvas, Size size, Offset origin) {
    final w = mapModel.gridWidth.toDouble();
    final d = mapModel.gridDepth.toDouble();

    final groundPaint = Paint()
      ..color = isDark
          ? const Color(0xFF1E1B35)
          : const Color(0xFFEAEAF0)
      ..style = PaintingStyle.fill;

    final groundPath = Path()
      ..moveTo(_iso(0, 0, 0, origin).dx, _iso(0, 0, 0, origin).dy)
      ..lineTo(_iso(w, 0, 0, origin).dx, _iso(w, 0, 0, origin).dy)
      ..lineTo(_iso(w, d, 0, origin).dx, _iso(w, d, 0, origin).dy)
      ..lineTo(_iso(0, d, 0, origin).dx, _iso(0, d, 0, origin).dy)
      ..close();

    canvas.drawPath(groundPath, groundPaint);

    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int c = 0; c <= mapModel.gridWidth; c++) {
      final start = _iso(c.toDouble(), 0, 0, origin);
      final end   = _iso(c.toDouble(), d, 0, origin);
      canvas.drawLine(start, end, gridPaint);
    }
    for (int r = 0; r <= mapModel.gridDepth; r++) {
      final start = _iso(0, r.toDouble(), 0, origin);
      final end   = _iso(w, r.toDouble(), 0, origin);
      canvas.drawLine(start, end, gridPaint);
    }
  }

  void _drawBooth(
    Canvas canvas,
    MapBoothModel booth,
    Color hallColor,
    Offset origin,
  ) {
    final c  = booth.col.toDouble();
    final r  = booth.row.toDouble();
    final bw = booth.gridWidth.toDouble();
    final bd = booth.gridDepth.toDouble();
    final h  = booth.height;
    final isSelected = selectedBooth?.id == booth.id;

    Color topColor, leftColor, rightColor, outlineColor;

    if (isSelected && booth.isBooked) {
      topColor    = isDark ? const Color(0xFF52407A) : const Color(0xFFDDD0F5);
      leftColor   = isDark ? const Color(0xFF3D2E60) : const Color(0xFFCCBCEE);
      rightColor  = isDark ? const Color(0xFF2E2250) : const Color(0xFFBBADE0);
      outlineColor = const Color(0xFF9B59F5);
    } else if (isSelected) {
      topColor    = const Color(0xFF9B59F5);
      leftColor   = const Color(0xFF7A1FFF);
      rightColor  = const Color(0xFF5D0FCC);
      outlineColor = const Color(0xFFFFD700);
    } else if (booth.isBooked) {
      topColor    = isDark ? const Color(0xFF3A3650) : const Color(0xFFCCCCCC);
      leftColor   = isDark ? const Color(0xFF2A2640) : const Color(0xFFBBBBBB);
      rightColor  = isDark ? const Color(0xFF222035) : const Color(0xFFAAAAAA);
      outlineColor = Colors.transparent;
    } else {
      topColor    = hallColor.withOpacity(0.85);
      leftColor   = _darken(hallColor, 0.25);
      rightColor  = _darken(hallColor, 0.42);
      outlineColor = Colors.transparent;
    }

    final A  = _iso(c,      r,      h, origin);
    final B  = _iso(c + bw, r,      h, origin);
    final C  = _iso(c + bw, r + bd, h, origin);
    final D  = _iso(c,      r + bd, h, origin);
    final C0 = _iso(c + bw, r + bd, 0, origin);
    final D0 = _iso(c,      r + bd, 0, origin);
    final B0 = _iso(c + bw, r,      0, origin);

    final southFace = Path()
      ..moveTo(D.dx,  D.dy)
      ..lineTo(C.dx,  C.dy)
      ..lineTo(C0.dx, C0.dy)
      ..lineTo(D0.dx, D0.dy)
      ..close();

    final eastFace = Path()
      ..moveTo(B.dx,  B.dy)
      ..lineTo(C.dx,  C.dy)
      ..lineTo(C0.dx, C0.dy)
      ..lineTo(B0.dx, B0.dy)
      ..close();

    final topFace = Path()
      ..moveTo(A.dx, A.dy)
      ..lineTo(B.dx, B.dy)
      ..lineTo(C.dx, C.dy)
      ..lineTo(D.dx, D.dy)
      ..close();

    if (isSelected) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD700).withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawPath(topFace, glowPaint);
    }

    canvas.drawPath(southFace, Paint()..color = leftColor..style = PaintingStyle.fill);
    canvas.drawPath(eastFace,  Paint()..color = rightColor..style = PaintingStyle.fill);
    canvas.drawPath(topFace,   Paint()..color = topColor..style = PaintingStyle.fill);

    if (isSelected) {
      canvas.drawPath(topFace, Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8);
    } else {
      final edgePaint = Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawPath(southFace, edgePaint);
      canvas.drawPath(eastFace,  edgePaint);
      canvas.drawPath(topFace,   edgePaint);
    }

    // Only show label on available booths (or selected booked booth)
    if (!booth.isBooked || isSelected) {
      final center = _iso(c + bw / 2, r + bd / 2, h, origin);
      _drawBoothLabel(canvas, booth.number, center, isSelected);
    }

    hitAreas.add(BoothHitArea(booth, topFace));
  }

  void _drawBoothLabel(Canvas canvas, String text, Offset pos, bool selected) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withOpacity(selected ? 1.0 : 0.92),
          fontSize: selected ? 9.5 : 8.5,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          shadows: const [Shadow(color: Colors.black45, blurRadius: 3)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawHallLabels(Canvas canvas, Offset origin) {
    for (final hall in mapModel.halls) {
      if (hall.booths.isEmpty) continue;
      double sumCol = 0, sumRow = 0;
      for (final b in hall.booths) {
        sumCol += b.col + b.gridWidth / 2.0;
        sumRow += b.row + b.gridDepth / 2.0;
      }
      final avgCol = sumCol / hall.booths.length;
      final avgRow = sumRow / hall.booths.length;
      final maxH = hall.booths.map((b) => b.height).reduce((a, b) => a > b ? a : b);
      final labelPos = _iso(avgCol, avgRow, maxH + 0.6, origin);

      final bgPaint = Paint()
        ..color = hall.color.withOpacity(0.82)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: labelPos, width: 62, height: 18),
          const Radius.circular(9),
        ),
        bgPaint,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: hall.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      )..layout(maxWidth: 60);
      tp.paint(canvas, labelPos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _drawEntrance(Canvas canvas, Offset origin) {
    final gw = mapModel.gridWidth.toDouble();
    final gd = mapModel.gridDepth.toDouble();
    final entranceCenter = _iso(gw / 2, gd + 0.1, 0, origin);

    final arrowPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(entranceCenter.dx,       entranceCenter.dy - 10)
      ..lineTo(entranceCenter.dx + 8,   entranceCenter.dy + 4)
      ..lineTo(entranceCenter.dx + 3,   entranceCenter.dy + 4)
      ..lineTo(entranceCenter.dx + 3,   entranceCenter.dy + 12)
      ..lineTo(entranceCenter.dx - 3,   entranceCenter.dy + 12)
      ..lineTo(entranceCenter.dx - 3,   entranceCenter.dy + 4)
      ..lineTo(entranceCenter.dx - 8,   entranceCenter.dy + 4)
      ..close();

    canvas.drawPath(path, arrowPaint);

    final tp = TextPainter(
      text: const TextSpan(
        text: 'المدخل',
        style: TextStyle(
          color: Color(0xFF4CAF50),
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(
      canvas,
      entranceCenter + Offset(-tp.width / 2, 14),
    );
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  bool shouldRepaint(IsometricMapPainter old) =>
      old.selectedBooth?.id != selectedBooth?.id ||
      old.isDark != isDark;
}
