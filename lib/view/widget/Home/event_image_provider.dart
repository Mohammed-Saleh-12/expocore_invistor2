import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

ImageProvider<Object> eventImageProvider(String source) {
  final separator = source.indexOf(',');
  if (source.startsWith('data:image/') && separator >= 0) {
    final metadata = source.substring(0, separator).toLowerCase();
    final payload = source.substring(separator + 1);
    try {
      final bytes = metadata.contains(';base64')
          ? base64Decode(payload)
          : Uint8List.fromList(Uri.decodeComponent(payload).codeUnits);
      return MemoryImage(bytes);
    } catch (_) {
      // Let Image.network render the normal error state for invalid data.
    }
  }
  return NetworkImage(source);
}
