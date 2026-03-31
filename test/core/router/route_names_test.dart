import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/router/route_names.dart';

void main() {
  group('RouteNames', () {
    group('onboarding routes', () {
      test('splash route is "splash"', () {
        expect(RouteNames.splash, 'splash');
      });

      test('onboarding route is "onboarding"', () {
        expect(RouteNames.onboarding, 'onboarding');
      });

      test('auth route is "auth"', () {
        expect(RouteNames.auth, 'auth');
      });
    });

    group('style quiz routes', () {
      test('styleQuiz route is "style-quiz"', () {
        expect(RouteNames.styleQuiz, 'style-quiz');
      });

      test('styleQuizResult route is "style-quiz-result"', () {
        expect(RouteNames.styleQuizResult, 'style-quiz-result');
      });
    });

    group('main navigation routes', () {
      test('home route is "home"', () {
        expect(RouteNames.home, 'home');
      });

      test('wardrobe route is "wardrobe"', () {
        expect(RouteNames.wardrobe, 'wardrobe');
      });

      test('outfits route is "outfits"', () {
        expect(RouteNames.outfits, 'outfits');
      });

      test('favorites route is "favorites"', () {
        expect(RouteNames.favorites, 'favorites');
      });

      test('profile route is "profile"', () {
        expect(RouteNames.profile, 'profile');
      });
    });

    group('garment routes', () {
      test('garmentDetail route is "garment-detail"', () {
        expect(RouteNames.garmentDetail, 'garment-detail');
      });

      test('scan route is "scan"', () {
        expect(RouteNames.scan, 'scan');
      });

      test('scanPreview route is "scan-preview"', () {
        expect(RouteNames.scanPreview, 'scan-preview');
      });
    });

    group('outfit routes', () {
      test('outfitDetail route is "outfit-detail"', () {
        expect(RouteNames.outfitDetail, 'outfit-detail');
      });

      test('outfitHistory route is "outfit-history"', () {
        expect(RouteNames.outfitHistory, 'outfit-history');
      });
    });

    group('feature routes', () {
      test('tryOn route is "try-on"', () {
        expect(RouteNames.tryOn, 'try-on');
      });

      test('paywall route is "paywall"', () {
        expect(RouteNames.paywall, 'paywall');
      });
    });

    group('route name format', () {
      test('all route names are non-empty strings', () {
        final routes = [
          RouteNames.splash,
          RouteNames.onboarding,
          RouteNames.auth,
          RouteNames.styleQuiz,
          RouteNames.styleQuizResult,
          RouteNames.home,
          RouteNames.wardrobe,
          RouteNames.garmentDetail,
          RouteNames.scan,
          RouteNames.scanPreview,
          RouteNames.outfits,
          RouteNames.outfitDetail,
          RouteNames.favorites,
          RouteNames.outfitHistory,
          RouteNames.profile,
          RouteNames.tryOn,
          RouteNames.paywall,
        ];
        for (final route in routes) {
          expect(route, isNotEmpty, reason: 'Route name should not be empty');
        }
      });

      test('all route names are lowercase with hyphens only (no spaces)', () {
        final routes = [
          RouteNames.splash,
          RouteNames.onboarding,
          RouteNames.auth,
          RouteNames.styleQuiz,
          RouteNames.styleQuizResult,
          RouteNames.home,
          RouteNames.wardrobe,
          RouteNames.garmentDetail,
          RouteNames.scan,
          RouteNames.scanPreview,
          RouteNames.outfits,
          RouteNames.outfitDetail,
          RouteNames.favorites,
          RouteNames.outfitHistory,
          RouteNames.profile,
          RouteNames.tryOn,
          RouteNames.paywall,
        ];
        final validRoutePattern = RegExp(r'^[a-z][a-z\-]*[a-z]$|^[a-z]+$');
        for (final route in routes) {
          expect(validRoutePattern.hasMatch(route), isTrue,
              reason: '$route should only contain lowercase letters and hyphens');
        }
      });

      test('all route names are unique', () {
        final routes = [
          RouteNames.splash,
          RouteNames.onboarding,
          RouteNames.auth,
          RouteNames.styleQuiz,
          RouteNames.styleQuizResult,
          RouteNames.home,
          RouteNames.wardrobe,
          RouteNames.garmentDetail,
          RouteNames.scan,
          RouteNames.scanPreview,
          RouteNames.outfits,
          RouteNames.outfitDetail,
          RouteNames.favorites,
          RouteNames.outfitHistory,
          RouteNames.profile,
          RouteNames.tryOn,
          RouteNames.paywall,
        ];
        final uniqueRoutes = routes.toSet();
        expect(uniqueRoutes.length, routes.length,
            reason: 'All route names must be unique');
      });
    });
  });
}
