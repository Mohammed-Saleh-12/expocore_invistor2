import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════
//  MODEL  —  WebSection
//  يمثّل قسماً واحداً في تنقّل نسخة الويب
// ════════════════════════════════════════════════════════════
class WebSection {
  final IconData icon;
  final String   label;

  const WebSection({required this.icon, required this.label});
}
