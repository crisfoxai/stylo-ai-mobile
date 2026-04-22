import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/notifications_remote_datasource.dart';

final notificationsDataSourceProvider =
    Provider<NotificationsRemoteDataSource>((ref) {
  return NotificationsRemoteDataSource(ref.watch(apiClientProvider));
});

final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService(ref);
});

class NotificationsService {
  final Ref _ref;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  NotificationsService(this._ref);

  Future<void> init(BuildContext context, GoRouter router) async {
    await _requestPermission();
    await _registerToken();
    _listenTokenRefresh();
    _listenForeground(context, router);
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _registerToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _sendTokenToBackend(token);
    }
  }

  void _listenTokenRefresh() {
    _messaging.onTokenRefresh.listen(_sendTokenToBackend);
  }

  Future<void> _sendTokenToBackend(String token) async {
    final authState = _ref.read(authStateProvider);
    if (authState.valueOrNull == null) return;

    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      await _ref
          .read(notificationsDataSourceProvider)
          .registerToken(token, platform);
    } catch (_) {
      // Fail silently — token will be re-registered on next app launch
    }
  }

  void _listenForeground(BuildContext context, GoRouter router) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(notification.body ?? notification.title ?? ''),
          action: _buildDeepLinkAction(message, router, context),
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  SnackBarAction? _buildDeepLinkAction(
    RemoteMessage message,
    GoRouter router,
    BuildContext context,
  ) {
    final deepLink = message.data['deepLink'] as String?;
    if (deepLink == null) return null;
    return SnackBarAction(
      label: 'Ver',
      onPressed: () => router.push(deepLink),
    );
  }
}
