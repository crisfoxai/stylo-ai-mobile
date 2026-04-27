import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/outfit_generator_provider.dart';

class LookPhotoUploadSheet extends ConsumerStatefulWidget {
  final String outfitId;
  final bool hasExistingPhoto;

  const LookPhotoUploadSheet({
    super.key,
    required this.outfitId,
    required this.hasExistingPhoto,
  });

  @override
  ConsumerState<LookPhotoUploadSheet> createState() =>
      _LookPhotoUploadSheetState();
}

class _LookPhotoUploadSheetState extends ConsumerState<LookPhotoUploadSheet> {
  bool _isUploading = false;
  final _picker = ImagePicker();

  Future<void> _pick(ImageSource source) async {
    if (_isUploading) return;

    if (widget.hasExistingPhoto) {
      final confirmed = await _showReplaceDialog();
      if (confirmed != true) return;
    }

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (picked == null) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortá tu foto',
            toolbarColor: AppColors.background,
            toolbarWidgetColor: AppColors.textPrimary,
            activeControlsWidgetColor: AppColors.accent,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Recortá tu foto',
            aspectRatioLockEnabled: true,
          ),
        ],
      );
      if (cropped == null) return;

      setState(() => _isUploading = true);
      await ref
          .read(outfitRepositoryProvider)
          .uploadLookPhoto(widget.outfitId, cropped.path);

      if (mounted) Navigator.of(context).pop(true);
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
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<bool?> _showReplaceDialog() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text(
          '¿Reemplazar la foto del look?',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 17),
        ),
        content: const Text(
          'La foto actual será reemplazada por la nueva.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reemplazar',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Subir foto del look',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'La foto se recortará en formato retrato 3:4',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_isUploading)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.accent),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Subiendo foto...',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              )
            else ...[
              _OptionTile(
                key: const Key('look_photo_camera_btn'),
                icon: Icons.camera_alt_outlined,
                label: 'Sacarme una foto ahora',
                onTap: () => _pick(ImageSource.camera),
              ),
              const SizedBox(height: AppSpacing.sm),
              _OptionTile(
                key: const Key('look_photo_gallery_btn'),
                icon: Icons.photo_library_outlined,
                label: 'Elegir de la galería',
                onTap: () => _pick(ImageSource.gallery),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 22),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
