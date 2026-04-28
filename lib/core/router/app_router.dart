import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/outfits/presentation/screens/favorites_screen.dart';
import '../../features/outfits/presentation/screens/outfit_detail_screen.dart';
import '../../features/outfits/presentation/screens/outfit_generator_screen.dart';
import '../../features/outfits/presentation/screens/outfit_history_screen.dart';
import '../../features/outfits/presentation/screens/outfits_list_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/style_profile/presentation/screens/style_quiz_result_screen.dart';
import '../../features/style_profile/presentation/screens/style_quiz_screen.dart';
import '../../features/wardrobe/domain/entities/detection_result.dart';
import '../../features/wardrobe/presentation/screens/camera_scanner_screen.dart';
import '../../features/wardrobe/presentation/screens/garment_detail_screen.dart';
import '../../features/wardrobe/presentation/screens/garment_detection_confirm_screen.dart';
import '../../features/wardrobe/presentation/screens/garment_preview_screen.dart';
import '../../features/wardrobe/presentation/screens/wardrobe_grid_screen.dart';
import '../../shared/widgets/main_shell.dart';
import '../../features/subscription/presentation/screens/paywall_screen.dart';
import '../../features/subscription/presentation/screens/subscription_manage_screen.dart';
import '../../features/try_on/presentation/screens/virtual_try_on_screen.dart';
import '../../features/try_on/presentation/screens/outfit_tryon_builder_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../router/route_names.dart';
import '../../features/outfits/presentation/screens/home_dashboard_screen.dart';
import '../../features/referrals/presentation/screens/referral_screen.dart';

const _publicRoutes = ['/splash', '/onboarding', '/auth'];
const _quizRoutes = ['/style-quiz', '/style-quiz/result'];

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  late final ProviderSubscription<AsyncValue<User?>> _authSub;
  late final ProviderSubscription<bool> _onboardingSub;

  _RouterNotifier(this._ref) {
    _authSub = _ref.listen(authStateProvider, (_, __) => notifyListeners());
    _onboardingSub = _ref.listen(onboardingCompleteProvider, (_, __) => notifyListeners());
  }

  String? redirect(String location) {
    final authState = _ref.read(authStateProvider);
    final isAuthenticated = authState.valueOrNull != null;
    final isOnboarded = _ref.read(onboardingCompleteProvider);

    if (_publicRoutes.contains(location)) return null;
    if (!isAuthenticated) return '/auth';
    if (isAuthenticated && !isOnboarded && !_quizRoutes.contains(location)) {
      return '/style-quiz';
    }
    return null;
  }

  @override
  void dispose() {
    _authSub.close();
    _onboardingSub.close();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  final router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) => notifier.redirect(state.matchedLocation),
    routes: [
      GoRoute(
        path: '/splash',
        name: RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: RouteNames.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: RouteNames.auth,
        builder: (_, __) => const AuthScreen(),
      ),
      GoRoute(
        path: '/style-quiz',
        name: RouteNames.styleQuiz,
        builder: (_, __) => const StyleQuizScreen(),
        routes: [
          GoRoute(
            path: 'result',
            name: RouteNames.styleQuizResult,
            builder: (_, __) => const StyleQuizResultScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/try-on',
        name: RouteNames.tryOn,
        builder: (context, state) {
          final garmentId = state.uri.queryParameters['garmentId'] ?? '';
          final resultUrl = state.uri.queryParameters['resultUrl'];
          return VirtualTryOnScreen(garmentId: garmentId, resultUrl: resultUrl);
        },
      ),
      GoRoute(
        path: '/try-on/builder',
        name: RouteNames.tryOnBuilder,
        builder: (_, __) => const OutfitTryonBuilderScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (_, __) => const ChatScreen(),
      ),
      GoRoute(
        path: '/paywall',
        name: RouteNames.paywall,
        builder: (_, __) => const PaywallScreen(),
      ),
      GoRoute(
        path: '/subscription/manage',
        name: RouteNames.subscriptionManage,
        builder: (_, __) => const SubscriptionManageScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: RouteNames.home,
            builder: (_, __) => const HomeDashboardScreen(),
          ),
          GoRoute(
            path: '/wardrobe',
            name: RouteNames.wardrobe,
            builder: (_, __) => const WardrobeGridScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: RouteNames.garmentDetail,
                builder: (_, state) => GarmentDetailScreen(
                  id: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/scan',
            name: RouteNames.scan,
            builder: (_, __) => const CameraScannerScreen(),
            routes: [
              GoRoute(
                path: 'preview',
                name: RouteNames.scanPreview,
                builder: (_, state) => GarmentPreviewScreen(
                  imagePath: state.extra as String,
                ),
              ),
              GoRoute(
                path: 'detect-confirm',
                name: RouteNames.garmentDetectionConfirm,
                builder: (_, state) => GarmentDetectionConfirmScreen(
                  result: state.extra as DetectionResult,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/outfits',
            name: RouteNames.outfits,
            builder: (_, __) => const OutfitsListScreen(),
            routes: [
              GoRoute(
                path: 'generate',
                name: RouteNames.outfitGenerator,
                builder: (_, __) => const OutfitGeneratorScreen(),
              ),
              GoRoute(
                path: 'favorites',
                name: RouteNames.favorites,
                builder: (_, __) => const FavoritesScreen(),
              ),
              GoRoute(
                path: 'history',
                name: RouteNames.outfitHistory,
                builder: (_, __) => const OutfitHistoryScreen(),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.outfitDetail,
                builder: (_, state) => OutfitDetailScreen(
                  id: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            name: RouteNames.profile,
            builder: (_, __) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/referrals',
            name: RouteNames.referrals,
            builder: (_, __) => const ReferralScreen(),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    notifier.dispose();
    router.dispose();
  });

  return router;
});
