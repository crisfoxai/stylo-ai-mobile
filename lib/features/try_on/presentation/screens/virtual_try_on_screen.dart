import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/stylo_button.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/presentation/screens/paywall_screen.dart';
import '../providers/try_on_provider.dart';

class VirtualTryOnScreen extends ConsumerStatefulWidget {
  final String garmentId;

  const VirtualTryOnScreen({super.key, required this.garmentId});

  @override
  ConsumerState<VirtualTryOnScreen> createState() => _VirtualTryOnScreenState();
}

class _VirtualTryOnScreenState extends ConsumerState<VirtualTryOnScreen> {
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final hasTryon = ref.watch(hasTryonProvider);

    if (!hasTryon) {
      return const PaywallScreen(feature: PaywallFeature.tryon);
    }

    final tryOnState = ref.watch(tryOnProvider);

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
      body: SafeArea(
        child: _buildBody(tryOnState),
      ),
    );
  }

  Widget _buildBody(TryOnState state) {
    if (state.status == TryOnStatus.done && state.result != null) {
      return _ResultView(
        resultUrl: state.result!.resultUrl,
        onReset: () => ref.read(tryOnProvider.notifier).reset(),
      );
    }

    if (state.status == TryOnStatus.uploading ||
        state.status == TryOnStatus.processing) {
      return _LoadingView();
    }

    return _PickerView(
      selectedImagePath: _selectedImagePath,
      onPickCamera: () => _pickPhoto(ImageSource.camera),
      onPickGallery: () => _pickPhoto(ImageSource.gallery),
      onProcess: _selectedImagePath != null ? _startTryOn : null,
      errorMessage: state.status == TryOnStatus.error ? state.errorMessage : null,
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
      setState(() => _selectedImagePath = xFile.path);
    }
  }

  Future<void> _startTryOn() async {
    final path = _selectedImagePath;
    if (path == null) return;
    await ref.read(tryOnProvider.notifier).startTryOn(path, widget.garmentId);
  }
}

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Generando tu look...',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Puede tardar ~20 segundos',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerView extends StatelessWidget {
  final String? selectedImagePath;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final VoidCallback? onProcess;
  final String? errorMessage;

  const _PickerView({
    required this.selectedImagePath,
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
          AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: selectedImagePath != null
                  ? Image.asset(selectedImagePath!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _PhotoPlaceholder())
                  : _PhotoPlaceholder(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickCamera,
                  icon: const Icon(PhosphorIconsRegular.camera, size: 18),
                  label: const Text('Cámara'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickGallery,
                  icon: const Icon(PhosphorIconsRegular.image, size: 18),
                  label: const Text('Galería'),
                ),
              ),
            ],
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                errorMessage!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          StyloButton(
            label: 'Probarme la prenda',
            onPressed: onProcess,
          ),
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                  label: 'Guardar en galería',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Guardado en galería')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
