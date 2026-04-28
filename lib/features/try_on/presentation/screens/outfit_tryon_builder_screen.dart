import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../wardrobe/domain/entities/garment.dart';
import '../../../wardrobe/presentation/screens/wardrobe_picker_screen.dart';
import '../providers/tryon_credits_provider.dart';
import '../providers/try_on_provider.dart';

class OutfitTryonBuilderScreen extends ConsumerStatefulWidget {
  const OutfitTryonBuilderScreen({super.key});

  @override
  ConsumerState<OutfitTryonBuilderScreen> createState() =>
      _OutfitTryonBuilderScreenState();
}

class _OutfitTryonBuilderScreenState
    extends ConsumerState<OutfitTryonBuilderScreen> {
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();
  Garment? _top;
  Garment? _bottom;
  Garment? _outerwear;
  bool _isRunning = false;

  int get _selectedCount =>
      [_top, _bottom, _outerwear].where((g) => g != null).length;

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

  Future<void> _pickGarment(String category) async {
    final picked = await Navigator.of(context).push<Garment>(
      MaterialPageRoute(
        builder: (_) => WardrobePickerScreen(categoryFilter: category),
      ),
    );
    if (picked == null) return;
    setState(() {
      switch (category) {
        case 'top':
          _top = picked;
        case 'bottom':
          _bottom = picked;
        case 'outerwear':
          _outerwear = picked;
      }
    });
  }

  Future<void> _confirm() async {
    if (_selectedCount == 0 || _selectedImagePath == null) return;

    final credits = ref.read(tryonCreditsProvider);
    if (credits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('No te quedan créditos de try-on este mes.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirmed = await _showCreditsDialog(credits);
    if (confirmed != true) return;

    setState(() => _isRunning = true);
    try {
      final garments = <Map<String, String>>[
        if (_bottom != null)
          {'garmentId': _bottom!.id, 'category': 'bottom'},
        if (_top != null)
          {'garmentId': _top!.id, 'category': 'top'},
        if (_outerwear != null)
          {'garmentId': _outerwear!.id, 'category': 'outerwear'},
      ];

      final result = await ref
          .read(tryonRepositoryProvider)
          .tryOnOutfit(imagePath: _selectedImagePath!, garments: garments);

      if (mounted) {
        ref.invalidate(tryonCreditsProvider);
        context.go('/try-on?resultUrl=${Uri.encodeComponent(result)}');
      }
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
      if (mounted) setState(() => _isRunning = false);
    }
  }

  Future<bool?> _showCreditsDialog(TryonCredits credits) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text(
          'Usar créditos de try-on',
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Este try-on usará $_selectedCount de tus ${credits.remaining} créditos disponibles. ¿Continuar?',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continuar',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Armar outfit para probar',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // Photo picker section
                Text(
                  'Tu foto',
                  style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: SizedBox(
                        width: 80,
                        height: 108,
                        child: _selectedImagePath != null
                            ? Image.file(File(_selectedImagePath!), fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _PhotoPlaceholder())
                            : const _PhotoPlaceholder(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Pick buttons
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton.icon(
                            key: const Key('outfit_photo_camera_btn'),
                            onPressed: () => _pickPhoto(ImageSource.camera),
                            icon: const Icon(PhosphorIconsRegular.camera, size: 16),
                            label: const Text('Cámara'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton.icon(
                            key: const Key('outfit_photo_gallery_btn'),
                            onPressed: () => _pickPhoto(ImageSource.gallery),
                            icon: const Icon(PhosphorIconsRegular.image, size: 16),
                            label: const Text('Galería'),
                          ),
                          if (_selectedImagePath == null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Requerida para el try-on',
                              style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textTertiary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Seleccioná las prendas que querés probar. Podés elegir una o más.',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: AppSpacing.lg),
                _GarmentSlot(
                  key: const Key('slot_top'),
                  label: 'Top / Remera',
                  selected: _top,
                  onTap: () => _pickGarment('top'),
                  onClear: _top != null ? () => setState(() => _top = null) : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                _GarmentSlot(
                  key: const Key('slot_bottom'),
                  label: 'Pantalón / Falda',
                  selected: _bottom,
                  onTap: () => _pickGarment('bottom'),
                  onClear:
                      _bottom != null ? () => setState(() => _bottom = null) : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                _GarmentSlot(
                  key: const Key('slot_outerwear'),
                  label: 'Campera / Abrigo',
                  selected: _outerwear,
                  onTap: () => _pickGarment('outerwear'),
                  onClear: _outerwear != null
                      ? () => setState(() => _outerwear = null)
                      : null,
                  optional: true,
                ),
                const SizedBox(height: AppSpacing.sm),
                const _GarmentSlotComingSoon(label: 'Calzado'),
              ],
            ),
          ),
          // Bottom bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('tryon_outfit_confirm_btn'),
                  onPressed: _isRunning || _selectedCount == 0 || _selectedImagePath == null ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textOnPrimary,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full)),
                    elevation: 0,
                  ),
                  child: _isRunning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnPrimary),
                        )
                      : Text(
                          _selectedImagePath == null
                              ? 'Elegí tu foto primero'
                              : _selectedCount == 0
                                  ? 'Seleccioná al menos una prenda'
                                  : 'Probarme este outfit ($_selectedCount prenda${_selectedCount != 1 ? 's' : ''})',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GarmentSlot extends StatelessWidget {
  final String label;
  final Garment? selected;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final bool optional;

  const _GarmentSlot({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.onClear,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: selected != null ? AppColors.accent : AppColors.border,
          width: selected != null ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        leading: selected != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: CachedNetworkImage(
                  imageUrl: selected!.imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const ColoredBox(
                    color: AppColors.accentSubtle,
                    child: Icon(Icons.checkroom_outlined,
                        color: AppColors.accent),
                  ),
                ),
              )
            : Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.add, color: AppColors.accent),
              ),
        title: Text(
          label,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14),
        ),
        subtitle: selected != null
            ? Text(
                selected!.name.isNotEmpty ? selected!.name : selected!.type,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              )
            : Text(
                optional ? 'Opcional — toca para elegir' : 'Toca para elegir',
                style: const TextStyle(
                    color: AppColors.textTertiary, fontSize: 12),
              ),
        trailing: selected != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.accent, size: 20),
                  if (onClear != null) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onClear,
                      child: const Icon(Icons.close,
                          color: AppColors.textTertiary, size: 18),
                    ),
                  ],
                ],
              )
            : const Icon(Icons.add_circle_outline,
                color: AppColors.textTertiary),
        onTap: onTap,
      ),
    );
  }
}

class _GarmentSlotComingSoon extends StatelessWidget {
  final String label;

  const _GarmentSlotComingSoon({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        enabled: false,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(Icons.lock_outline,
              color: AppColors.textTertiary, size: 20),
        ),
        title: Text(label,
            style: const TextStyle(color: AppColors.textTertiary)),
        subtitle: const Text('Próximamente',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
        trailing: const Icon(Icons.lock_outline,
            color: AppColors.textTertiary, size: 18),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          PhosphorIconsRegular.userCircle,
          size: 36,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
