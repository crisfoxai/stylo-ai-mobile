import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/garment.dart';
import '../providers/wardrobe_provider.dart';

class WardrobePickerScreen extends ConsumerWidget {
  final String? categoryFilter;

  const WardrobePickerScreen({super.key, this.categoryFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wardrobeNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          categoryFilter != null
              ? 'Elegir ${_categoryLabel(categoryFilter!)}'
              : 'Elegir prenda',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, WardrobeState state) {
    if (state.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.accent));
    }

    if (state.errorMessage != null) {
      return Center(
        child: Text(
          state.errorMessage!,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final items = categoryFilter == null
        ? state.garments
        : state.garments
            .where((g) =>
                g.category?.toLowerCase() == categoryFilter!.toLowerCase())
            .toList();

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.checkroom_outlined,
                  size: 60, color: AppColors.textTertiary),
              const SizedBox(height: AppSpacing.lg),
              Text(
                categoryFilter != null
                    ? 'No tenés prendas de tipo ${_categoryLabel(categoryFilter!)} en tu guardarropa.'
                    : 'Tu guardarropa está vacío.',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _GarmentTile(
        garment: items[i],
        onTap: () => Navigator.of(context).pop(items[i]),
      ),
    );
  }

  String _categoryLabel(String cat) {
    return switch (cat.toLowerCase()) {
      'top' => 'Top / Remera',
      'bottom' => 'Pantalón / Falda',
      'outerwear' => 'Campera / Abrigo',
      _ => cat,
    };
  }
}

class _GarmentTile extends StatelessWidget {
  final Garment garment;
  final VoidCallback onTap;

  const _GarmentTile({required this.garment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: garment.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    const ColoredBox(color: AppColors.accentSubtle),
                errorWidget: (_, __, ___) => const ColoredBox(
                  color: AppColors.accentSubtle,
                  child: Center(
                    child: Icon(Icons.checkroom_outlined,
                        color: AppColors.accent, size: 28),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Text(
                garment.name.isNotEmpty ? garment.name : garment.type,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
