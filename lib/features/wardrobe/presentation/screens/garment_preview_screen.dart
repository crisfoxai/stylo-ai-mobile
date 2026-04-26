import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/utils/garment_translations.dart';
import '../../../../shared/widgets/stylo_button.dart';
import '../providers/wardrobe_provider.dart';

class GarmentPreviewScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const GarmentPreviewScreen({super.key, required this.imagePath});

  @override
  ConsumerState<GarmentPreviewScreen> createState() =>
      _GarmentPreviewScreenState();
}

class _GarmentPreviewScreenState extends ConsumerState<GarmentPreviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(garmentScanProvider.notifier).startScan(widget.imagePath);
    });
  }

  @override
  void dispose() {
    // Reset scan state when leaving without completing
    super.dispose();
  }

  void _addToWardrobe() {
    final scanState = ref.read(garmentScanProvider);
    if (scanState.result != null) {
      ref.read(wardrobeNotifierProvider.notifier).addGarment(scanState.result!);
      ref.read(garmentScanProvider.notifier).reset();
      context.goNamed('wardrobe');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prenda agregada al guardarropa'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _retryCapture() {
    ref.read(garmentScanProvider.notifier).reset();
    context.pop();
  }

  void _discard() {
    ref.read(garmentScanProvider.notifier).reset();
    context.goNamed('wardrobe');
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(garmentScanProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: _retryCapture,
        ),
        title: Text(
          'Vista previa',
          style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Image preview
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.shimmer,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Classification area
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _buildClassificationArea(scanState),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: _buildActions(scanState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassificationArea(ScanState scanState) {
    return switch (scanState.step) {
      ScanStep.uploading || ScanStep.processing => _buildProcessingShimmer(),
      ScanStep.done => _buildClassificationResult(scanState),
      ScanStep.error => _buildErrorResult(scanState.errorMessage),
      _ => _buildProcessingShimmer(),
    };
  }

  Widget _buildProcessingShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Clasificando prenda con IA...',
              style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Shimmer.fromColors(
          baseColor: AppColors.shimmer,
          highlightColor: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerBar(width: 120, height: 16),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: List.generate(
                  5,
                  (i) => _shimmerBar(width: 60.0 + (i * 15), height: 32),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _shimmerBar(width: 80, height: 16),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: List.generate(
                  3,
                  (i) => _shimmerBar(width: 70.0 + (i * 20), height: 32),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _shimmerBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmer,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }

  Widget _buildClassificationResult(ScanState scanState) {
    final garment = scanState.result!;
    final displayName = garment.name.isNotEmpty
        ? garment.name
        : GarmentTranslations.computedName(garment.color, garment.category ?? garment.type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, size: 18, color: AppColors.accent),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Clasificación IA',
              style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Name
        if (displayName.isNotEmpty) ...[
          Text(
            displayName,
            style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Attribute chips (translated)
        if (garment.type.isNotEmpty)
          _buildAttributeSection('Tipo', [GarmentTranslations.type(garment.type)]),
        if (garment.category != null && garment.category!.isNotEmpty)
          _buildAttributeSection('Categoría', [GarmentTranslations.category(garment.category!)]),
        if (garment.color != null && garment.color!.isNotEmpty)
          _buildAttributeSection('Color', [GarmentTranslations.color(garment.color!)]),
        if (garment.style != null && garment.style!.isNotEmpty)
          _buildAttributeSection('Estilo', [garment.style!]),
        if (garment.season != null && garment.season!.isNotEmpty)
          _buildAttributeSection('Temporada', [garment.season!]),
        if (garment.tags.isNotEmpty)
          _buildAttributeSection('Etiquetas', garment.tags),
      ],
    );
  }

  Widget _buildAttributeSection(String title, List<String> values) {
    if (values.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: values
                .map(
                  (v) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentSubtle,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                    ),
                    child: Text(
                      v,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorResult(String? message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'No se pudo clasificar la prenda',
          style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildActions(ScanState scanState) {
    final isDone = scanState.step == ScanStep.done;
    final isError = scanState.step == ScanStep.error;
    final isProcessing = !isDone && !isError;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDone)
          StyloButton(
            label: 'Agregar al guardarropa',
            onPressed: _addToWardrobe,
            variant: StyloButtonVariant.primary,
          ),
        if (isDone) const SizedBox(height: AppSpacing.md),
        StyloButton(
          label: 'Volver a intentar',
          onPressed: isProcessing ? null : _retryCapture,
          variant: StyloButtonVariant.outlined,
        ),
        const SizedBox(height: AppSpacing.sm),
        StyloButton(
          label: 'Descartar',
          onPressed: isProcessing ? null : _discard,
          variant: StyloButtonVariant.text,
        ),
      ],
    );
  }
}
