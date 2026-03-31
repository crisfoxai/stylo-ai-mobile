# Stylo AI — Flutter Mobile App Specification

**Version:** 1.0
**Date:** 2026-03-30
**Platform:** iOS 16+ / Android 8.0+ (API 26+)
**Framework:** Flutter 3.x (Dart 3.x)

---

## Table of Contents

1. [Project Structure](#1-project-structure)
2. [Design System](#2-design-system)
3. [Navigation (GoRouter)](#3-navigation-gorouter)
4. [State Management (Riverpod)](#4-state-management-riverpod)
5. [Network Layer (Dio)](#5-network-layer-dio)
6. [Screen Specifications](#6-screen-specifications)
7. [Shared Components](#7-shared-components)
8. [Image Processing Flow](#8-image-processing-flow)
9. [Offline Strategy](#9-offline-strategy)
10. [Platform-Specific Configuration](#10-platform-specific-configuration)
11. [Performance](#11-performance)
12. [Dependencies](#12-dependencies)

---

## 1. Project Structure

```
lib/
├── main.dart
├── app.dart                          # App root widget, ProviderScope
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart        # API base URLs, timeouts, pagination limits
│   │   ├── storage_keys.dart         # SharedPreferences / Hive box keys
│   │   └── asset_paths.dart          # Image, lottie, illustration path constants
│   ├── theme/
│   │   ├── app_theme.dart            # ThemeData light/dark
│   │   ├── app_colors.dart           # Color palette
│   │   ├── app_typography.dart       # TextStyle definitions
│   │   └── app_spacing.dart          # Spacing scale constants
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── image_utils.dart          # Compression, resize helpers
│   │   ├── validators.dart           # Form field validators
│   │   └── extensions/
│   │       ├── context_ext.dart      # BuildContext extensions (theme, l10n, nav)
│   │       ├── string_ext.dart
│   │       └── list_ext.dart
│   ├── errors/
│   │   ├── app_exception.dart        # Base exception class
│   │   ├── network_exception.dart
│   │   ├── auth_exception.dart
│   │   └── failure.dart              # Sealed class: NetworkFailure, AuthFailure, etc.
│   ├── network/
│   │   ├── api_client.dart           # Dio instance factory
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── error_interceptor.dart
│   │   │   └── logging_interceptor.dart
│   │   └── endpoints.dart            # Typed endpoint constants
│   └── router/
│       ├── app_router.dart           # GoRouter configuration
│       ├── route_names.dart          # Named route constants
│       └── guards/
│           ├── auth_guard.dart
│           ├── onboarding_guard.dart
│           └── subscription_guard.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in_with_google.dart
│   │   │       ├── sign_in_with_apple.dart
│   │   │       ├── sign_in_with_email.dart
│   │   │       ├── sign_up_with_email.dart
│   │   │       └── sign_out.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       └── screens/
│   │           └── auth_screen.dart
│   │
│   ├── onboarding/
│   │   ├── data/
│   │   │   └── datasources/
│   │   │       └── onboarding_local_datasource.dart
│   │   ├── domain/
│   │   │   └── usecases/
│   │   │       └── complete_onboarding.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── onboarding_provider.dart
│   │       └── screens/
│   │           ├── splash_screen.dart
│   │           └── onboarding_screen.dart
│   │
│   ├── wardrobe/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── wardrobe_remote_datasource.dart
│   │   │   │   └── wardrobe_local_datasource.dart   # Hive cache
│   │   │   ├── models/
│   │   │   │   ├── garment_model.dart
│   │   │   │   └── garment_tag_model.dart
│   │   │   └── repositories/
│   │   │       └── wardrobe_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── garment.dart
│   │   │   │   └── garment_tag.dart
│   │   │   ├── repositories/
│   │   │   │   └── wardrobe_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_wardrobe.dart
│   │   │       ├── add_garment.dart
│   │   │       ├── update_garment.dart
│   │   │       ├── delete_garment.dart
│   │   │       └── search_wardrobe.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── wardrobe_provider.dart
│   │       └── screens/
│   │           ├── wardrobe_grid_screen.dart
│   │           ├── camera_scanner_screen.dart
│   │           ├── garment_preview_screen.dart
│   │           └── garment_detail_screen.dart
│   │
│   ├── outfits/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── outfit_remote_datasource.dart
│   │   │   │   └── outfit_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── outfit_model.dart
│   │   │   └── repositories/
│   │   │       └── outfit_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── outfit.dart
│   │   │   ├── repositories/
│   │   │   │   └── outfit_repository.dart
│   │   │   └── usecases/
│   │   │       ├── generate_outfit.dart
│   │   │       ├── get_outfit_history.dart
│   │   │       ├── toggle_favorite.dart
│   │   │       └── log_outfit_worn.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── outfit_generator_provider.dart
│   │       │   └── outfit_history_provider.dart
│   │       └── screens/
│   │           ├── outfit_generator_screen.dart
│   │           ├── outfit_detail_screen.dart
│   │           ├── favorites_screen.dart
│   │           └── outfit_history_screen.dart
│   │
│   ├── style_profile/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── style_profile_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── style_profile_model.dart
│   │   │   └── repositories/
│   │   │       └── style_profile_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── style_profile.dart
│   │   │   ├── repositories/
│   │   │   │   └── style_profile_repository.dart
│   │   │   └── usecases/
│   │   │       ├── submit_style_quiz.dart
│   │   │       └── get_style_profile.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── style_profile_provider.dart
│   │       └── screens/
│   │           ├── style_quiz_screen.dart
│   │           └── style_quiz_result_screen.dart
│   │
│   ├── try_on/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── try_on_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── try_on_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   │   └── try_on_repository.dart
│   │   │   └── usecases/
│   │   │       └── compose_virtual_outfit.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── try_on_provider.dart
│   │       └── screens/
│   │           └── virtual_try_on_screen.dart
│   │
│   ├── settings/
│   │   └── presentation/
│   │       └── screens/
│   │           └── settings_screen.dart
│   │
│   └── subscription/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── subscription_remote_datasource.dart
│       │   ├── models/
│       │   │   └── subscription_model.dart
│       │   └── repositories/
│       │       └── subscription_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── subscription.dart
│       │   ├── repositories/
│       │   │   └── subscription_repository.dart
│       │   └── usecases/
│       │       ├── get_subscription_status.dart
│       │       └── purchase_subscription.dart
│       └── presentation/
│           ├── providers/
│           │   └── subscription_provider.dart
│           └── screens/
│               └── paywall_screen.dart
│
└── shared/
    ├── widgets/
    │   ├── stylo_button.dart
    │   ├── stylo_text_field.dart
    │   ├── stylo_chip.dart
    │   ├── stylo_card.dart
    │   ├── garment_tile.dart
    │   ├── outfit_card.dart
    │   ├── bottom_nav_bar.dart
    │   ├── loading_overlay.dart
    │   ├── error_view.dart
    │   └── empty_state_view.dart
    └── providers/
        ├── weather_provider.dart
        └── theme_provider.dart

assets/
├── images/
│   ├── logo.png
│   ├── logo_dark.png
│   └── onboarding/
│       ├── slide_1.png
│       ├── slide_2.png
│       └── slide_3.png
├── animations/
│   ├── splash_logo.json          # Lottie
│   └── scanning_frame.json       # Lottie
└── fonts/
    ├── PlusJakartaSans/
    └── Inter/
```

---

## 2. Design System

### Colors (`app_colors.dart`)

```dart
class AppColors {
  // Brand
  static const Color accent       = Color(0xFFC67A5C);  // Terracotta
  static const Color primary      = Color(0xFF1A1A1A);  // Near-black
  static const Color background   = Color(0xFFFAFAFA);  // Off-white

  // Neutrals
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color surfaceAlt   = Color(0xFFF5F3F1);
  static const Color border       = Color(0xFFE8E3DF);
  static const Color textSecondary = Color(0xFF7A7370);
  static const Color textDisabled  = Color(0xFFB5B0AD);

  // Semantic
  static const Color success      = Color(0xFF4CAF77);
  static const Color error        = Color(0xFFE05252);
  static const Color warning      = Color(0xFFF5A623);
  static const Color info         = Color(0xFF4A90D9);
}
```

### Typography (`app_typography.dart`)

| Style          | Font              | Size | Weight | Usage                        |
|----------------|-------------------|------|--------|------------------------------|
| displayLarge   | Plus Jakarta Sans | 32   | 700    | Screen titles                |
| displayMedium  | Plus Jakarta Sans | 24   | 700    | Section headers              |
| displaySmall   | Plus Jakarta Sans | 20   | 600    | Card titles                  |
| titleLarge     | Plus Jakarta Sans | 18   | 600    | List headers                 |
| titleMedium    | Inter             | 16   | 500    | Sub-headers                  |
| bodyLarge      | Inter             | 16   | 400    | Primary body text            |
| bodyMedium     | Inter             | 14   | 400    | Secondary body               |
| labelLarge     | Inter             | 14   | 600    | Buttons, active chips        |
| labelMedium    | Inter             | 12   | 500    | Tags, metadata               |
| labelSmall     | Inter             | 10   | 400    | Captions                     |

### Spacing & Shape

```dart
class AppSpacing {
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 24.0;
  static const double xxxl = 32.0;
}

class AppRadius {
  static const double sm   = 8.0;
  static const double md   = 12.0;   // Default
  static const double lg   = 16.0;
  static const double xl   = 24.0;
  static const double full = 100.0;  // Pills / FAB
}
```

### Icons
- Library: `phosphor_flutter`
- Default weight: `regular`
- Active/selected: `fill` variant
- Size: 24px standard, 20px compact, 28px FAB

---

## 3. Navigation (GoRouter)

### Route Table (`route_names.dart` + `app_router.dart`)

```
/splash                        → SplashScreen
/onboarding                    → OnboardingScreen
/auth                          → AuthScreen
/style-quiz                    → StyleQuizScreen
/style-quiz/result             → StyleQuizResultScreen

/ (ShellRoute — bottom nav)
  /home                        → HomeDashboardScreen
  /wardrobe                    → WardrobeGridScreen
  /wardrobe/:id                → GarmentDetailScreen
  /scan                        → CameraScannerScreen
  /scan/preview                → GarmentPreviewScreen
  /outfits                     → OutfitGeneratorScreen
  /outfits/:id                 → OutfitDetailScreen
  /outfits/favorites           → FavoritesScreen
  /outfits/history             → OutfitHistoryScreen
  /profile                     → SettingsScreen

/try-on                        → VirtualTryOnScreen   (guarded: subscription)
/paywall                       → PaywallScreen        (bottom sheet)
```

### GoRouter Configuration

```dart
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final onboardingComplete = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull != null;
      final isOnboarded = onboardingComplete.valueOrNull == true;
      final loc = state.matchedLocation;

      // Unauthenticated: redirect to auth (except public routes)
      if (!isAuthenticated && !_isPublicRoute(loc)) return '/auth';

      // Authenticated but not onboarded: redirect to quiz
      if (isAuthenticated && !isOnboarded && !_isQuizRoute(loc)) {
        return '/style-quiz';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash',       builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding',   builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/auth',         builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/style-quiz',   builder: (_, __) => const StyleQuizScreen(),
        routes: [
          GoRoute(path: 'result',    builder: (_, __) => const StyleQuizResultScreen()),
        ],
      ),
      GoRoute(path: '/try-on',
        redirect: (context, state) => _requiresPremium(ref) ? '/paywall' : null,
        builder: (_, __) => const VirtualTryOnScreen(),
      ),
      GoRoute(path: '/paywall',      builder: (_, state) => const PaywallScreen()),

      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home',     builder: (_, __) => const HomeDashboardScreen()),
          GoRoute(path: '/wardrobe', builder: (_, __) => const WardrobeGridScreen(),
            routes: [
              GoRoute(path: ':id',   builder: (_, state) =>
                GarmentDetailScreen(id: state.pathParameters['id']!)),
            ],
          ),
          GoRoute(path: '/scan',     builder: (_, __) => const CameraScannerScreen(),
            routes: [
              GoRoute(path: 'preview', builder: (_, state) =>
                GarmentPreviewScreen(imagePath: state.extra as String)),
            ],
          ),
          GoRoute(path: '/outfits',  builder: (_, __) => const OutfitGeneratorScreen(),
            routes: [
              GoRoute(path: ':id',   builder: (_, state) =>
                OutfitDetailScreen(id: state.pathParameters['id']!)),
              GoRoute(path: 'favorites', builder: (_, __) => const FavoritesScreen()),
              GoRoute(path: 'history',   builder: (_, __) => const OutfitHistoryScreen()),
            ],
          ),
          GoRoute(path: '/profile',  builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
});
```

### Guards Summary

| Guard               | Trigger                                      | Redirect         |
|---------------------|----------------------------------------------|------------------|
| `auth_guard`        | Accessing any `/home`, `/wardrobe`, etc.     | `/auth`          |
| `onboarding_guard`  | Auth'd user with no style profile            | `/style-quiz`    |
| `subscription_guard`| Accessing `/try-on` without premium plan     | `/paywall`       |

---

## 4. State Management (Riverpod)

### Provider Architecture Overview

All providers follow this pattern:
- **AsyncNotifier** for async data (wardrobe, outfits, subscription)
- **StateNotifier** for complex sync/async state with side effects (auth)
- **Provider / StreamProvider** for derived/reactive values
- **FutureProvider** for one-shot async reads

---

### 4.1 AuthNotifier

```dart
// File: features/auth/presentation/providers/auth_provider.dart

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
}

class AuthNotifier extends StateNotifier<AuthState>
    extends StateNotifier<AuthState> {
  AuthNotifier(this._signInWithGoogle, this._signInWithEmail, ...)
      : super(AuthState.initial());

  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String email, String password);
  Future<void> signOut();
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) { ... });

// Stream of Firebase auth changes for router redirect
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});
```

---

### 4.2 WardrobeNotifier

```dart
// File: features/wardrobe/presentation/providers/wardrobe_provider.dart

class WardrobeState {
  final List<Garment> garments;
  final String searchQuery;
  final List<String> activeFilters;   // category, color, season
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;
}

class WardrobeNotifier extends AsyncNotifier<WardrobeState> {
  Future<void> loadWardrobe({bool refresh = false});
  Future<void> loadMore();
  void setSearchQuery(String query);
  void toggleFilter(String filter);
  Future<void> addGarment(Garment garment);
  Future<void> deleteGarment(String id);
  Future<void> updateGarment(Garment garment);
}

final wardrobeNotifierProvider =
    AsyncNotifierProvider<WardrobeNotifier, WardrobeState>(() => WardrobeNotifier());

// Derived: filtered garment list
final filteredWardrobeProvider = Provider<List<Garment>>((ref) {
  final state = ref.watch(wardrobeNotifierProvider).valueOrNull;
  // Apply search + filter logic
});

// Garment count per category (for stats)
final wardrobeStatsProvider = Provider<Map<String, int>>((ref) { ... });
```

---

### 4.3 OutfitGeneratorNotifier

```dart
// File: features/outfits/presentation/providers/outfit_generator_provider.dart

enum OutfitGeneratorStep { idle, selecting, generating, result, error }

class OutfitGeneratorState {
  final OutfitGeneratorStep step;
  final String? mood;              // casual, formal, sporty, etc.
  final String? event;             // work, date, weekend, etc.
  final WeatherData? weather;
  final GeneratedOutfit? result;
  final String? error;
}

class OutfitGeneratorNotifier extends AsyncNotifier<OutfitGeneratorState> {
  void setMood(String mood);
  void setEvent(String event);
  Future<void> generateOutfit();
  Future<void> regenerateOutfit();
  Future<void> swapGarment(String slot, String newGarmentId);
  Future<void> favoriteOutfit(String outfitId);
  Future<void> logAsWorn(String outfitId);
}

final outfitGeneratorProvider =
    AsyncNotifierProvider<OutfitGeneratorNotifier, OutfitGeneratorState>(
      () => OutfitGeneratorNotifier(),
    );

final outfitHistoryProvider = AsyncNotifierProvider<OutfitHistoryNotifier,
    List<OutfitHistoryEntry>>(() => OutfitHistoryNotifier());

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier,
    List<Outfit>>(() => FavoritesNotifier());
```

---

### 4.4 StyleProfileNotifier

```dart
// File: features/style_profile/presentation/providers/style_profile_provider.dart

class StyleQuizState {
  final int currentQuestion;        // 0–4
  final Map<int, List<String>> answers;
  final bool isSubmitting;
  final bool isComplete;
}

class StyleProfileNotifier extends AsyncNotifier<StyleProfile?> {
  Future<void> fetchProfile();
  Future<void> submitQuiz(Map<int, List<String>> answers);
}

final styleQuizStateProvider =
    StateNotifierProvider<StyleQuizNotifier, StyleQuizState>(
      (ref) => StyleQuizNotifier(),
    );

final styleProfileProvider =
    AsyncNotifierProvider<StyleProfileNotifier, StyleProfile?>(
      () => StyleProfileNotifier(),
    );
```

---

### 4.5 SubscriptionNotifier

```dart
// File: features/subscription/presentation/providers/subscription_provider.dart

class SubscriptionNotifier extends AsyncNotifier<Subscription> {
  Future<void> fetchStatus();
  Future<void> purchasePlan(String productId);
  Future<void> restorePurchases();
}

final subscriptionProvider =
    AsyncNotifierProvider<SubscriptionNotifier, Subscription>(
      () => SubscriptionNotifier(),
    );

final isPremiumProvider = Provider<bool>((ref) {
  final sub = ref.watch(subscriptionProvider).valueOrNull;
  return sub?.isActive == true;
});
```

---

### 4.6 WeatherProvider

```dart
// File: shared/providers/weather_provider.dart

final weatherProvider = FutureProvider.autoDispose<WeatherData>((ref) async {
  final location = await ref.watch(locationProvider.future);
  final client = ref.watch(apiClientProvider);
  return WeatherService(client).fetchCurrentWeather(location);
});

// Cached for the day — invalidated at midnight via a timer in app startup
```

---

### 4.7 ThemeProvider

```dart
// File: shared/providers/theme_provider.dart

final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(ref.watch(localStorageProvider)),
);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(this._storage) : super(_storage.getThemeMode());
  void setTheme(ThemeMode mode);
}
```

---

### 4.8 Camera / Scan Providers

```dart
// File: features/wardrobe/presentation/providers/wardrobe_provider.dart

enum ScanStep { idle, capturing, previewing, uploading, processing, done, error }

class GarmentScanState {
  final ScanStep step;
  final String? capturedImagePath;
  final String? processedImageUrl;
  final List<GarmentTag> suggestedTags;
  final List<GarmentTag> confirmedTags;
  final double uploadProgress;
  final String? error;
}

final garmentScanProvider =
    StateNotifierProvider.autoDispose<GarmentScanNotifier, GarmentScanState>(
      (ref) => GarmentScanNotifier(ref),
    );
```

---

## 5. Network Layer (Dio)

### Base Client Configuration (`api_client.dart`)

```dart
final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 60),       // Longer for image uploads
    headers: {
      'Content-Type': 'application/json',
      'Accept':        'application/json',
      'X-App-Version': AppConstants.appVersion,
      'X-Platform':    Platform.isIOS ? 'ios' : 'android',
    },
  ));

  dio.interceptors.addAll([
    ref.read(authInterceptorProvider),
    ref.read(errorInterceptorProvider),
    if (kDebugMode) ref.read(loggingInterceptorProvider),
    RetryInterceptor(dio: dio, retries: 2),
  ]);

  return dio;
});
```

### Auth Interceptor (`auth_interceptor.dart`)

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Attempt token refresh
      try {
        final newToken = await _refreshToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final retryResponse = await _dio.fetch(err.requestOptions);
        handler.resolve(retryResponse);
        return;
      } catch (_) {
        // Refresh failed — force logout
        _ref.read(authNotifierProvider.notifier).signOut();
      }
    }
    handler.next(err);
  }
}
```

### Error Interceptor (`error_interceptor.dart`)

Maps `DioException` to domain `AppException` types:

| HTTP Status | AppException Subclass          |
|-------------|-------------------------------|
| 400         | `ValidationException`          |
| 401         | `UnauthorizedException`        |
| 403         | `ForbiddenException`           |
| 404         | `NotFoundException`            |
| 422         | `UnprocessableException`       |
| 429         | `RateLimitException`           |
| 500–503     | `ServerException`              |
| timeout     | `NetworkTimeoutException`      |
| no connection | `NoInternetException`        |

### Retry Interceptor

- Max retries: 2
- Retryable status codes: 408, 429, 500, 502, 503, 504
- Backoff: exponential (500ms, 1000ms)
- Does NOT retry: 4xx (except 408/429), POST with non-idempotent body

### Endpoints (`endpoints.dart`)

```dart
class Endpoints {
  // Auth
  static const String signIn         = '/auth/signin';
  static const String signUp         = '/auth/signup';
  static const String refreshToken   = '/auth/refresh';

  // Wardrobe
  static const String wardrobe       = '/wardrobe';
  static String garment(String id)   => '/wardrobe/$id';
  static const String scanUpload     = '/wardrobe/scan';
  static String classifyGarment(String id) => '/wardrobe/$id/classify';

  // Outfits
  static const String outfits        = '/outfits';
  static String outfit(String id)    => '/outfits/$id';
  static const String generateOutfit = '/outfits/generate';
  static const String favorites      = '/outfits/favorites';
  static const String history        = '/outfits/history';

  // Style Profile
  static const String styleProfile   = '/style-profile';
  static const String styleQuiz      = '/style-profile/quiz';

  // Try-On
  static const String tryOnCompose   = '/try-on/compose';

  // Subscription
  static const String subscription   = '/subscription';
  static const String verifyPurchase = '/subscription/verify';

  // Weather (proxied through backend to protect API key)
  static const String weather        = '/weather/current';
}
```

### Image Upload (Multipart)

```dart
Future<String> uploadGarmentImage(String localPath) async {
  final formData = FormData.fromMap({
    'image': await MultipartFile.fromFile(
      localPath,
      filename: path.basename(localPath),
      contentType: MediaType('image', 'jpeg'),
    ),
    'remove_background': true,
  });

  final response = await _dio.post(
    Endpoints.scanUpload,
    data: formData,
    onSendProgress: (sent, total) {
      final progress = sent / total;
      ref.read(garmentScanProvider.notifier).updateProgress(progress);
    },
  );

  return response.data['image_url'] as String;
}
```

---

## 6. Screen Specifications

---

### 6.1 SplashScreen

**Path:** `/splash`
**File:** `features/onboarding/presentation/screens/splash_screen.dart`

**Widget Tree:**
```
Scaffold(backgroundColor: AppColors.background)
  └── Center
        └── Column
              ├── LottieBuilder.asset('assets/animations/splash_logo.json')  // 200x200
              └── FadeTransition
                    └── Text('STYLO', style: displayLarge, color: accent)
```

**State Dependencies:** `authStateProvider`, `onboardingCompleteProvider`

**Logic:**
1. Play Lottie animation (2 seconds)
2. Check `authStateProvider` — if authenticated and onboarded → `/home`
3. If authenticated and not onboarded → `/style-quiz`
4. If not authenticated, `onboardingCompleteProvider` == false → `/onboarding`
5. Otherwise → `/auth`

**Loading State:** Animation IS the loading state; no skeleton needed.

---

### 6.2 OnboardingScreen

**Path:** `/onboarding`
**File:** `features/onboarding/presentation/screens/onboarding_screen.dart`

**Widget Tree:**
```
Scaffold
  └── SafeArea
        └── Column
              ├── PageView (controller: _pageController)
              │     ├── OnboardingSlide(index: 0)   // "Scan Your Wardrobe"
              │     ├── OnboardingSlide(index: 1)   // "AI-Powered Outfits"
              │     └── OnboardingSlide(index: 2)   // "Try Before You Wear"
              ├── SmoothPageIndicator
              └── Row
                    ├── TextButton('Skip')          // → /auth
                    └── StyloButton('Next' / 'Get Started')
```

**Each `OnboardingSlide`:**
```
Column
  ├── Image.asset(illustration, height: 320)
  ├── Text(title, style: displayMedium)
  └── Text(subtitle, style: bodyLarge, color: textSecondary)
```

**State Dependencies:** `onboardingNotifierProvider`

**User Interactions:**
- Swipe left/right between slides
- "Skip" button → `/auth`, marks onboarding seen
- "Next" → next slide; on last slide "Get Started" → `/auth`

**Navigation Targets:** `/auth`

---

### 6.3 AuthScreen

**Path:** `/auth`
**File:** `features/auth/presentation/screens/auth_screen.dart`

**Widget Tree:**
```
Scaffold
  └── SafeArea
        └── SingleChildScrollView
              └── Padding(horizontal: lg)
                    └── Column
                          ├── Image.asset(logo, height: 56)
                          ├── Text('Welcome back', style: displayMedium)
                          ├── Text(subtitle, style: bodyMedium, color: textSecondary)
                          ├── SocialAuthButton(provider: 'google')
                          ├── SocialAuthButton(provider: 'apple')    // iOS only
                          ├── Divider with 'or' label
                          ├── StyloTextField(label: 'Email')
                          ├── StyloTextField(label: 'Password', obscure: true)
                          ├── TextButton('Forgot password?')
                          ├── StyloButton('Sign In')
                          └── TextButton('Create account')           // toggles mode
```

**State Dependencies:** `authNotifierProvider`

**User Interactions:**
- Google sign-in → `AuthNotifier.signInWithGoogle()`
- Apple sign-in (iOS) → `AuthNotifier.signInWithApple()`
- Email/password → `AuthNotifier.signInWithEmail()`
- Toggle between sign-in and sign-up modes
- "Forgot password" → email reset dialog

**Loading State:** Buttons show `CircularProgressIndicator`, form disabled
**Error State:** `SnackBar` with error message from `authState.errorMessage`
**Navigation Targets:** Post-auth → GoRouter redirect handles `/home` or `/style-quiz`

---

### 6.4 StyleQuizScreen

**Path:** `/style-quiz`
**File:** `features/style_profile/presentation/screens/style_quiz_screen.dart`

**Widget Tree:**
```
Scaffold
  └── SafeArea
        └── Column
              ├── LinearProgressIndicator(value: currentQuestion / 5)
              ├── Text('Question ${n} of 5', style: labelMedium, color: textSecondary)
              ├── Expanded
              │     └── PageView (physics: NeverScrollableScrollPhysics)
              │           └── QuizQuestionSlide × 5
              └── Row
                    ├── OutlinedButton('Back')     // hidden on q1
                    └── StyloButton('Next' / 'See My Style')
```

**QuizQuestionSlide:**
```
Column
  ├── Text(question, style: displaySmall)
  ├── Text(subtitle, style: bodyMedium)
  └── Wrap
        └── SelectableChip × n   // multi-select (max 3 per question)
```

**Quiz Questions:**
1. "Which aesthetics resonate with you?" — Minimalist, Streetwear, Bohemian, Classic, Avant-garde, Athleisure
2. "How would you describe your daily lifestyle?" — Office, Creative, Student, Active, Social, Work From Home
3. "What colors dominate your wardrobe?" — Neutrals, Earth Tones, Pastels, Bold & Bright, Monochrome, Jewel Tones
4. "What's your top priority when dressing?" — Comfort, Style, Versatility, Trendy, Sustainability, Practicality
5. "Which occasions do you dress for most?" — Work, Casual, Evening, Weekend, Formal, Sport

**State Dependencies:** `styleQuizStateProvider`

**User Interactions:**
- Select/deselect chips (up to 3 per question)
- "Next" advances page, updates `styleQuizState.answers`
- "See My Style" → submits quiz → navigates to `/style-quiz/result`

**Loading State:** Submit button shows spinner; quiz locked
**Empty State (no selection):** "Next" button disabled with tooltip

---

### 6.5 StyleQuizResultScreen

**Path:** `/style-quiz/result`
**File:** `features/style_profile/presentation/screens/style_quiz_result_screen.dart`

**Widget Tree:**
```
Scaffold
  └── SafeArea
        └── Column
              ├── Text('Your Style DNA', style: displayMedium)
              ├── StyleBadge(primaryStyle: 'Minimalist Chic')   // custom painter badge
              ├── RadarChart(data: styleScores)                  // fl_chart RadarChart
              │     // Axes: Classic, Casual, Bold, Trendy, Comfortable, Versatile
              ├── StyleTraitList                                  // 3 bullet traits
              │     └── Text × 3 (style: bodyMedium)
              ├── Text('Recommended Palette', style: titleMedium)
              ├── ColorPaletteRow(colors: recommendedColors)     // 5 color circles
              └── StyloButton('Start Building My Wardrobe')      // → /home
```

**State Dependencies:** `styleProfileProvider`

**Loading State:** Shimmer skeleton covering entire body
**Error State:** `ErrorView` widget with retry button

---

### 6.6 HomeDashboardScreen

**Path:** `/home`
**File:** `features/wardrobe/presentation/screens/home_dashboard_screen.dart`
*(Note: lives under wardrobe feature or could be a top-level `home` feature)*

**Widget Tree:**
```
Scaffold(backgroundColor: AppColors.background)
  ├── CustomScrollView
  │     ├── SliverAppBar(floating: true, snap: true)
  │     │     └── Row: greeting text + avatar/notification icon
  │     ├── SliverToBoxAdapter
  │     │     └── OutfitOfTheDayCard            // Outfit suggestion for today
  │     ├── SliverToBoxAdapter
  │     │     └── QuickActionsRow
  │     │           ├── QuickAction('Scan', PhosphorIcon.camera)   → /scan
  │     │           ├── QuickAction('Generate', PhosphorIcon.sparkle) → /outfits
  │     │           ├── QuickAction('Try On', PhosphorIcon.tShirt) → /try-on
  │     │           └── QuickAction('History', PhosphorIcon.clockCounterClockwise) → /outfits/history
  │     ├── SliverToBoxAdapter
  │     │     └── SectionHeader('Recent Wardrobe', onSeeAll: → /wardrobe)
  │     ├── SliverToBoxAdapter
  │     │     └── HorizontalGarmentList (4 items, CachedNetworkImage)
  │     ├── SliverToBoxAdapter
  │     │     └── SectionHeader('Outfit Ideas', onSeeAll: → /outfits)
  │     └── SliverList
  │           └── OutfitCard × 3
  └── BottomNavBar
```

**OutfitOfTheDayCard:**
```
Container(borderRadius: md, gradient: warm)
  └── Row
        ├── Column
        │     ├── WeatherChip(temp, icon)
        │     ├── Text('Today\'s Look', style: displaySmall)
        │     └── StyloButton('View Outfit')     → /outfits/:id
        └── OutfitFlatLayThumbnail
```

**State Dependencies:**
- `wardrobeNotifierProvider` (recent garments, sliced to 4)
- `outfitGeneratorProvider` (outfit of the day)
- `weatherProvider`
- `currentUserProvider` (greeting name)

**Loading State:** Shimmer for `OutfitOfTheDayCard` and `HorizontalGarmentList`
**Empty State:** If wardrobe is empty → `EmptyWardrobePrompt` with "Scan your first item" CTA

---

### 6.7 CameraScannerScreen

**Path:** `/scan`
**File:** `features/wardrobe/presentation/screens/camera_scanner_screen.dart`

**Widget Tree:**
```
Scaffold(backgroundColor: Colors.black)
  └── Stack
        ├── CameraPreview(controller)             // full screen
        ├── ScanFrameOverlay                       // animated Lottie frame guide
        │     └── Positioned corners with accent color
        ├── Positioned(top: safeArea + 16)
        │     └── Row
        │           ├── IconButton(PhosphorIcon.x) → pop
        │           ├── Spacer
        │           └── IconButton(PhosphorIcon.flashlight) toggle flash
        ├── Positioned(bottom: 100)
        │     └── Text('Center garment in frame', style: labelMedium, color: white70)
        └── Positioned(bottom: 32)
              └── Row
                    ├── ImagePickerButton(PhosphorIcon.image)  // from gallery
                    ├── CaptureButton(size: 72)                // large round button
                    └── SizedBox(width: 56)                    // balance
```

**CaptureButton Design:** Outer ring (white, 72px), inner circle (accent, 56px), tap feedback scale animation.

**State Dependencies:** `garmentScanProvider`, `cameraControllerProvider`

**User Interactions:**
- Tap capture → photo taken → navigate to `/scan/preview` with image path
- Tap gallery icon → `image_picker` → navigate to `/scan/preview`
- Toggle flash → `CameraController.setFlashMode()`

**Permissions:** Handled before screen loads via `permission_handler`. If denied → `PermissionDeniedView` with deep link to settings.

**Loading State:** Camera initializing → centered `CircularProgressIndicator` on black bg
**Error State:** Camera unavailable → error message with gallery fallback

---

### 6.8 GarmentPreviewScreen

**Path:** `/scan/preview`
**File:** `features/wardrobe/presentation/screens/garment_preview_screen.dart`

**Widget Tree:**
```
Scaffold
  ├── AppBar(title: 'Preview', leading: back button)
  └── Column
        ├── Expanded
        │     └── Stack
        │           ├── ProcessedGarmentImage         // shows bg-removed result
        │           └── if (processing) ProcessingOverlay
        │                 └── Column(Lottie + 'Analyzing...' text)
        ├── TagSection
        │     ├── Text('AI Detected', style: titleMedium)
        │     └── Wrap
        │           └── EditableChip × n             // editable, deletable
        ├── AddTagButton                              // '+ Add tag' chip
        └── Padding(horizontal: lg, vertical: xl)
              └── StyloButton('Save to Wardrobe')
```

**Tag Categories Shown:** Category, Color, Pattern, Season, Brand (if detected)

**State Dependencies:** `garmentScanProvider`

**Scan Steps & UI Mapping:**
| Step          | UI                                         |
|---------------|--------------------------------------------|
| `uploading`   | Linear progress bar at top + progress %    |
| `processing`  | Lottie spinner overlay on image            |
| `done`        | Processed image displayed, tags shown      |
| `error`       | Error snackbar + retry button              |

**User Interactions:**
- Delete chip → removes tag
- Tap chip → edit text inline (`TextField` in chip)
- "Add tag" → shows category bottom sheet picker then text input
- "Save to Wardrobe" → `WardrobeNotifier.addGarment()` → navigate to `/wardrobe`

---

### 6.9 WardrobeGridScreen

**Path:** `/wardrobe`
**File:** `features/wardrobe/presentation/screens/wardrobe_grid_screen.dart`

**Widget Tree:**
```
Scaffold
  ├── CustomScrollView
  │     ├── SliverAppBar(pinned: true)
  │     │     └── Column
  │     │           ├── SearchBar(hint: 'Search your wardrobe...')
  │     │           └── FilterChipsRow (All, Tops, Bottoms, Shoes, Accessories, Outerwear)
  │     └── SliverGrid(
  │           delegate: SliverGridDelegateWithFixedCrossAxisCount(
  │             crossAxisCount: 2,               // 3 on tablets
  │             childAspectRatio: 0.75,
  │             crossAxisSpacing: 12,
  │             mainAxisSpacing: 12,
  │           )
  │         )
  │           └── GarmentTile × n
  └── FAB(PhosphorIcon.camera, label: 'Scan')    → /scan
```

**GarmentTile:**
```
GestureDetector(onTap: → /wardrobe/:id)
  └── Stack
        ├── ClipRRect(borderRadius: md)
        │     └── CachedNetworkImage(fit: BoxFit.cover)
        └── Positioned(bottom: 0)
              └── Container(gradient: bottomFade)
                    └── Text(garment.category + garment.primaryColor)
```

**State Dependencies:** `filteredWardrobeProvider`, `wardrobeNotifierProvider`

**User Interactions:**
- Search input → `WardrobeNotifier.setSearchQuery()`
- Filter chip → `WardrobeNotifier.toggleFilter()`
- Scroll to bottom → `WardrobeNotifier.loadMore()` (pagination)
- Long press tile → selection mode → multi-delete option
- FAB → `/scan`

**Loading State:** Shimmer grid (2-col, 6 placeholder tiles)
**Empty State (no wardrobe):** `EmptyStateView(icon, 'Your wardrobe is empty', CTA: 'Scan your first item')`
**Empty State (no search results):** `EmptyStateView(icon, 'No items match "${query}"')`

---

### 6.10 GarmentDetailScreen

**Path:** `/wardrobe/:id`
**File:** `features/wardrobe/presentation/screens/garment_detail_screen.dart`

**Widget Tree:**
```
Scaffold
  └── CustomScrollView
        ├── SliverAppBar(expandedHeight: 380, pinned: true)
        │     └── FlexibleSpaceBar
        │           └── Hero(tag: 'garment-${id}')
        │                 └── CachedNetworkImage(fit: BoxFit.cover)
        │     Actions: edit icon, more (delete) icon
        ├── SliverToBoxAdapter
        │     └── Padding
        │           └── Column
        │                 ├── Row: Text(name, style: displaySmall), BrandBadge
        │                 ├── AttributeGrid (Category, Color, Pattern, Season, Size)
        │                 │     └── 2-col Wrap of AttributeChip
        │                 ├── Divider
        │                 ├── Text('Outfit Appearances', style: titleMedium)
        │                 ├── HorizontalOutfitList (outfits containing garment)
        │                 ├── Divider
        │                 └── WearStatsRow
        │                       ├── Stat('Times Worn', count)
        │                       ├── Stat('Last Worn', date)
        │                       └── Stat('Cost Per Wear', '$x.xx')
        └── SliverPadding(bottom: 32)
```

**State Dependencies:** `garmentDetailProvider(id)` (family provider), `outfitsByGarmentProvider(id)`

**User Interactions:**
- Edit icon → inline edit mode for name and tags
- Delete (more menu) → confirmation dialog → `WardrobeNotifier.deleteGarment(id)`
- Outfit appearance tap → `/outfits/:id`

**Loading State:** Shimmer matching layout structure
**Error State:** `ErrorView` with retry

---

### 6.11 OutfitGeneratorScreen

**Path:** `/outfits`
**File:** `features/outfits/presentation/screens/outfit_generator_screen.dart`

**Widget Tree:**
```
Scaffold
  ├── AppBar(title: 'Outfit Generator')
  │     Actions: history icon → /outfits/history, favorites → /outfits/favorites
  └── Column
        ├── WeatherContextCard
        │     └── Row: WeatherIcon, Text(temp + condition), Text(location)
        ├── SectionLabel('Mood')
        ├── HorizontalScrollRow
        │     └── MoodChip × 6  (Casual, Formal, Creative, Sporty, Romantic, Bold)
        ├── SectionLabel('Occasion')
        ├── HorizontalScrollRow
        │     └── OccasionChip × 6  (Work, Date, Weekend, Party, Errand, Travel)
        ├── Spacer
        ├── if (result != null) OutfitFlatLayPreview
        └── Padding(horizontal: lg)
              └── StyloButton(
                    label: result == null ? 'Generate Outfit' : 'Regenerate',
                    loading: step == generating,
                    onTap: generateOutfit,
                  )
```

**OutfitFlatLayPreview:**
```
GestureDetector(onTap: → /outfits/:id)
  └── Container(borderRadius: lg, color: surfaceAlt)
        └── Stack
              ├── FlatLayCanvas (positioned garment images)
              └── Positioned(top: 8, right: 8)
                    └── IconButton(PhosphorIcon.heart)  // quick favorite
```

**State Dependencies:** `outfitGeneratorProvider`, `weatherProvider`

**Loading State:** `OutfitFlatLaySkeleton` (animated shimmer of garment silhouettes)
**Error State:** Error card within body, "Try Again" button
**Empty (no mood/occasion selected):** Generate button active with default recommendations

---

### 6.12 OutfitDetailScreen

**Path:** `/outfits/:id`
**File:** `features/outfits/presentation/screens/outfit_detail_screen.dart`

**Widget Tree:**
```
Scaffold
  ├── CustomScrollView
  │     ├── SliverAppBar(expandedHeight: 420, pinned: true)
  │     │     └── FlexibleSpaceBar
  │     │           └── FlatLayCanvas (full outfit image)
  │     │     Actions: share icon, heart (favorite) icon
  │     └── SliverToBoxAdapter
  │           └── Column
  │                 ├── Row: Text(outfitName, style: displaySmall), OccasionBadge
  │                 ├── Text('Garment Breakdown', style: titleMedium)
  │                 ├── ListView.separated (garment swap row × pieces)
  │                 │     └── GarmentSwapRow
  │                 │           ├── CachedNetworkImage (thumb, 56x56)
  │                 │           ├── Column: name, category
  │                 │           └── IconButton(PhosphorIcon.arrowsClockwise) → SwapBottomSheet
  │                 └── WearTodaySection
  │                       └── StyloButton('Wear Today')   → logs worn
  └── BottomSafeArea
```

**State Dependencies:** `outfitDetailProvider(id)`, `favoritesProvider`

**SwapBottomSheet:**
- Shows 6 alternative garments from same category
- Tap garment → `OutfitGeneratorNotifier.swapGarment(slot, newId)` → sheet closes, outfit updates

**User Interactions:**
- Heart icon → `toggleFavorite(id)`
- Share → `Share.share()` with outfit image + deep link
- "Wear Today" → `logAsWorn(id)` → confirmation snackbar
- Garment row tap → `/wardrobe/:garmentId`

---

### 6.13 FavoritesScreen

**Path:** `/outfits/favorites`
**File:** `features/outfits/presentation/screens/favorites_screen.dart`

**Widget Tree:**
```
Scaffold
  ├── AppBar(title: 'Favorites')
  ├── Column
  │     ├── FilterChipsRow (All, Casual, Formal, Sporty, etc.)
  │     └── Expanded
  │           └── GridView.builder (2-col, childAspectRatio: 0.8)
  │                 └── OutfitCard
  │                       ├── FlatLayThumbnail (CachedNetworkImage)
  │                       ├── Text(occasion badge)
  │                       └── IconButton(heart filled → unfavorite)
  └── (no FAB)
```

**State Dependencies:** `favoritesProvider`

**User Interactions:**
- Tap outfit card → `/outfits/:id`
- Tap heart → `FavoritesNotifier.removeFavorite(id)` with undo `SnackBar`
- Filter chips → filter `favoritesProvider` by occasion

**Empty State:** `EmptyStateView(PhosphorIcon.heartBreak, 'No favorites yet', 'Generate an outfit to save it')`

---

### 6.14 OutfitHistoryScreen

**Path:** `/outfits/history`
**File:** `features/outfits/presentation/screens/outfit_history_screen.dart`

**Widget Tree:**
```
Scaffold
  ├── AppBar(title: 'Outfit History')
  └── Column
        ├── CalendarStrip
        │     └── HorizontalScrollRow of DayChip (Mon 25, Tue 26, ...)
        │           // Active day highlighted in accent
        ├── StatsRow
        │     ├── Stat('This Week', n + ' outfits')
        │     ├── Stat('Most Worn', garment name)
        │     └── Stat('Streak', n + ' days')
        └── Expanded
              └── ListView.builder
                    └── HistoryEntry (grouped by date)
                          ├── DateHeader (Sticky: 'Monday, March 30')
                          └── OutfitHistoryCard
                                ├── FlatLayThumbnail (56x56)
                                ├── Column: outfit name, occasion, time worn
                                └── ChevronRight
```

**State Dependencies:** `outfitHistoryProvider`, `selectedHistoryDateProvider`

**User Interactions:**
- Tap calendar day → filters timeline to that day
- Tap history entry → `/outfits/:id`
- Pull to refresh → `OutfitHistoryNotifier.refresh()`

**Empty State:** `EmptyStateView('No history yet', 'Mark outfits as worn to see them here')`

---

### 6.15 VirtualTryOnScreen (Premium)

**Path:** `/try-on`
**File:** `features/try_on/presentation/screens/virtual_try_on_screen.dart`

**Guard:** Redirects to `/paywall` if `isPremiumProvider == false`

**Widget Tree:**
```
Scaffold
  ├── AppBar(title: 'Virtual Try-On', actions: [save icon, share icon])
  └── Column
        ├── Expanded
        │     └── InteractiveTryOnCanvas
        │           // GestureDetector wrapping Stack of
        │           // DraggableGarmentLayer × n (positioned, scalable)
        │           // Background: mannequin silhouette or plain #F5F3F1
        ├── GarmentTray
        │     └── DraggableScrollableSheet
        │           └── GridView (garment thumbnails from wardrobe)
        │                 └── GarmentThumbnail (drag source)
        └── Padding(horizontal: lg, bottom: safeArea)
              └── Row
                    ├── OutlinedButton('Clear All')
                    └── StyloButton('Save Look')
```

**DraggableGarmentLayer:**
- `Draggable<Garment>` wrapping `CachedNetworkImage`
- Supports scale gesture for resizing
- Tap to select → shows delete/bring-forward/send-back handles
- `DragTarget` on canvas accepts drops

**State Dependencies:** `tryOnProvider`, `wardrobeNotifierProvider`

**User Interactions:**
- Drag garment from tray → drop onto canvas
- Pinch to scale garment on canvas
- Tap garment on canvas → select (shows handles)
- Trash handle on selected → removes from canvas
- "Save Look" → captures canvas as image → saves to outfits

**Loading State:** Canvas shimmer while wardrobe loads
**Accessibility Note:** Non-drag alternative: tap garment in tray → tap slot on canvas

---

### 6.16 SettingsScreen

**Path:** `/profile`
**File:** `features/settings/presentation/screens/settings_screen.dart`

**Widget Tree:**
```
Scaffold
  ├── CustomScrollView
  │     ├── SliverAppBar(title: 'Profile & Settings')
  │     │     └── ProfileHeaderCard
  │     │           ├── CircleAvatar (user photo, 72px)
  │     │           ├── Text(displayName, style: displaySmall)
  │     │           ├── Text(email, style: bodyMedium, color: textSecondary)
  │     │           └── OutlinedButton('Edit Profile')
  │     └── SliverList
  │           └── Column
  │                 ├── SettingsSection('Style')
  │                 │     ├── SettingsTile('Style Profile', trailing: badge)  → /style-quiz
  │                 │     └── SettingsTile('Preferred Colors', trailing: chips)
  │                 ├── SettingsSection('Subscription')
  │                 │     ├── SubscriptionStatusTile          // shows plan + renewal
  │                 │     └── SettingsTile('Manage Plan')     → /paywall
  │                 ├── SettingsSection('App')
  │                 │     ├── SettingsTile('Notifications', trailing: Switch)
  │                 │     ├── SettingsTile('Theme', trailing: ThemeSegmentedControl)
  │                 │     └── SettingsTile('Units', trailing: UnitToggle)
  │                 ├── SettingsSection('Legal')
  │                 │     ├── SettingsTile('Privacy Policy')  → webview/URL
  │                 │     ├── SettingsTile('Terms of Service') → webview/URL
  │                 │     └── SettingsTile('Licenses')
  │                 └── Padding(vertical: xl)
  │                       └── TextButton('Sign Out', color: error)
  └── (no FAB)
```

**State Dependencies:** `currentUserProvider`, `subscriptionProvider`, `themeModeProvider`

**User Interactions:**
- Theme toggle → `ThemeNotifier.setTheme()`
- Notifications switch → `NotificationService.setEnabled()`
- Sign Out → `AuthNotifier.signOut()` → GoRouter redirects to `/auth`

---

### 6.17 PaywallScreen

**Path:** `/paywall`
**File:** `features/subscription/presentation/screens/paywall_screen.dart`

**Presentation:** `showModalBottomSheet` (draggable, `isScrollControlled: true`)

**Widget Tree:**
```
DraggableScrollableSheet(initialSize: 0.92)
  └── Container(borderRadius: TopRadius(xl))
        └── Column
              ├── DragHandle
              ├── Text('Unlock Stylo Premium', style: displayMedium)
              ├── Text(subtitle, style: bodyMedium, color: textSecondary)
              ├── FeatureComparisonList
              │     └── FeatureRow × 6
              │           ├── PhosphorIcon (accent)
              │           ├── Text(featureName)
              │           └── if isPremium PhosphorIcon.check else LockIcon
              ├── PricingOptions (2 options)
              │     ├── PricingCard('Monthly', '$9.99/mo', selected: monthlySelected)
              │     └── PricingCard('Annual', '$59.99/yr', badge: 'Save 50%', selected: !monthlySelected)
              ├── StyloButton('Start Free Trial')   // 7-day trial
              ├── TextButton('Restore Purchases')
              └── Text(legalDisclaimer, style: labelSmall, color: textDisabled)
```

**Premium Features Listed:**
1. Virtual Try-On canvas
2. Unlimited outfit generation
3. AI wardrobe analysis report
4. Priority AI processing
5. Outfit sharing & export
6. Advanced style insights

**State Dependencies:** `subscriptionProvider`

**User Interactions:**
- Select pricing plan → updates selection state
- "Start Free Trial" → `SubscriptionNotifier.purchasePlan(productId)`
- "Restore Purchases" → `SubscriptionNotifier.restorePurchases()`

**Loading State:** Button shows spinner; options disabled
**Error State:** `SnackBar` with purchase error
**Success:** Sheet dismisses, `isPremiumProvider` updates, original route accessible

---

## 7. Shared Components

### StyloButton (`shared/widgets/stylo_button.dart`)

```dart
class StyloButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool fullWidth;
  final StyloButtonVariant variant;   // filled | outlined | text
  final PhosphorIconData? icon;
  // ...
}
```

- Height: 52px
- Border radius: `AppRadius.full` (pill)
- Filled: `backgroundColor: accent`, text: white
- Outlined: transparent bg, `border: accent`, text: accent
- Disabled: opacity 0.4
- Loading: replaces label with 20px `CircularProgressIndicator` (white)

---

### StyloTextField (`shared/widgets/stylo_text_field.dart`)

```dart
class StyloTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final PhosphorIconData? prefixIcon;
  final Widget? suffix;
  // ...
}
```

- Border radius: `AppRadius.md`
- Unfocused border: `AppColors.border`
- Focused border: `AppColors.accent`, 1.5px
- Error state: `AppColors.error` border + error text below
- Height: 52px

---

### StyloChip / SelectableChip (`shared/widgets/stylo_chip.dart`)

```dart
class StyloChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool deletable;
  final VoidCallback? onDelete;
  // ...
}
```

- Unselected: `surfaceAlt` bg, `border` border, `textSecondary` text
- Selected: `accent` bg (10% opacity), `accent` border, `accent` text, bold
- Height: 36px, padding: `horizontal: 14, vertical: 8`
- Border radius: `AppRadius.full`

---

### GarmentTile (`shared/widgets/garment_tile.dart`)

```dart
class GarmentTile extends StatelessWidget {
  final Garment garment;
  final VoidCallback onTap;
  final bool selectable;
  final bool selected;
  // ...
}
```

- Image: `CachedNetworkImage` with `BoxFit.cover`
- Placeholder: shimmer gradient
- Error: `PhosphorIcon.imageBroken` centered
- Optional selection overlay: accent border + checkmark

---

### OutfitCard (`shared/widgets/outfit_card.dart`)

```dart
class OutfitCard extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool showFavoriteButton;
  // ...
}
```

- Aspect ratio: 3:4
- Border radius: `AppRadius.md`
- Bottom gradient overlay with occasion badge + name
- Favorite button: top-right, heart icon (filled if favorited)

---

### BottomNavBar (`shared/widgets/bottom_nav_bar.dart`)

```dart
// 5 destinations:
// [Home, Wardrobe, Scan (FAB), Outfits, Profile]
// Scan is a centered FAB that breaks the bar visually
```

| Index | Icon (inactive)               | Icon (active)                | Label    |
|-------|-------------------------------|------------------------------|----------|
| 0     | PhosphorIcon.house            | PhosphorIcon.houseFill       | Home     |
| 1     | PhosphorIcon.tShirt           | PhosphorIcon.tShirtFill      | Wardrobe |
| 2     | PhosphorIcon.camera (FAB)     | — (always accent)            | Scan     |
| 3     | PhosphorIcon.hanger           | PhosphorIcon.hangerFill      | Outfits  |
| 4     | PhosphorIcon.user             | PhosphorIcon.userFill        | Profile  |

The FAB (index 2) is a 56px circle, `backgroundColor: accent`, elevated above the nav bar. Tapping navigates to `/scan`.

---

### LoadingOverlay (`shared/widgets/loading_overlay.dart`)

Full-screen semi-transparent overlay with centered `CircularProgressIndicator(color: accent)` and optional message text. Used for blocking operations (sign in, purchase).

---

### ErrorView (`shared/widgets/error_view.dart`)

```dart
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final PhosphorIconData? icon;
  // ...
}
```

Layout: Center > Column > Icon (48px, textDisabled) > Text(message) > if onRetry: OutlinedButton('Try Again')

---

### EmptyStateView (`shared/widgets/empty_state_view.dart`)

Same structure as `ErrorView` but semantically for empty data. Accepts a CTA button.

---

## 8. Image Processing Flow

```
[User Action]
     │
     ▼
1. CAPTURE
   ├── camera_scanner_screen.dart
   ├── CameraController.takePicture() → XFile
   ├── image_utils.dart: compressImage(maxWidth: 1200, quality: 85)
   └── Navigate → garment_preview_screen.dart(imagePath: localPath)

     │
     ▼
2. PREVIEW (local)
   ├── Display Image.file(localPath) immediately (no wait)
   └── Trigger background processing

     │
     ▼
3. UPLOAD
   ├── GarmentScanNotifier.uploadImage(localPath)
   ├── Dio multipart POST /wardrobe/scan
   │     { image: file, remove_background: true }
   ├── onSendProgress → update uploadProgress state (0.0 → 1.0)
   └── Response: { job_id, status: 'processing' }

     │
     ▼
4. BACKGROUND REMOVAL (server-side async)
   ├── Poll GET /wardrobe/scan/{job_id} every 1.5 seconds
   ├── Status: processing → show Lottie spinner overlay
   ├── Status: done → { processed_image_url, thumbnail_url }
   └── Display CachedNetworkImage(processedImageUrl) replacing local preview

     │
     ▼
5. CLASSIFICATION (server-side, returns with step 4)
   ├── Response also includes: { tags: [{ key, value, confidence }] }
   ├── Filter tags with confidence >= 0.6
   └── Populate `suggestedTags` in GarmentScanState

     │
     ▼
6. USER REVIEW
   ├── User edits / adds / removes tags in GarmentPreviewScreen
   └── Taps "Save to Wardrobe"

     │
     ▼
7. SAVE
   ├── POST /wardrobe { image_url, thumbnail_url, tags, created_at }
   ├── WardrobeNotifier.addGarment() updates local state optimistically
   ├── Hive cache updated
   └── Navigate → /wardrobe (grid refreshes with new item at top)
```

**Error Handling Per Step:**
- Capture fails → show snackbar, stay on camera screen
- Upload fails (network) → retry button in preview screen
- Processing timeout (>30s) → show error with "Try Again" (re-upload)
- Classification returns no tags → show empty chip row, prompt user to add manually
- Save fails → keep draft in local Hive, retry indicator on wardrobe grid

---

## 9. Offline Strategy

### What Works Offline

| Feature                          | Offline Behavior                                    |
|----------------------------------|-----------------------------------------------------|
| Browse wardrobe                  | Full access — served from Hive cache                |
| View garment detail              | Full access — cached images via cached_network_image|
| View outfit history              | Full access — served from Hive cache                |
| View saved favorites             | Full access — served from Hive cache                |
| Browse outfit of the day         | Shows last cached outfit (stale label if >24h)      |
| Scan garment                     | Capture works; upload queued for reconnect          |
| Generate outfit                  | Disabled — requires AI backend                      |
| Virtual try-on                   | Disabled — requires AI backend                      |
| Style quiz                       | Can complete quiz offline; submit queued            |

### Local Caching Approach

**Hive Boxes:**

| Box Name              | Content                                 | TTL          |
|-----------------------|-----------------------------------------|--------------|
| `wardrobe_box`        | `List<GarmentModel>` (full data)        | No expiry    |
| `outfits_box`         | `List<OutfitModel>` (recent 50)         | 7 days       |
| `outfit_history_box`  | `List<OutfitHistoryEntry>` (recent 90d) | 90 days      |
| `style_profile_box`   | `StyleProfileModel`                     | No expiry    |
| `weather_box`         | `WeatherData` + timestamp               | 3 hours      |
| `auth_box`            | Access token, refresh token, user data  | Token expiry |

**Image Cache:**
- `cached_network_image` stores decoded images in memory + disk
- Max disk cache: 200 MB (configured in `main.dart` via `DefaultCacheManager`)
- Max memory cache: 50 images

**Offline Queue (Hive `pending_actions_box`):**
```dart
class PendingAction {
  final String id;
  final String type;          // 'add_garment', 'log_worn', 'toggle_favorite'
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  int retryCount;
}
```

`ConnectivityService` listens to `connectivity_plus` stream. On reconnect → processes `pending_actions_box` in FIFO order.

**Stale Data Indicators:**
- If `wardrobe_box` data is older than last successful sync, show subtle "Last synced X ago" in `WardrobeGridScreen` AppBar subtitle.

---

## 10. Platform-Specific Configuration

### iOS (`ios/Runner/Info.plist`)

```xml
<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>Stylo needs camera access to scan your clothing items.</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Stylo needs photo library access to import clothing images.</string>

<!-- Photo Library Add Only -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Stylo saves outfit looks to your photo library when you share them.</string>

<!-- Location (for weather) -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Stylo uses your location to suggest weather-appropriate outfits.</string>
```

**Capabilities (Xcode):**
- Sign In with Apple: enabled
- Push Notifications: enabled (for outfit reminders)
- In-App Purchase: enabled

**Minimum iOS version:** 16.0 (for `swift_package_manager` compatibility and `PHPicker`)

**App Transport Security:** Exception for development API host only; production uses HTTPS exclusively.

---

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />  <!-- API 33+ -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />  <!-- API 33+ -->

<!-- Prevents app showing on devices without camera -->
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

**`android/app/build.gradle`:**
```groovy
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 26       // Android 8.0
        targetSdkVersion 34
        multiDexEnabled true
    }
    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

**`android/app/proguard-rules.pro`:**
```
-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
```

**Google Sign-In:** `google-services.json` in `android/app/`
**Firebase:** `GoogleService-Info.plist` (iOS) + `google-services.json` (Android) must be present before build.

---

### Permission Request Flow (`permission_handler`)

```dart
// core/utils/permission_service.dart
class PermissionService {
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestPhotos() async {
    if (Platform.isIOS) {
      return (await Permission.photos.request()).isGranted;
    } else {
      final sdkVersion = await _getSdkVersion();
      if (sdkVersion >= 33) {
        return (await Permission.photos.request()).isGranted;
      } else {
        return (await Permission.storage.request()).isGranted;
      }
    }
  }
}
```

Permissions are requested contextually (when feature is first needed), not at app launch. On permanent denial, show a `AlertDialog` explaining the need with a button to open app settings via `openAppSettings()`.

---

## 11. Performance

### Image Caching

All remote images use `CachedNetworkImage`:

```dart
CachedNetworkImage(
  imageUrl: garment.imageUrl,
  placeholder: (context, url) => const ShimmerBox(),
  errorWidget: (context, url, error) => const GarmentImageError(),
  fit: BoxFit.cover,
  memCacheWidth: 400,    // Resize in memory to reduce RAM usage
  memCacheHeight: 533,   // for 3:4 tiles
)
```

**Preloading:** On `WardrobeGridScreen` build, preload first 6 visible images:
```dart
for (final garment in garments.take(6)) {
  precacheImage(CachedNetworkImageProvider(garment.thumbnailUrl), context);
}
```

### Lazy Loading & Pagination

- **WardrobeGrid:** Page size 20. Load next page when scroll reaches 80% of list.
- **OutfitHistory:** Page size 15, infinite scroll.
- **Favorites:** Page size 20, infinite scroll.

```dart
// Pagination via WardrobeNotifier
bool _isNearBottom(ScrollController controller) {
  return controller.position.pixels >=
         controller.position.maxScrollExtent * 0.8;
}
```

### Compute Isolates

Heavy operations run in `compute()` isolates to avoid jank:
- Image compression before upload
- JSON parsing of large wardrobe lists (>100 items)
- Wardrobe search/filter on large datasets

```dart
final compressed = await compute(compressImageIsolate, ImageCompressParams(
  path: localPath,
  maxWidth: 1200,
  quality: 85,
));
```

### Rendering Performance

- `const` constructors used throughout for static widgets
- `RepaintBoundary` wraps `FlatLayCanvas` and `RadarChart` (heavy paint)
- `ListView.builder` and `GridView.builder` — never `ListView(children: [...])`
- `keepAlive` wrappers on `PageView` tab children (onboarding, quiz)
- `AutomaticKeepAliveClientMixin` on `WardrobeGridScreen` to preserve scroll position across tab switches

### App Startup

- Splash screen shown immediately (no async wait)
- Heavy providers (`wardrobeNotifierProvider`, `outfitHistoryProvider`) use `AsyncNotifier` — data loads after navigation
- Firebase initialized before `runApp()` using `WidgetsFlutterBinding.ensureInitialized()`
- Font loading: preloaded in `pubspec.yaml` assets to avoid FOUT

### Build Flavor Configuration

```
flutter/
├── .env.development    # DEV_API_URL, Firebase dev project
├── .env.staging        # STAGING_API_URL
└── .env.production     # PROD_API_URL
```

Managed via `flutter_dotenv` + `--dart-define` per flavor.

---

## 12. Dependencies

### `pubspec.yaml` (Key Packages)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^13.2.0

  # Network
  dio: ^5.4.3
  pretty_dio_logger: ^1.3.1

  # Firebase / Auth
  firebase_core: ^2.30.1
  firebase_auth: ^4.19.4
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.1.0

  # Image
  image_picker: ^1.1.2
  flutter_image_compress: ^2.2.0
  cached_network_image: ^3.3.1

  # Local Storage
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.3

  # UI
  phosphor_flutter: ^2.1.0
  lottie: ^3.1.0
  smooth_page_indicator: ^1.1.0
  fl_chart: ^0.68.0       # RadarChart for style profile
  shimmer: ^3.0.0

  # In-App Purchase
  purchases_flutter: ^7.5.0   # RevenueCat

  # Utilities
  connectivity_plus: ^6.0.3
  permission_handler: ^11.3.1
  share_plus: ^9.0.0
  url_launcher: ^6.3.0
  flutter_dotenv: ^5.1.0
  intl: ^0.19.0
  uuid: ^4.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.9
  hive_generator: ^2.0.1
  flutter_lints: ^4.0.0
  mocktail: ^1.0.3
```

### Dependency Notes

- **RevenueCat (`purchases_flutter`)**: Used for cross-platform in-app purchase management. Handles iOS StoreKit + Android Billing Library behind a unified API.
- **`fl_chart`**: Provides `RadarChart` for the StyleQuizResult screen. Configure with `RadarChartData` mapping 6 style axes.
- **`phosphor_flutter`**: Import as `PhosphorIconsRegular`, `PhosphorIconsFill` for dual-weight usage. Alias to avoid verbosity: `typedef PhIcon = PhosphorIconsRegular`.
- **`lottie`**: Used for splash logo animation and camera scanning frame animation. Source JSON files from LottieFiles, store under `assets/animations/`.
- **`sign_in_with_apple`**: Only rendered on iOS. Wrap with `Platform.isIOS` check in `AuthScreen`.

---

*End of Stylo AI Flutter Specification v1.0*
