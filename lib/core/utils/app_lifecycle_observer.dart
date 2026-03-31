import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/weather_provider.dart';

/// Observes Android/iOS app lifecycle transitions and manages Riverpod
/// provider state accordingly (e.g. invalidating stale data on resume).
class AppLifecycleObserver extends WidgetsBindingObserver {
  final WidgetRef _ref;

  AppLifecycleObserver(this._ref);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Invalidate weather so it refetches on resume.
        _ref.invalidate(weatherProvider);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }
}
