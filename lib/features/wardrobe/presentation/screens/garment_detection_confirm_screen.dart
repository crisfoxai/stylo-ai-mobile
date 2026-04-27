import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/detection_result.dart';
import '../providers/wardrobe_provider.dart';
import 'garment_detection_edit_sheet.dart';

class GarmentDetectionConfirmScreen extends ConsumerStatefulWidget {
  final DetectionResult result;

  const GarmentDetectionConfirmScreen({super.key, required this.result});

  @override
  ConsumerState<GarmentDetectionConfirmScreen> createState() =>
      _GarmentDetectionConfirmScreenState();
}

class _GarmentDetectionConfirmScreenState
    extends ConsumerState<GarmentDetectionConfirmScreen> {
  late final List<DetectedGarmentEdit> _edits;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _edits = widget.result.detected
        .map(DetectedGarmentEdit.fromDetected)
        .toList();
  }

  Future<void> _confirm() async {
    final selected = _edits.where((e) => e.include).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccioná al menos una prenda para agregar.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isConfirming = true);
    try {
      final ids = await ref
          .read(wardrobeRepositoryProvider)
          .confirmDetection(widget.result.photoKey, selected);

      ref.invalidate(wardrobeNotifierProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Se ${ids.length == 1 ? 'agregó 1 prenda' : 'agregaron ${ids.length} prendas'} a tu guardarropa'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/wardrobe');
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
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  Future<void> _editGarment(int index) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) =>
          GarmentDetectionEditSheet(garment: _edits[index]),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _edits.where((e) => e.include).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Prendas detectadas',
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
            child: _edits.isEmpty
                ? const Center(
                    child: Text(
                      'No se detectaron prendas en la foto.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 15),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _edits.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) =>
                        _DetectedGarmentCard(
                      edit: _edits[i],
                      onToggle: (v) =>
                          setState(() => _edits[i].include = v),
                      onEdit: () => _editGarment(i),
                    ),
                  ),
          ),
          // Bottom bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('detection_discard_btn'),
                      onPressed: _isConfirming ? null : () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.full)),
                      ),
                      child: const Text('Descartar todo'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      key: const Key('detection_confirm_btn'),
                      onPressed:
                          _isConfirming || selectedCount == 0 ? null : _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.full)),
                        elevation: 0,
                      ),
                      child: _isConfirming
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textOnPrimary),
                            )
                          : Text(
                              'Agregar seleccionadas ($selectedCount)',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetectedGarmentCard extends StatelessWidget {
  final DetectedGarmentEdit edit;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  const _DetectedGarmentCard({
    required this.edit,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: edit.include ? AppColors.accent : AppColors.border,
          width: edit.include ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkmark
            Transform.scale(
              scale: 1.1,
              child: Checkbox(
                value: edit.include,
                onChanged: (v) => onToggle(v ?? false),
                activeColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    edit.descripcion,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: [
                      _Chip(edit.tipo),
                      _Chip(edit.color),
                      if (edit.material != null && edit.material!.isNotEmpty)
                        _Chip(edit.material!),
                      if (edit.fit != null && edit.fit!.isNotEmpty)
                        _Chip(edit.fit!),
                    ],
                  ),
                ],
              ),
            ),
            // Edit button
            TextButton(
              onPressed: onEdit,
              child: const Text(
                'Editar',
                style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accentSubtle,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: AppColors.accent,
            fontSize: 11,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}
