import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/constants/app_constants.dart';

void main() {
  setUpAll(() async {
    // Load dotenv so AppConstants.apiBaseUrl doesn't throw NotInitializedError.
    // The .env file may be empty or minimal in tests — the getter falls back to
    // the hardcoded default URL when the key is absent.
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // If .env is missing or unreadable in CI, use an empty env.
      dotenv.testLoad(fileInput: '');
    }
  });

  group('AppConstants', () {
    group('version', () {
      test('appVersion is 1.0.0', () {
        expect(AppConstants.appVersion, '1.0.0');
      });

      test('appVersion has correct format (X.Y.Z)', () {
        final versionRegex = RegExp(r'^\d+\.\d+\.\d+$');
        expect(versionRegex.hasMatch(AppConstants.appVersion), isTrue);
      });
    });

    group('timeouts', () {
      test('connectTimeout is 15 seconds', () {
        expect(AppConstants.connectTimeout, const Duration(seconds: 15));
      });

      test('receiveTimeout is 30 seconds', () {
        expect(AppConstants.receiveTimeout, const Duration(seconds: 30));
      });

      test('sendTimeout is 60 seconds', () {
        expect(AppConstants.sendTimeout, const Duration(seconds: 60));
      });

      test('connectTimeout is less than receiveTimeout', () {
        expect(
          AppConstants.connectTimeout.inSeconds,
          lessThan(AppConstants.receiveTimeout.inSeconds),
        );
      });

      test('receiveTimeout is less than sendTimeout', () {
        expect(
          AppConstants.receiveTimeout.inSeconds,
          lessThan(AppConstants.sendTimeout.inSeconds),
        );
      });

      test('all timeouts are positive durations', () {
        expect(AppConstants.connectTimeout.isNegative, isFalse);
        expect(AppConstants.receiveTimeout.isNegative, isFalse);
        expect(AppConstants.sendTimeout.isNegative, isFalse);
      });
    });

    group('pagination', () {
      test('defaultPageSize is 20', () {
        expect(AppConstants.defaultPageSize, 20);
      });

      test('defaultPageSize is a positive integer', () {
        expect(AppConstants.defaultPageSize, greaterThan(0));
      });
    });

    group('image constants', () {
      test('maxImageSizeBytes is 10MB', () {
        const tenMegabytes = 10 * 1024 * 1024;
        expect(AppConstants.maxImageSizeBytes, tenMegabytes);
      });

      test('imageQuality is 85', () {
        expect(AppConstants.imageQuality, 85);
      });

      test('imageQuality is between 1 and 100', () {
        expect(AppConstants.imageQuality, greaterThanOrEqualTo(1));
        expect(AppConstants.imageQuality, lessThanOrEqualTo(100));
      });

      test('thumbnailSize is 200', () {
        expect(AppConstants.thumbnailSize, 200);
      });

      test('thumbnailSize is a positive integer', () {
        expect(AppConstants.thumbnailSize, greaterThan(0));
      });

      test('maxImageSizeBytes is greater than thumbnailSize', () {
        expect(AppConstants.maxImageSizeBytes, greaterThan(AppConstants.thumbnailSize));
      });
    });

    group('apiBaseUrl', () {
      test('apiBaseUrl returns a non-empty string', () {
        expect(AppConstants.apiBaseUrl, isNotEmpty);
      });

      test('apiBaseUrl starts with https', () {
        // When dotenv is not loaded, falls back to the default URL
        expect(
          AppConstants.apiBaseUrl.startsWith('https://'),
          isTrue,
        );
      });

      test('apiBaseUrl contains api path segment', () {
        expect(AppConstants.apiBaseUrl.contains('/api/'), isTrue);
      });
    });
  });
}
