import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ════════════════════════════════════════════════════════════
//  ExpocoreLogo  –  شعار ExpoCore (SVG رسمي — مطابق 100%)
//  widget واحد يُستخدم في كل التطبيق (جوال + ويب)
// ════════════════════════════════════════════════════════════
class ExpocoreLogo extends StatelessWidget {
  final double size;

  /// عند true تُعرض خلفية اللوغو الداكنة المستديرة (كما في الصورة الأصلية)
  /// عند false تُعرض العلامة فقط بدون الخلفية — تملأ كامل المساحة (الافتراضي)
  final bool withBackground;

  const ExpocoreLogo({super.key, this.size = 120, this.withBackground = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.string(
        withBackground ? _svgFull : _svgMark,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SVG — النسخة الكاملة (مع الخلفية الداكنة المستديرة)
// ════════════════════════════════════════════════════════════
const String _svgDefs = '''
<defs>
<radialGradient id="bg" cx="50%" cy="40%" r="75%"><stop offset="0" stop-color="#241733"/><stop offset="100%" stop-color="#150E1D"/></radialGradient>
<linearGradient id="g0" gradientUnits="userSpaceOnUse" x1="337.3" y1="329.3" x2="562.2" y2="1071.2"><stop offset="0" stop-color="#821D54"/><stop offset="0.5" stop-color="#561138"/><stop offset="1" stop-color="#4B0F33"/></linearGradient>
<linearGradient id="g1" gradientUnits="userSpaceOnUse" x1="861.5" y1="176.4" x2="49.1" y2="226.5"><stop offset="0" stop-color="#8328AC"/><stop offset="0.5" stop-color="#7E25A7"/><stop offset="1" stop-color="#3A1052"/></linearGradient>
<linearGradient id="g2" gradientUnits="userSpaceOnUse" x1="86.3" y1="312.3" x2="119.5" y2="941.0"><stop offset="0" stop-color="#FB9A18"/><stop offset="0.5" stop-color="#F97411"/><stop offset="1" stop-color="#EB550B"/></linearGradient>
<linearGradient id="g3" gradientUnits="userSpaceOnUse" x1="885.2" y1="474.5" x2="415.0" y2="779.3"><stop offset="0" stop-color="#4A1569"/><stop offset="0.5" stop-color="#401159"/><stop offset="1" stop-color="#3B114F"/></linearGradient>
</defs>
''';

const String _svgPaths = '''
<path d="M498.4,291.9 Q488.0,286.0 478.0,292.6 L254.0,440.4 Q244.0,447.0 244.1,459.0 L246.9,953.0 Q247.0,965.0 257.3,971.2 L455.7,1090.8 Q466.0,1097.0 476.3,1090.9 L899.7,841.1 Q910.0,835.0 899.7,828.9 L795.3,767.1 Q785.0,761.0 774.6,767.1 L497.4,928.9 Q487.0,935.0 476.5,929.2 L402.5,888.8 Q392.0,883.0 391.8,871.0 L385.2,549.0 Q385.0,537.0 395.3,530.8 L638.7,383.2 Q649.0,377.0 638.6,371.1 Z" fill="url(#g0)"/>
<path d="M855.8,257.4 Q866.0,251.0 855.5,245.2 L474.5,35.8 Q464.0,30.0 453.8,36.4 L63.2,282.6 Q53.0,289.0 62.7,296.1 L163.3,369.9 Q173.0,377.0 182.9,370.2 L457.1,179.8 Q467.0,173.0 477.4,179.0 L729.6,324.0 Q740.0,330.0 750.2,323.6 Z" fill="url(#g1)"/>
<path d="M61.4,332.4 Q37.0,315.0 36.8,345.0 L34.2,809.3 Q34.0,837.0 51.5,858.5 L51.5,858.5 Q69.0,880.0 93.3,893.3 L148.7,923.6 Q175.0,938.0 174.8,908.0 L172.2,441.0 Q172.0,411.0 147.6,393.6 Z" fill="url(#g2)"/>
<path d="M856.8,444.0 Q857.0,432.0 846.6,437.9 L455.4,660.1 Q445.0,666.0 444.9,678.0 L444.1,811.0 Q444.0,823.0 454.4,817.1 L843.6,596.9 Q854.0,591.0 854.2,579.0 Z" fill="url(#g3)"/>
''';

const String _svgFull =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 940 1127">'
    '$_svgDefs'
    '<rect width="940" height="1127" rx="170" fill="url(#bg)"/>'
    '$_svgPaths'
    '</svg>';

// النسخة بدون خلفية (العلامة فقط) — viewBox مقصوص بإحكام حول العلامة
// حتى تملأ كامل المساحة وتظهر أكبر (الحدود الفعلية: x≈34..910، y≈30..1097)
const String _svgMark =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="30 26 884 1074">'
    '$_svgDefs'
    '$_svgPaths'
    '</svg>';
