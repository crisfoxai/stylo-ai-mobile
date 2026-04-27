import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/multi_select_chip_row.dart';
import '../../../../core/widgets/single_select_chip_row.dart';
import '../../domain/entities/garment.dart';
import '../providers/wardrobe_provider.dart';

const _materialsOpts = [
  'Algodón', 'Denim', 'Lino', 'Lana', 'Cuero',
  'Sintético', 'Seda', 'Poliéster', 'Mezcla',
];
const _fitsOpts = ['Slim', 'Regular', 'Oversize', 'Relaxed', 'Cropped'];
const _seasonsOpts = ['Primavera', 'Verano', 'Otoño', 'Invierno', 'Todo el año'];
const _occasionsOpts = [
  'Casual', 'Trabajo', 'Formal', 'Deporte', 'Salida nocturna', 'Playa',
];
const _conditionsOpts = ['nuevo', 'buen_estado', 'usado', 'para_donar'];
const _conditionLabels = {
  'nuevo': 'Nuevo',
  'buen_estado': 'Buen estado',
  'usado': 'Usado',
  'para_donar': 'Para donar',
};

class GarmentEditScreen extends ConsumerStatefulWidget {
  final Garment garment;

  const GarmentEditScreen({super.key, required this.garment});

  @override
  ConsumerState<GarmentEditScreen> createState() => _GarmentEditScreenState();
}

class _GarmentEditScreenState extends ConsumerState<GarmentEditScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _typeCtrl;
  late final TextEditingController _colorCtrl;
  late final TextEditingController _styleCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _notesCtrl;

  late List<String> _materials;
  String? _fit;
  late List<String> _seasons;
  late List<String> _occasions;
  String? _condition;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final g = widget.garment;
    _nameCtrl = TextEditingController(text: g.name);
    _typeCtrl = TextEditingController(text: g.type);
    _colorCtrl = TextEditingController(text: g.color ?? '');
    _styleCtrl = TextEditingController(text: g.style ?? '');
    _brandCtrl = TextEditingController(text: g.brand ?? '');
    _priceCtrl = TextEditingController(
        text: g.purchasePrice != null ? g.purchasePrice.toString() : '');
    _notesCtrl = TextEditingController(text: g.notes ?? '');
    _materials = List.from(g.materials);
    _fit = g.fit;
    _seasons = List.from(g.seasons);
    _occasions = List.from(g.occasions);
    _condition = g.condition;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _typeCtrl.dispose();
    _colorCtrl.dispose();
    _styleCtrl.dispose();
    _brandCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final fields = <String, dynamic>{
        if (_nameCtrl.text.trim().isNotEmpty) 'name': _nameCtrl.text.trim(),
        if (_typeCtrl.text.trim().isNotEmpty) 'type': _typeCtrl.text.trim(),
        if (_colorCtrl.text.trim().isNotEmpty) 'color': _colorCtrl.text.trim(),
        if (_styleCtrl.text.trim().isNotEmpty) 'style': _styleCtrl.text.trim(),
        if (_brandCtrl.text.trim().isNotEmpty) 'brand': _brandCtrl.text.trim(),
        if (_materials.isNotEmpty) 'materials': _materials,
        if (_fit != null) 'fit': _fit,
        if (_seasons.isNotEmpty) 'seasons': _seasons,
        if (_occasions.isNotEmpty) 'occasions': _occasions,
        if (_condition != null) 'condition': _condition,
        if (_priceCtrl.text.trim().isNotEmpty)
          'purchasePrice': double.tryParse(_priceCtrl.text.trim()),
        if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      };

      await ref
          .read(wardrobeRepositoryProvider)
          .updateGarment(widget.garment.id, fields);

      ref.invalidate(garmentDetailProvider(widget.garment.id));
      ref.invalidate(wardrobeNotifierProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prenda actualizada'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
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
      if (mounted) setState(() => _isSaving = false);
    }
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
          'Editar prenda',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            key: const Key('garment_save_btn'),
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.accent),
                  )
                : const Text(
                    'Guardar',
                    style: TextStyle(
                        color: AppColors.accent, fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Basic fields
            _SectionTitle('Información básica'),
            const SizedBox(height: AppSpacing.md),
            _Field(label: 'Nombre', controller: _nameCtrl),
            const SizedBox(height: AppSpacing.md),
            _Field(label: 'Tipo', controller: _typeCtrl),
            const SizedBox(height: AppSpacing.md),
            _Field(label: 'Color', controller: _colorCtrl),
            const SizedBox(height: AppSpacing.md),
            _Field(label: 'Estilo', controller: _styleCtrl),
            const SizedBox(height: AppSpacing.md),
            _Field(label: 'Marca (opcional)', controller: _brandCtrl),

            const SizedBox(height: AppSpacing.xxl),
            _SectionTitle('Más detalles (opcional)'),
            const SizedBox(height: AppSpacing.md),

            // Material
            MultiSelectChipRow(
              label: 'Material',
              options: _materialsOpts,
              selected: _materials,
              onChanged: (v) => setState(() => _materials = v),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Fit
            SingleSelectChipRow(
              label: 'Fit',
              options: _fitsOpts,
              selected: _fit,
              onChanged: (v) => setState(() => _fit = v),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Temporada
            MultiSelectChipRow(
              label: 'Temporada',
              options: _seasonsOpts,
              selected: _seasons,
              onChanged: (v) => setState(() => _seasons = v),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Ocasión
            MultiSelectChipRow(
              label: 'Ocasión',
              options: _occasionsOpts,
              selected: _occasions,
              onChanged: (v) => setState(() => _occasions = v),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Estado
            SingleSelectChipRow(
              label: 'Estado',
              options: _conditionsOpts,
              selected: _condition,
              onChanged: (v) => setState(() => _condition = v),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Price
            _Field(
              label: 'Precio de compra (opcional)',
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.md),

            // Notes
            _Field(
              label: 'Notas (opcional)',
              controller: _notesCtrl,
              maxLines: 3,
            ),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  const _Field({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
