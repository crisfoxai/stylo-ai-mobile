import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'garment_cache.dart';

// Isar offline cache removed — generator version conflict with riverpod_generator.
// WardrobeRepositoryImpl accepts null and falls back to remote-only.
final isarProvider = FutureProvider<dynamic>((ref) async => null);
