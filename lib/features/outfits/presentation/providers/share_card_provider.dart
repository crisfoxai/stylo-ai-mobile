import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/share_card_result.dart';
import 'outfit_generator_provider.dart';

final shareCardProvider =
    FutureProvider.family<ShareCardResult, String>((ref, outfitId) async {
  return ref.read(outfitRepositoryProvider).generateShareCard(outfitId);
});
