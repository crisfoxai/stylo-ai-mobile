import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylo_ai/core/constants/storage_keys.dart';
import 'package:stylo_ai/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:stylo_ai/features/auth/data/models/user_model.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AuthLocalDataSource dataSource;
  late _MockFlutterSecureStorage mockSecureStorage;
  late SharedPreferences prefs;

  setUp(() async {
    mockSecureStorage = _MockFlutterSecureStorage();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    dataSource = AuthLocalDataSource(mockSecureStorage, prefs);
  });

  group('AuthLocalDataSource', () {
    group('saveTokens', () {
      test('stores access token and refresh token in secure storage', () async {
        when(
          () => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        await dataSource.saveTokens('access_123', 'refresh_456');

        verify(
          () => mockSecureStorage.write(
            key: StorageKeys.accessToken,
            value: 'access_123',
          ),
        ).called(1);
        verify(
          () => mockSecureStorage.write(
            key: StorageKeys.refreshToken,
            value: 'refresh_456',
          ),
        ).called(1);
      });
    });

    group('getAccessToken', () {
      test('returns token when present', () async {
        when(
          () => mockSecureStorage.read(key: StorageKeys.accessToken),
        ).thenAnswer((_) async => 'my_token');

        final result = await dataSource.getAccessToken();
        expect(result, 'my_token');
      });

      test('returns null when no token stored', () async {
        when(
          () => mockSecureStorage.read(key: StorageKeys.accessToken),
        ).thenAnswer((_) async => null);

        final result = await dataSource.getAccessToken();
        expect(result, isNull);
      });
    });

    group('getRefreshToken', () {
      test('returns refresh token when present', () async {
        when(
          () => mockSecureStorage.read(key: StorageKeys.refreshToken),
        ).thenAnswer((_) async => 'refresh_abc');

        final result = await dataSource.getRefreshToken();
        expect(result, 'refresh_abc');
      });
    });

    group('saveUser / getUser', () {
      test('saves and retrieves a UserModel via SharedPreferences', () async {
        final user = UserModel(
          id: 'u1',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          hasStyleProfile: false,
          createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
        );

        await dataSource.saveUser(user);

        final retrieved = dataSource.getUser();
        expect(retrieved, isNotNull);
        expect(retrieved!.id, 'u1');
        expect(retrieved.email, 'test@example.com');
        expect(retrieved.firstName, 'John');
        expect(retrieved.lastName, 'Doe');
      });

      test('returns null when no user is saved', () {
        final result = dataSource.getUser();
        expect(result, isNull);
      });
    });

    group('clearAll', () {
      test('deletes secure storage and removes user from prefs', () async {
        when(() => mockSecureStorage.deleteAll()).thenAnswer((_) async {});

        final user = UserModel(
          id: 'u1',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          hasStyleProfile: false,
          createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
        );
        await dataSource.saveUser(user);
        expect(dataSource.getUser(), isNotNull);

        await dataSource.clearAll();

        verify(() => mockSecureStorage.deleteAll()).called(1);
        expect(dataSource.getUser(), isNull);
      });
    });
  });
}
