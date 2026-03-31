import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/network/endpoints.dart';

void main() {
  group('Endpoints', () {
    group('Auth endpoints', () {
      test('register endpoint is /auth/register', () {
        expect(Endpoints.register, '/auth/register');
      });

      test('login endpoint is /auth/login', () {
        expect(Endpoints.login, '/auth/login');
      });

      test('googleAuth endpoint is /auth/google', () {
        expect(Endpoints.googleAuth, '/auth/google');
      });

      test('appleAuth endpoint is /auth/apple', () {
        expect(Endpoints.appleAuth, '/auth/apple');
      });

      test('refreshToken endpoint is /auth/refresh', () {
        expect(Endpoints.refreshToken, '/auth/refresh');
      });

      test('logout endpoint is /auth/logout', () {
        expect(Endpoints.logout, '/auth/logout');
      });

      test('forgotPassword endpoint is /auth/forgot-password', () {
        expect(Endpoints.forgotPassword, '/auth/forgot-password');
      });
    });

    group('User endpoints', () {
      test('me endpoint is /users/me', () {
        expect(Endpoints.me, '/users/me');
      });

      test('avatar endpoint is /users/me/avatar', () {
        expect(Endpoints.avatar, '/users/me/avatar');
      });

      test('stats endpoint is /users/me/stats', () {
        expect(Endpoints.stats, '/users/me/stats');
      });
    });

    group('Wardrobe endpoints', () {
      test('garments endpoint is /garments', () {
        expect(Endpoints.garments, '/garments');
      });

      test('garment(id) returns correct dynamic path', () {
        expect(Endpoints.garment('abc123'), '/garments/abc123');
      });

      test('garment(id) interpolates different IDs correctly', () {
        expect(Endpoints.garment('xyz-456'), '/garments/xyz-456');
        expect(Endpoints.garment('1'), '/garments/1');
      });

      test('scanUpload endpoint is /garments/scan', () {
        expect(Endpoints.scanUpload, '/garments/scan');
      });

      test('garmentJob(jobId) returns correct dynamic path', () {
        expect(Endpoints.garmentJob('job-001'), '/garments/jobs/job-001');
      });
    });

    group('Outfit endpoints', () {
      test('outfits endpoint is /outfits', () {
        expect(Endpoints.outfits, '/outfits');
      });

      test('outfit(id) returns correct dynamic path', () {
        expect(Endpoints.outfit('outfit-789'), '/outfits/outfit-789');
      });

      test('generateOutfit endpoint is /outfits/generate', () {
        expect(Endpoints.generateOutfit, '/outfits/generate');
      });

      test('favorites endpoint is /outfits/favorites', () {
        expect(Endpoints.favorites, '/outfits/favorites');
      });

      test('toggleFavorite(id) returns correct dynamic path', () {
        expect(Endpoints.toggleFavorite('out-1'), '/outfits/out-1/favorite');
      });

      test('logWorn(id) returns correct dynamic path', () {
        expect(Endpoints.logWorn('out-2'), '/outfits/out-2/worn');
      });

      test('outfitHistory endpoint is /outfits/history', () {
        expect(Endpoints.outfitHistory, '/outfits/history');
      });
    });

    group('Style Profile endpoints', () {
      test('styleProfile endpoint is /style-profile', () {
        expect(Endpoints.styleProfile, '/style-profile');
      });

      test('styleQuiz endpoint is /style-profile/quiz', () {
        expect(Endpoints.styleQuiz, '/style-profile/quiz');
      });
    });

    group('Subscription endpoints', () {
      test('subscription endpoint is /subscription', () {
        expect(Endpoints.subscription, '/subscription');
      });

      test('verifyPurchase endpoint is /subscription/verify', () {
        expect(Endpoints.verifyPurchase, '/subscription/verify');
      });
    });

    group('Weather endpoints', () {
      test('weather endpoint is /weather/current', () {
        expect(Endpoints.weather, '/weather/current');
      });
    });

    group('All static endpoints start with /', () {
      test('all constant endpoints start with /', () {
        final endpoints = [
          Endpoints.register,
          Endpoints.login,
          Endpoints.googleAuth,
          Endpoints.appleAuth,
          Endpoints.refreshToken,
          Endpoints.logout,
          Endpoints.forgotPassword,
          Endpoints.me,
          Endpoints.avatar,
          Endpoints.stats,
          Endpoints.garments,
          Endpoints.scanUpload,
          Endpoints.outfits,
          Endpoints.generateOutfit,
          Endpoints.favorites,
          Endpoints.outfitHistory,
          Endpoints.styleProfile,
          Endpoints.styleQuiz,
          Endpoints.subscription,
          Endpoints.verifyPurchase,
          Endpoints.weather,
        ];
        for (final endpoint in endpoints) {
          expect(endpoint.startsWith('/'), isTrue,
              reason: '$endpoint should start with /');
        }
      });
    });

    group('Dynamic endpoints start with /', () {
      test('garment dynamic endpoint starts with /', () {
        expect(Endpoints.garment('id').startsWith('/'), isTrue);
      });

      test('garmentJob dynamic endpoint starts with /', () {
        expect(Endpoints.garmentJob('id').startsWith('/'), isTrue);
      });

      test('outfit dynamic endpoint starts with /', () {
        expect(Endpoints.outfit('id').startsWith('/'), isTrue);
      });

      test('toggleFavorite dynamic endpoint starts with /', () {
        expect(Endpoints.toggleFavorite('id').startsWith('/'), isTrue);
      });

      test('logWorn dynamic endpoint starts with /', () {
        expect(Endpoints.logWorn('id').startsWith('/'), isTrue);
      });
    });
  });
}
