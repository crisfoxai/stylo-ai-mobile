import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/outfit.dart';
import '../providers/outfit_generator_provider.dart';
import '../providers/share_card_provider.dart';
import '../widgets/look_photo_upload_sheet.dart';

final _outfitDetailProvider =
    FutureProvider.family<Outfit, String>((ref, id) async {
  return ref.watch(outfitRepositoryProvider).getOutfit(id);
});

class OutfitDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const OutfitDetailScreen({super.key, required this.id});

  @override
  ConsumerState<OutfitDetailScreen> createState() =>
      _OutfitDetailScreenState();
}

class _OutfitDetailScreenState extends ConsumerState<OutfitDetailScreen> {
  bool _isFavoriting = false;
  bool _isLoggingWorn = false;
  bool _isGeneratingShareCard = false;
  bool _isDeletingLookPhoto = false;

  Future<void> _openLookPhotoSheet(Outfit outfit) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => LookPhotoUploadSheet(
        outfitId: outfit.id,
        hasExistingPhoto: outfit.hasLookPhoto,
      ),
    );
    if (result == true) {
      ref.invalidate(_outfitDetailProvider(widget.id));
    }
  }

  Future<void> _deleteLookPhoto(Outfit outfit) async {
    if (_isDeletingLookPhoto) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('¿Eliminar foto del look?',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: const Text('Esta acción no se puede deshacer.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _isDeletingLookPhoto = true);
    try {
      await ref.read(outfitRepositoryProvider).deleteLookPhoto(outfit.id);
      ref.invalidate(_outfitDetailProvider(widget.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppException.extractMessage(e)),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeletingLookPhoto = false);
    }
  }

  Future<void> _toggleFavorite(Outfit outfit) async {
    if (_isFavoriting) return;
    setState(() => _isFavoriting = true);
    try {
      await ref
          .read(outfitRepositoryProvider)
          .toggleFavorite(outfit.id);
      ref.invalidate(_outfitDetailProvider(widget.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isFavoriting = false);
    }
  }

  Future<void> _logWorn(Outfit outfit) async {
    if (_isLoggingWorn) return;
    setState(() => _isLoggingWorn = true);
    try {
      await ref
          .read(outfitRepositoryProvider)
          .logWorn(outfit.id);
      ref.invalidate(_outfitDetailProvider(widget.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Outfit registrado como usado hoy'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoggingWorn = false);
    }
  }

  Future<void> _share(Outfit outfit) async {
    if (_isGeneratingShareCard) return;
    HapticFeedback.lightImpact();
    setState(() => _isGeneratingShareCard = true);
    try {
      final result =
          await ref.read(shareCardProvider(outfit.id).future);

      // Download the image to a temp file
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(result.url));
      final response = await request.close();
      final bytes = await response.fold<List<int>>([], (prev, chunk) {
        prev.addAll(chunk);
        return prev;
      });

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/share_card_${outfit.id}.jpg');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/jpeg')],
        text: '¡Mirá mi outfit de hoy en Stylo AI! 🌟',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppException.extractMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingShareCard = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final outfitAsync = ref.watch(_outfitDetailProvider(widget.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: outfitAsync.when(
        loading: () => const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
        error: (error, _) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            iconTheme:
                const IconThemeData(color: AppColors.textPrimary),
          ),
          body: Center(
            child: Text(
              'Error al cargar el outfit',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        ),
        data: (outfit) => _OutfitDetailContent(
          outfit: outfit,
          isFavoriting: _isFavoriting,
          isLoggingWorn: _isLoggingWorn,
          isGeneratingShareCard: _isGeneratingShareCard,
          isDeletingLookPhoto: _isDeletingLookPhoto,
          onFavorite: () => _toggleFavorite(outfit),
          onLogWorn: () => _logWorn(outfit),
          onShare: () => _share(outfit),
          onUploadLookPhoto: () => _openLookPhotoSheet(outfit),
          onDeleteLookPhoto: () => _deleteLookPhoto(outfit),
        ),
      ),
    );
  }
}

class _OutfitDetailContent extends StatelessWidget {
  final Outfit outfit;
  final bool isFavoriting;
  final bool isLoggingWorn;
  final bool isGeneratingShareCard;
  final bool isDeletingLookPhoto;
  final VoidCallback onFavorite;
  final VoidCallback onLogWorn;
  final VoidCallback onShare;
  final VoidCallback onUploadLookPhoto;
  final VoidCallback onDeleteLookPhoto;

  const _OutfitDetailContent({
    required this.outfit,
    required this.isFavoriting,
    required this.isLoggingWorn,
    required this.isGeneratingShareCard,
    required this.isDeletingLookPhoto,
    required this.onFavorite,
    required this.onLogWorn,
    required this.onShare,
    required this.onUploadLookPhoto,
    required this.onDeleteLookPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          pinned: true,
          expandedHeight: 320,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          actions: [
            isGeneratingShareCard
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: SizedBox(
                      key: Key('share_card_loading'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.accent),
                    ),
                  )
                : IconButton(
                    key: const Key('share_outfit_btn'),
                    icon: const Icon(Icons.share_outlined,
                        color: AppColors.textPrimary),
                    onPressed: onShare,
                  ),
            isFavoriting
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.accent),
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      outfit.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_outline,
                      color: outfit.isFavorite
                          ? AppColors.accent
                          : AppColors.textPrimary,
                    ),
                    onPressed: onFavorite,
                  ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _CoverHero(
              outfit: outfit,
              isDeletingLookPhoto: isDeletingLookPhoto,
              onUploadLookPhoto: onUploadLookPhoto,
              onDeleteLookPhoto: onDeleteLookPhoto,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and score
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        outfit.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    if (outfit.score != null) ...[
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.accentSubtle,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: AppColors.accent, size: 14),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              outfit.score!.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // Tags
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    if (outfit.mood != null)
                      _Tag(label: outfit.mood!),
                    if (outfit.event != null)
                      _Tag(label: outfit.event!),
                    if (outfit.weatherContext != null)
                      _Tag(label: outfit.weatherContext!),
                  ],
                ),

                // Rationale
                if (outfit.rationale != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.accentSubtle,
                      borderRadius:
                          BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: AppColors.accent, size: 18),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            outfit.rationale!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xxl),

                Text(
                  'Prendas',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),

                ...outfit.garments.map((garment) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _GarmentCard(garment: garment),
                    )),

                // Worn date
                if (outfit.wornAt != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.history,
                          color: AppColors.textTertiary, size: 16),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Usado el ${_formatDate(outfit.wornAt!)}',
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: AppSpacing.xxl),

                // Usar hoy button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoggingWorn ? null : onLogWorn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      elevation: 0,
                    ),
                    child: isLoggingWorn
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textOnPrimary),
                          )
                        : const Text(
                            'Usar hoy',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}

