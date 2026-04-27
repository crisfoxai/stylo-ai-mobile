import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/detection_result.dart';

class GarmentDetectionEditSheet extends StatefulWidget {
  final DetectedGarmentEdit garment;

  const GarmentDetectionEditSheet({super.key, required this.garment});

  @override
  State<GarmentDetectionEditSheet> createState() =>
      _GarmentDetectionEditSheetState();
}

class _GarmentDetectionEditSheetState
    extends State<GarmentDetectionEditSheet> {
  late final TextEditingController _descController;
  late final TextEditingController _tipoController;
  late final TextEditingController _colorController;
  late final TextEditingController _materialController;
  late final TextEditingController _fitController;

  @override
  void initState() {
    super.initState();
    final g = widget.garment;
    _descController = TextEditingController(text: g.descripcion);
    _tipoController = TextEditingController(text: g.tipo);
    _colorController = TextEditingController(text: g.color);
    _materialController = TextEditingController(text: g.material ?? '');
    _fitController = TextEditingController(text: g.fit ?? '');
  }

  @override
  void dispose() {
    _descController.dispose();
    _tipoController.dispose();
    _colorController.dispose();
    _materialController.dispose();
    _fitController.dispose();
    super.dispose();
  }

  void _save() {
    widget.garment
      ..descripcion = _descController.text.trim()
      ..tipo = _tipoController.text.trim()
      ..color = _colorController.text.trim()
      ..material = _materialController.text.trim().isNotEmpty
          ? _materialController.text.trim()
          : null
      ..fit = _fitController.text.trim().isNotEmpty
          ? _fitController.text.trim()
          : null;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Editar prenda',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          _Field(label: 'Nombre / Descripción', controller: _descController),
          const SizedBox(height: AppSpacing.md),
          _Field(label: 'Tipo (ej: remera, pantalón)', controller: _tipoController),
          const SizedBox(height: AppSpacing.md),
          _Field(label: 'Color', controller: _colorController),
          const SizedBox(height: AppSpacing.md),
          _Field(
              label: 'Material (opcional)', controller: _materialController),
          const SizedBox(height: AppSpacing.md),
          _Field(label: 'Fit (opcional)', controller: _fitController),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textOnPrimary,
              padding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full)),
              elevation: 0,
            ),
            child: const Text('Guardar',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _Field({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
      ),
    );
  }
}
