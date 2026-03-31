import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/outfits/presentation/screens/favorites_screen.dart';
import '../../features/outfits/presentation/screens/outfit_detail_screen.dart';
import '../../features/outfits/presentation/screens/outfit_generator_screen.dart';
import '../../features/outfits/presentation/screens/outfit_history_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/style_profile/presentation/screens/style_quiz_result_screen.dart';
import '../../features/style_profile/presentation/screens/style_quiz_screen.dart';
import '../../features/wardrobe/presentation/screens/camera_scanner_screen.dart';
import '../../features/wardrobe/presentation/screens/garment_detail_screen.dart';
import '../../features/wardrobe/presentation/screens/garment_preview_screen.dart';
import '../../features/wardrobe/presentation/screens/wardrobe_grid_screen.dart';
import '../../shared/widgets/main_shell.dart';
import '../../features/subscription/presentation/screens/paywall_screen.dart';
import '../../features/try_on/presentation/screens/virtual_try_on_screen.dart';
import '../router/route_names.dart';
import '../../features/outfits/presentation/screens/home_dashboard_screen.dart';

final _publicRoutes = ['/splash', '/onboarding', '/auth'];
final _quizRoutes = ['/style-quiz', '/style-quiz/result'];

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final onboardingComplete = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull != null;
      final isOnboarded = onboardingComplete;
      final loc = state.matchedLocation;

      if (_publicRoutes.contains(loc)) return null;

      if (!isAuthenticated) return '/auth';

      if (isAuthenticated && !isOnboarded && !_quizRoutes.contains(loc)) {
        return '/style-quiz';
      }

      return null;
    },
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
        builder: (_, __) => const VirtualTryOnScreen(),
      ),
      GoRoute(
        path: '/paywall',
        name: RouteNames.paywall,
        builder: (_, __) => const PaywallScreen(),
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
            ],
          ),
          GoRoute(
            path: '/outfits',
            name: RouteNames.outfits,
            builder: (_, __) => const OutfitGeneratorScreen(),
            routes: [
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
        ],
      ),
    ],
  );
});
