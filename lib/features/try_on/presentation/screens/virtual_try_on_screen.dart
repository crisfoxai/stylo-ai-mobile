import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../shared/widgets/stylo_button.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../providers/try_on_provider.dart';

class VirtualTryOnScreen extends ConsumerStatefulWidget {
  final String? outfitId;

  const VirtualTryOnScreen({super.key, this.outfitId});

  @override
  ConsumerState<VirtualTryOnScreen> createState() =>
      _VirtualTryOnScreenState();
}

class _VirtualTryOnScreenState extends ConsumerState<VirtualTryOnScreen> {
  File? _selectedPhoto;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final tryOnState = ref.watch(tryOnProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            PhosphorIconsRegular.arrowLeft,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Prueba Virtual',
          style: AppTypography.headlineSmall
              .copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: false,
      ),
      body: LoadingOverlay(
        isLoading: tryOnState.status == TryOnStatus.loading,
        message: 'Generando prueba virtual...',
        child: SafeArea(
          child: tryOnState.status == TryOnStatus.success
              ? _ResultView(
                  resultUrl: tryOnState.resultUrl!,
                  onReset: () => ref.read(tryOnProvider.notifier).reset(),
                )
              : _PickerView(
                  selectedPhoto: _selectedPhoto,
                  isPremium: isPremium,
                  onPickCamera: () => _pickPhoto(ImageSource.camera),
                  onPickGallery: () => _pickPhoto(ImageSource.gallery),
                  onProcess: _selectedPhoto != null && isPremium
                      ? _processTryOn
                      : null,
                  errorMessage: tryOnState.errorMessage,
                ),
        ),
      ),
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final xFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (xFile != null && mounted) {
      setState(() => _selectedPhoto = File(xFile.path));
    }
  }

  Future<void> _processTryOn() async {
    final photo = _selectedPhoto;
    if (photo == null) return;
    await ref.read(tryOnProvider.notifier).process(
          outfitId: widget.outfitId ?? '',
          userPhoto: photo,
        );
  }
}

class _PickerView extends StatelessWidget {
  final File? selectedPhoto;
  final bool isPremium;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final VoidCallback? onProcess;
  final String? errorMessage;

  const _PickerView({
    required this.selectedPhoto,
    required this.isPremium,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onProcess,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isPremium) ...[
            _PaywallBanner(onUpgrade: () => context.push('/paywall')),
            const SizedBox(height: AppSpacing.xl),
          ],
          AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: selectedPhoto != null
                  ? Image.file(selectedPhoto!, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.surface,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            PhosphorIconsRegular.userCircle,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Seleccioná tu foto',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isPremium ? onPickCamera : null,
                  icon: const Icon(PhosphorIconsRegular.camera, size: 18),
                  label: const Text('Cámara'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isPremium ? onPickGallery : null,
                  icon: const Icon(PhosphorIconsRegular.image, size: 18),
                  label: const Text('Galería'),
                ),
              ),
            ],
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              errorMessage!,
              style:
                  AppTypography.bodySmall.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          StyloButton(
            label: 'Probarme el outfit',
            onPressed: onProcess,
          ),
        ],
      ),
    );
  }
}

class _PaywallBanner extends StatelessWidget {
  final VoidCallback onUpgrade;

  const _PaywallBanner({required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.accentSubtle,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.accent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsFill.crown, color: AppColors.accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Función Premium',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Actualizá para usar la prueba virtual.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onUpgrade,
            child: const Text('Ver planes'),
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final String resultUrl;
  final VoidCallback onReset;

  const _ResultView({required this.resultUrl, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: CachedNetworkImage(
                imageUrl: resultUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (_, __, ___) => const Center(
                  child: Icon(PhosphorIconsRegular.imageBroken, size: 48),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(
                    PhosphorIconsRegular.arrowCounterClockwise,
                    size: 18,
                  ),
                  label: const Text('Reintentar'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: StyloButton(
                  label: 'Guardar',
                  onPressed: () {/* save to gallery */},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
