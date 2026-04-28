import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/garment.dart';
import '../providers/wardrobe_provider.dart';
import 'garment_edit_screen.dart';
import '../../../try_on/presentation/widgets/tryon_button.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';

class GarmentDetailScreen extends ConsumerWidget {
  final String id;

  const GarmentDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garmentAsync = ref.watch(garmentDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: garmentAsync.when(
        loading: () => const _LoadingDetailView(),
        error: (e, __) => _ErrorDetailView(message: AppException.extractMessage(e)),
        data: (garment) => _GarmentDetailView(garment: garment, ref: ref),
      ),
    );
  }
}

// ─── Loading view ────────────────────────────────────────────────────────────

class _LoadingDetailView extends StatelessWidget {
  const _LoadingDetailView();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 380,
          pinned: true,
          backgroundColor: AppColors.background,
          leading: const _BackButton(),
          flexibleSpace: FlexibleSpaceBar(
            background: Shimmer.fromColors(
              baseColor: AppColors.shimmer,
              highlightColor: AppColors.surface,
              child: Container(color: AppColors.shimmer),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Shimmer.fromColors(
                baseColor: AppColors.shimmer,
                highlightColor: AppColors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 200, height: 24, color: AppColors.shimmer),
                    const SizedBox(height: AppSpacing.sm),
                    Container(width: 120, height: 16, color: AppColors.shimmer),
                    const SizedBox(height: AppSpacing.xxl),
                    ...List.generate(
                      5,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Container(height: 56, color: AppColors.shimmer),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─── Error view ──────────────────────────────────────────────────────────────

class _ErrorDetailView extends StatelessWidget {
  final String message;

  const _ErrorDetailView({required this.message});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const _BackButton(),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'No se pudo cargar la prenda',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      message,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Main detail view ────────────────────────────────────────────────────────

class _GarmentDetailView extends StatelessWidget {
  final Garment garment;
  final WidgetRef ref;

  const _GarmentDetailView({required this.garment, required this.ref});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Hero image in app bar
        SliverAppBar(
          expandedHeight: 380,
          pinned: true,
          stretch: true,
          backgroundColor: AppColors.primary,
          leading: const _BackButton(dark: true),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () => _showOptions(context),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground],
            background: Hero(
              tag: 'garment-image-${garment.id}',
              child: CachedNetworkImage(
                imageUrl: garment.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: AppColors.shimmer,
                  highlightColor: AppColors.surface,
                  child: Container(color: AppColors.shimmer),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.shimmer,
                  child: const Center(
                    child: Icon(
                      Icons.checkroom_outlined,
                      size: 80,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Name and type
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          garment.name.isNotEmpty ? garment.name : 'Sin nombre',
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          garment.type,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Date added
                  Text(
                    _formatDate(garment.createdAt),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: AppSpacing.xxl),

              // Attributes
              Text(
                'Características',
                style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.lg),

              _AttributeRow(
                icon: Icons.category_outlined,
                label: 'Tipo',
                value: garment.type.isNotEmpty ? garment.type : '—',
              ),
              _AttributeRow(
                icon: Icons.palette_outlined,
                label: 'Color',
                value: garment.color ?? '—',
              ),
              _AttributeRow(
                icon: Icons.style_outlined,
                label: 'Estilo',
                value: garment.style ?? '—',
              ),
              _AttributeRow(
                icon: Icons.texture_outlined,
                label: 'Material',
                value: garment.material ?? '—',
              ),
              _AttributeRow(
                icon: Icons.wb_sunny_outlined,
                label: 'Temporada',
                value: garment.season ?? '—',
              ),

              // Tags
              if (garment.tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxl),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Etiquetas',
                  style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: garment.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs + 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            tag,
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],

              // Confidence scores
              if (garment.confidences != null && garment.confidences!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxl),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Confianza IA',
                  style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.md),
                ...garment.confidences!.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${(entry.value * 100).toStringAsFixed(0)}%',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: LinearProgressIndicator(
                            value: entry.value,
                            minHeight: 6,
                            backgroundColor: AppColors.border,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Try-On button (plan-aware)
              TryOnButton(
                onTap: () => context.push('/try-on?garmentId=${garment.id}'),
              ),

              if (ref.watch(hasTryonProvider)) ...[
                const SizedBox(height: AppSpacing.xs),
                TextButton.icon(
                  key: const Key('tryon_outfit_builder_btn'),
                  onPressed: () => context.push('/try-on/builder'),
                  icon: const Text('👗', style: TextStyle(fontSize: 14)),
                  label: const Text('Armar outfit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    minimumSize: const Size(double.infinity, 36),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.md),

              // Delete button
              OutlinedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                label: Text(
                  'Eliminar prenda',
                  style: AppTypography.labelLarge.copyWith(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxxxl),
            ]),
          ),
        ),
      ],
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                key: const Key('garment_edit_option'),
                leading: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
                title: Text(
                  'Editar prenda',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GarmentEditScreen(garment: garment),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: Text(
                  'Eliminar prenda',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Eliminar prenda',
          style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          '¿Estás seguro de que querés eliminar esta prenda? Esta acción no se puede deshacer.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Eliminar',
              style: AppTypography.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(wardrobeNotifierProvider.notifier).deleteGarment(garment.id);
        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prenda eliminada'),
              backgroundColor: AppColors.textPrimary,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: ${AppException.extractMessage(e)}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ─── Shared widgets ──────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  final bool dark;

  const _BackButton({this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: dark
                ? Colors.black.withOpacity(0.4)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: dark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _AttributeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AttributeRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textTertiary),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const Spacer(),
            Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
