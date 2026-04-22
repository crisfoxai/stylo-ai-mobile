import '../env.dart';

class AppConstants {
  AppConstants._();

  static String get apiBaseUrl => Env.apiBaseUrl;
  static const String appVersion = '1.0.0';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 60);
  static const int defaultPageSize = 20;
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int imageQuality = 85;
  static const int thumbnailSize = 200;
}