class _CoverHero extends StatelessWidget {
  final Outfit outfit;
  final bool isDeletingLookPhoto;
  final VoidCallback onUploadLookPhoto;
  final VoidCallback onDeleteLookPhoto;

  const _CoverHero({
    required this.outfit,
    required this.isDeletingLookPhoto,
    required this.onUploadLookPhoto,
    required this.onDeleteLookPhoto,
  });

  String? get _imageUrl =>
      outfit.lookPhotoUrl ?? outfit.tryonImageUrl ?? outfit.coverImageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Cover image
        _imageUrl != null && _imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: _imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    ColoredBox(color: AppColors.accentSubtle),
                errorWidget: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
        // Gradient overlay at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [AppColors.background, Colors.transparent],
              ),
            ),
          ),
        ),
        // Look photo button at bottom
        Positioned(
          bottom: AppSpacing.md,
          left: AppSpacing.lg,
          child: GestureDetector(
            key: const Key('upload_look_photo_btn'),
            onTap: onUploadLookPhoto,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt_outlined,
                      color: Colors.white, size: 16),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    outfit.hasLookPhoto
                        ? 'Cambiar foto del look'
                        : 'Subir foto del look',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Delete look photo button
        if (outfit.hasLookPhoto)
          Positioned(
            bottom: AppSpacing.md,
            right: AppSpacing.lg,
            child: GestureDetector(
              key: const Key('delete_look_photo_btn'),
              onTap: isDeletingLookPhoto ? null : onDeleteLookPhoto,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: isDeletingLookPhoto
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.delete_outline,
                        color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: AppColors.accentSubtle,
      child: const Center(
        child: Icon(Icons.checkroom_outlined, color: AppColors.accent, size: 80),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.accentSubtle,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _GarmentCard extends StatelessWidget {
  final OutfitGarment garment;
  const _GarmentCard({required this.garment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accentSubtle,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: garment.thumbnailUrl != null
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppRadius.sm),
                    child: Image.network(
                      garment.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.checkroom_outlined,
                          color: AppColors.accent),
                    ),
                  )
                : const Icon(Icons.checkroom_outlined,
                    color: AppColors.accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  garment.type,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${garment.color} · ${garment.style}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
