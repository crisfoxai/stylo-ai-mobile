import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stylo_ai/features/outfits/data/datasources/outfit_remote_datasource.dart';
import 'package:stylo_ai/features/outfits/data/repositories/outfit_repository_impl.dart';
import 'package:stylo_ai/features/outfits/domain/entities/outfit.dart';

class _MockOutfitRemoteDataSource extends Mock
    implements OutfitRemoteDataSource {}

void main() {
  late _MockOutfitRemoteDataSource mockDs;
  late OutfitRepositoryImpl repo;
  late Outfit fakeOutfit;

  setUp(() {
    mockDs = _MockOutfitRemoteDataSource();
    repo = OutfitRepositoryImpl(mockDs);
    fakeOutfit = Outfit(
      id: 'o1',
      name: 'Test Outfit',
      createdAt: DateTime.utc(2024),
    );
  });

  group('OutfitRepositoryImpl', () {
    test('generateOutfit delegates to datasource', () async {
      when(() => mockDs.generateOutfit(
            mood: any(named: 'mood'),
            event: any(named: 'event'),
          )).thenAnswer((_) async => fakeOutfit);

      final result = await repo.generateOutfit(mood: 'happy', event: 'work');

      expect(result.id, 'o1');
      verify(() => mockDs.generateOutfit(mood: 'happy', event: 'work'))
          .called(1);
    });

    test('getOutfits delegates to datasource', () async {
      when(() => mockDs.getOutfits(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => [fakeOutfit]);

      final result = await repo.getOutfits();

      expect(result, hasLength(1));
    });

    test('toggleFavorite delegates to datasource', () async {
      when(() => mockDs.toggleFavorite(any()))
          .thenAnswer((_) async {});

      await repo.toggleFavorite('o1');

      verify(() => mockDs.toggleFavorite('o1')).called(1);
    });

    test('getFavorites delegates to datasource', () async {
      when(() => mockDs.getFavorites()).thenAnswer((_) async => [fakeOutfit]);

      final result = await repo.getFavorites();

      expect(result, hasLength(1));
    });
  });
}
