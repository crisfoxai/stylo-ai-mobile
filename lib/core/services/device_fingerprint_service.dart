import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceFingerprintService {
  Future<String> getFingerprint() async {
    try {
      final plugin = DeviceInfoPlugin();
      if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await plugin.androidInfo;
        final raw = '${info.id}${info.model}${info.brand}';
        return sha256.convert(utf8.encode(raw)).toString();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final info = await plugin.iosInfo;
        final raw = info.identifierForVendor ?? '';
        return sha256.convert(utf8.encode(raw)).toString();
      }
      return 'unknown';
    } catch (_) {
      return 'unknown';
    }
  }
}
