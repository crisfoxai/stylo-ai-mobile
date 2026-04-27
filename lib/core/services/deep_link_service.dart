import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/referrals/presentation/providers/referral_provider.dart';

class DeepLinkService {
  StreamSubscription<Uri>? _sub;

  Future<void> init(WidgetRef ref) async {
    final appLinks = AppLinks();

    // Handle cold start link
    final initialUri = await appLinks.getInitialLink();
    if (initialUri != null) {
      _handleUri(ref, initialUri);
    }

    // Handle foreground links
    _sub = appLinks.uriLinkStream.listen((uri) {
      _handleUri(ref, uri);
    });
  }

  void dispose() {
    _sub?.cancel();
  }

  void _handleUri(WidgetRef ref, Uri uri) {
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == 'join') {
      final code = segments[1].toUpperCase();
      ref.read(pendingReferralCodeProvider.notifier).state = code;
    }
  }
}
