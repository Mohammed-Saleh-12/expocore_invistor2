import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> checkInternet() async {
  try {
    // Layer 1: quick interface check
    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) return false;

    // Layer 2: actual DNS reachability
    final lookup = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 5));
    return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}
