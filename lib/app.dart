import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_lifecycle_observer.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/notifications/presentation/providers/notifications_provider.dart';
import 'shared/providers/theme_provider.dart';

class StyloApp extends ConsumerStatefulWidget {
  const StyloApp({super.key});

  @override
  ConsumerState<StyloApp> createState() => _StyloAppState();
}

class _StyloAppState extends ConsumerState<StyloApp> {
  late final AppLifecycleObserver _lifecycleObserver;
  bool _notificationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _lifecycleObserver = AppLifecycleObserver(ref);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Initialize push notifications once the user is authenticated
    ref.listen(authStateProvider, (_, next) {
      final user = next.valueOrNull;
      if (user != null && !_notificationsInitialized) {
        _notificationsInitialized = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref
                .read(notificationsServiceProvider)
                .init(context, router);
          }
        });
      }
      if (user == null) {
        _notificationsInitialized = false;
      }
    });

    return MaterialApp.router(
      title: 'Stylo AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
