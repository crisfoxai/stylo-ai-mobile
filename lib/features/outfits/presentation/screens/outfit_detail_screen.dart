import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/outfit.dart';
import '../providers/outfit_generator_provider.dart';

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

  void _share(Outfit outfit) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartiendo "${outfit.name}"...'),
        backgroundColor: AppColors.info,
      ),
    );
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
          onFavorite: () => _toggleFavorite(outfit),
          onLogWorn: () => _logWorn(outfit),
          onShare: () => _share(outfit),
        ),
      ),
    );
  }
}

class _OutfitDetailContent extends StatelessWidget {
  final Outfit outfit;
  final bool isFavoriting;
  final bool isLoggingWorn;
  final VoidCallback onFavorite;
  final VoidCallback onLogWorn;
  final VoidCallback onShare;

  const _OutfitDetailContent({
    required this.outfit,
    required this.isFavoriting,
    required this.isLoggingWorn,
    required this.onFavorite,
    required this.onLogWorn,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          pinned: true,
          expandedHeight: 200,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          actions: [
            IconButton(
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
            background: Container(
              color: AppColors.accentSubtle,
              child: const Center(
                child: Icon(
                  Icons.checkroom_outlined,
                  color: AppColors.accent,
                  size: 80,
                ),
              ),
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
