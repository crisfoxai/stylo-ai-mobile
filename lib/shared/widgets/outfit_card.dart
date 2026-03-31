import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class OutfitCard extends StatelessWidget {
  final String name;
  final List<String> garmentImageUrls;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final String? occasion;

  const OutfitCard({
    super.key,
    required this.name,
    required this.garmentImageUrls,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
    this.occasion,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnailRow(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailRow() {
    final urls = garmentImageUrls.take(4).toList();
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.shimmer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        child: urls.isEmpty
            ? const Center(
                child: Icon(
                  Icons.style_outlined,
                  size: 40,
                  color: AppColors.textTertiary,
                ),
              )
            : Row(
                children: urls
                    .map(
                      (url) => Expanded(
                        child: CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          height: 100,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: AppColors.shimmer,
                            highlightColor: AppColors.surface,
                            child: Container(color: AppColors.shimmer),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.shimmer,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              size: 24,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (occasion != null)
                  Text(
                    occasion!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onFavoriteTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(isFavorite),
                  color: isFavorite ? AppColors.accent : AppColors.textTertiary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
